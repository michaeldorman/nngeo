
#ifndef WK_FIELDS_HPP
#define WK_FIELDS_HPP

#include <cstdint>

#include "wk/io.hpp"
#include "wk/reader.hpp"
#include "wk/writer.hpp"

template<typename ContainerType>
class WKFieldsProvider: public WKProvider {
public:
  WKFieldsProvider(const ContainerType& container, uint32_t size):
    container(container), size(size), index(UINT32_MAX) {}

  template<typename ItemType, typename VectorType>
  ItemType field(size_t field) {
    const VectorType& vector = this->container[field];
    return vector[this->index];
  }

  virtual size_t nFields() {
    return this->container.size();
  }

  size_t nFeatures() {
    return this->size;
  }

  // whether or not a feature is null has to be resolved
  // by individual type readers...without knowing anything
  // about the vector types it isn't possible
  bool featureIsNull() {
    return false;
  }

  void reset() {
    this->index = UINT32_MAX;
  }

  bool seekNextFeature() {
    if (this->index == UINT32_MAX) {
      this->index = 0;
    } else {
      this->index++;
    }
    return this->index < this->nFeatures();
  }

protected:
  const ContainerType& container;

private:
  uint32_t size;
  uint32_t index;
};

template<typename ContainerType>
class WKFieldsExporter: public WKExporter {
public:
  WKFieldsExporter(ContainerType container, size_t size):
    WKExporter(size), container(container), index(0) {}

  template<typename ItemType, typename VectorType>
  void setField(size_t field, ItemType value) {
    VectorType vector = this->container[field];
    vector[this->index] = value;
  }

  size_t nFields() {
    return this->container.size();
  }

  void prepareNextFeature() {}

  void writeNull() {
    throw std::runtime_error("writeNull() not meaningful for WKFieldsExporter");
  }

  void writeNextFeature() {
    this->index++;
  }

protected:
  ContainerType container;
  size_t index;
};

template<typename ContainerType>
class WKFieldsReader: public WKReader {
public:
  WKFieldsReader(WKFieldsProvider<ContainerType>& provider):
    WKReader(provider), provider(provider) {}

protected:
  WKFieldsProvider<ContainerType>& provider;
};


template<typename ContainerType>
class WKFieldsWriter: public WKWriter {
public:
  WKFieldsWriter(WKFieldsExporter<ContainerType>& exporter):
    WKWriter(exporter), exporter(exporter) {}

  virtual void nextNull(size_t featureId) = 0;

protected:
  WKFieldsExporter<ContainerType>& exporter;
};

#endif
