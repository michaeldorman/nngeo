
#ifndef WK_XYZM_HPP
#define WK_XYZM_HPP

#include <cmath>
#include "wk/fields.hpp"

template<typename ContainerType, typename RealVectorType>
class WKXYZMReader: public WKFieldsReader<ContainerType> {
public:
  WKXYZMReader(WKFieldsProvider<ContainerType>& provider):
    WKFieldsReader<ContainerType>(provider) {}

  void readFeature(size_t featureId) {
    this->handler->nextFeatureStart(featureId);

    double x = this->provider.template field<double, RealVectorType>(0);
    double y = this->provider.template field<double, RealVectorType>(1);
    double z = this->provider.template field<double, RealVectorType>(2);
    double m = this->provider.template field<double, RealVectorType>(3);

    WKGeometryMeta meta(WKGeometryType::Point);
    meta.hasSize = true;
    meta.hasZ = !std::isnan(z);
    meta.hasM = !std::isnan(m);

    // treat NA, NA, NA as an empty point
    if (std::isnan(x) && std::isnan(y) && std::isnan(z) && std::isnan(m)) {
      meta.size = 0;
      this->handler->nextGeometryStart(meta, WKReader::PART_ID_NONE);
      this->handler->nextGeometryEnd(meta, WKReader::PART_ID_NONE);
    } else {
      meta.size = 1;
      WKCoord coord = WKCoord::xyzm(x, y, z, m);
      coord.hasZ = meta.hasZ;
      coord.hasM = meta.hasM;

      this->handler->nextGeometryStart(meta, WKReader::PART_ID_NONE);
      this->handler->nextCoordinate(meta, coord, 0);
      this->handler->nextGeometryEnd(meta, WKReader::PART_ID_NONE);
    }

    this->handler->nextFeatureEnd(featureId);
  }
};

template<typename ContainerType, typename RealVectorType>
class WKXYZMWriter: public WKFieldsWriter<ContainerType> {
public:
  WKXYZMWriter(WKFieldsExporter<ContainerType>& exporter):
    WKFieldsWriter<ContainerType>(exporter) {}

  virtual void nextFeatureStart(size_t featureId) {
    WKFieldsWriter<ContainerType>::nextFeatureStart(featureId);
  }

  void nextNull(size_t featureId) {
    this->exporter.template setField<double, RealVectorType>(0, NAN);
    this->exporter.template setField<double, RealVectorType>(1, NAN);
    this->exporter.template setField<double, RealVectorType>(2, NAN);
    this->exporter.template setField<double, RealVectorType>(3, NAN);
  }

  void nextGeometryStart(const WKGeometryMeta& meta, uint32_t partId) {
    if (meta.geometryType != WKGeometryType::Point) {
      throw std::runtime_error("Can't create xy(zm) from a non-point");
    }

    if (meta.size == 0) {
      this->exporter.template setField<double, RealVectorType>(0, NAN);
      this->exporter.template setField<double, RealVectorType>(1, NAN);
      this->exporter.template setField<double, RealVectorType>(2, NAN);
      this->exporter.template setField<double, RealVectorType>(3, NAN);
    }
  }

  void nextCoordinate(const WKGeometryMeta& meta, const WKCoord& coord, uint32_t coordId) {
    this->exporter.template setField<double, RealVectorType>(0, coord.x);
    this->exporter.template setField<double, RealVectorType>(1, coord.y);
    if (coord.hasZ) {
      this->exporter.template setField<double, RealVectorType>(2, coord.z);
    } else {
      this->exporter.template setField<double, RealVectorType>(2, NAN);
    }
    if (coord.hasM) {
      this->exporter.template setField<double, RealVectorType>(3, coord.m);
    } else {
      this->exporter.template setField<double, RealVectorType>(3, NAN);
    }
  }

};

#endif
