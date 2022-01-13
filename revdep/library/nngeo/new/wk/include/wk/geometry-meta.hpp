
#ifndef WK_GEOMETRY_TYPE_H
#define WK_GEOMETRY_TYPE_H

#include <cstdint>
#include <string>
#include <sstream>
#include "parse-exception.hpp"

// https://github.com/postgis/postgis/blob/2.1.0/doc/ZMSgeoms.txt
// https://github.com/r-spatial/sf/blob/master/src/wkb.cpp

enum WKGeometryType {
  Invalid = 0,
  Point = 1,
  LineString = 2,
  Polygon = 3,
  MultiPoint = 4,
  MultiLineString = 5,
  MultiPolygon = 6,
  GeometryCollection = 7
};

#define EWKB_Z_BIT    0x80000000
#define EWKB_M_BIT    0x40000000
#define EWKB_SRID_BIT 0x20000000

class WKGeometryMeta {
public:
  const static uint32_t SRID_NONE = 0;
  const static uint32_t SIZE_UNKNOWN = UINT32_MAX;

  // type info
  uint32_t geometryType;
  bool hasZ;
  bool hasM;
  bool hasSRID;
  bool hasSize;
  uint32_t size;
  uint32_t srid;

  WKGeometryMeta():
    geometryType(WKGeometryType::Invalid),
    hasZ(false),
    hasM(false),
    hasSRID(false),
    hasSize(false),
    size(SIZE_UNKNOWN),
    srid(SRID_NONE) {}

  WKGeometryMeta(uint32_t geometryType, uint32_t size = SIZE_UNKNOWN):
    geometryType(wkbSimpleGeometryType(geometryType)),
    hasZ(wkbTypeHasZ(geometryType)),
    hasM(wkbTypeHasM(geometryType)),
    hasSRID(geometryType & EWKB_SRID_BIT),
    hasSize(size != SIZE_UNKNOWN),
    size(size),
    srid(SRID_NONE) {}

  WKGeometryMeta(int geometryType, bool hasZ, bool hasM, bool hasSRID):
    geometryType(geometryType),
    hasZ(hasZ),
    hasM(hasM),
    hasSRID(hasSRID),
    hasSize(false),
    size(SIZE_UNKNOWN),
    srid(SRID_NONE) {}

  uint32_t ewkbType() {
    return calcEWKBType(this->geometryType, this->hasZ, this->hasM, this->hasSRID);
  }

  std::string wktType() const {
    std::stringstream f;
    f << wktSimpleGeometryType(this->geometryType);

    if (this->hasZ || this->hasM) {
      f << " ";
    }
    if (this->hasZ) {
      f << "Z";
    }

    if (this->hasM) {
      f << "M";
    }

    return f.str();
  }

  // this is easier to store than a const WKGeometryMeta&, and safer than
  // casting to WKGeometryMeta* for testing identical geometryMeta objects
  uintptr_t id() const {
    return (uintptr_t) this;
  }

private:
  static uint32_t calcEWKBType(int simpleGeometryType, bool hasZ, bool hasM, bool hasSRID) {
    uint32_t out = simpleGeometryType;
    if (hasZ) out |= EWKB_Z_BIT;
    if (hasM) out |= EWKB_M_BIT;
    if (hasSRID) out |= EWKB_SRID_BIT;
    return out;
  }

  static const char* wktSimpleGeometryType(uint32_t simpleGeometryType) {
    switch (simpleGeometryType) {
    case WKGeometryType::Point:
      return "POINT";
    case WKGeometryType::LineString:
      return "LINESTRING";
    case WKGeometryType::Polygon:
      return "POLYGON";
    case WKGeometryType::MultiPoint:
      return "MULTIPOINT";
    case WKGeometryType::MultiLineString:
      return "MULTILINESTRING";
    case WKGeometryType::MultiPolygon:
      return "MULTIPOLYGON";
    case WKGeometryType::GeometryCollection:
      return "GEOMETRYCOLLECTION";
    default:
      // # nocov start
      std::stringstream err;
      err << "Invalid integer geometry type: " << simpleGeometryType;
      throw WKParseException(err.str());
      // # nocov end
    }
  }

  // the 1000 + simpleGeometryType and 3000 + simpleGeometryType
  // series both have Z values as well as those marked with the
  // EWKB_Z_BIT
  static bool wkbTypeHasZ(uint32_t geometryType) {
    if (geometryType & EWKB_Z_BIT) {
      return true;
    }

    geometryType = geometryType & 0x0000ffff;
    return (geometryType >= 1000 && geometryType < 2000) ||
      (geometryType > 3000);
  }

  static bool wkbTypeHasM(uint32_t geometryType) {
    if (geometryType & EWKB_M_BIT) {
      return true;
    }

    geometryType = geometryType & 0x0000ffff;
    return geometryType >= 2000;
  }

  // has to deal with both EWKB flags and the 1000-style WKB types
  static uint32_t wkbSimpleGeometryType(uint32_t geometryType) {
    geometryType = geometryType & 0x0000ffff;
    if (geometryType >= 3000) {
      return geometryType - 3000;
    } else  if (geometryType >= 2000) {
      return geometryType - 2000;
    } else if (geometryType >= 1000) {
      return geometryType - 1000;
    } else {
      return geometryType;
    }
  }
};

#endif
