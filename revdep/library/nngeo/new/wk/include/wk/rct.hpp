
#ifndef WK_RCT_HPP
#define WK_RCT_HPP

#include <cmath>
#include "wk/fields.hpp"

template<typename ContainerType, typename RealVectorType>
class WKRctReader: public WKFieldsReader<ContainerType> {
public:
  WKRctReader(WKFieldsProvider<ContainerType>& provider):
    WKFieldsReader<ContainerType>(provider) {}

  void readFeature(size_t featureId) {
    this->handler->nextFeatureStart(featureId);

    double xmin = this->provider.template field<double, RealVectorType>(0);
    double ymin = this->provider.template field<double, RealVectorType>(1);
    double xmax = this->provider.template field<double, RealVectorType>(2);
    double ymax = this->provider.template field<double, RealVectorType>(3);

    WKGeometryMeta meta(WKGeometryType::Polygon, false, false, false);
    meta.hasSize = true;

    // treat any rectangle with a nan or -Inf width or height as empty
    // width/height of Inf *is* allowed, since this could be used to encode
    // a rectangle covering everything
    double width = xmax - xmin;
    double height = ymax - ymin;

    if ((std::isnan(width)) ||
        (std::isnan(height)) ||
        (width == -INFINITY) ||
        (height == -INFINITY)) {
      meta.size = 0;
      this->handler->nextGeometryStart(meta, WKReader::PART_ID_NONE);
      this->handler->nextGeometryEnd(meta, WKReader::PART_ID_NONE);
    } else {
      meta.size = 1;
      this->handler->nextGeometryStart(meta, WKReader::PART_ID_NONE);
      this->handler->nextLinearRingStart(meta, 5, 0);

      this->handler->nextCoordinate(meta, WKCoord::xy(xmin, ymin), 0);
      this->handler->nextCoordinate(meta, WKCoord::xy(xmax, ymin), 1);
      this->handler->nextCoordinate(meta, WKCoord::xy(xmax, ymax), 2);
      this->handler->nextCoordinate(meta, WKCoord::xy(xmin, ymax), 3);
      this->handler->nextCoordinate(meta, WKCoord::xy(xmin, ymin), 4);

      this->handler->nextLinearRingEnd(meta, 5, 0);
      this->handler->nextGeometryEnd(meta, WKReader::PART_ID_NONE);
    }

    this->handler->nextFeatureEnd(featureId);
  }
};

#endif
