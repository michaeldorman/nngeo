
#ifndef WK_RCPP_IO_H
#define WK_RCPP_IO_H

#include "wk/parse-exception.hpp"
#include "wk/io-bytes.hpp"
#include "wk/io-string.hpp"

#include <Rcpp.h>

class WKRcppSEXPProvider: public WKProvider {
public:
  const Rcpp::List& input;
  R_xlen_t index;

  WKRcppSEXPProvider(const Rcpp::List& input): input(input) {
    this->reset();
  }

  void reset() {
    this->index = -1;
  }

  SEXP feature() {
    return this->input[this->index];
  }

  bool seekNextFeature() {
    this->index++;
    return this->index < input.size();
  }

  bool featureIsNull() {
    return this->input[this->index] == R_NilValue;
  }

  size_t nFeatures() {
    return input.size();
  }
};

class WKRcppSEXPExporter: public WKExporter {
public:
  Rcpp::List output;
  R_xlen_t index;
  WKRcppSEXPExporter(size_t size): WKExporter(size), output(size), index(0) {}

  void prepareNextFeature() {}

  void setFeature(SEXP item) {
    this->item = item;
  }

  void writeNull() {
    this->setFeature(R_NilValue);
  }

  void writeNextFeature() {
    if (this->index >= output.size()) {
      Rcpp::stop("Attempt to set index out of range (WKRcppSEXPExporter)");
    }

    this->output[this->index] = this->item;
    this->index++;
  }

private:
  SEXP item;
};


class WKRawVectorListProvider: public WKBytesProvider {
public:

  WKRawVectorListProvider(const Rcpp::List& container): container(container) {
    this->reset();
  }

  void reset() {
    this->index = -1;
    this->featureNull = true;
    this->offset = 0;
  }

  unsigned char readCharRaw() {
    return readBinary<unsigned char>();
  }

  double readDoubleRaw() {
    return readBinary<double>();
  }

  uint32_t readUint32Raw() {
    return readBinary<uint32_t>();
  }

  bool seekNextFeature() {
    this->index += 1;
    if (this->index >= this->container.size()) {
      return false;
    }

    SEXP item = this->container[this->index];

    if (item == R_NilValue) {
      this->featureNull = true;
      this->data = nullptr;
      this->dataSize = 0;
    } else {
      this->featureNull = false;
      this->data = RAW(item);
      this->dataSize = Rf_xlength(item);
    }

    this->offset = 0;
    return true;
  }

  bool featureIsNull() {
    return this->featureNull;
  }

  size_t nFeatures() {
    return container.size();
  }

private:
  const Rcpp::List& container;
  R_xlen_t index;
  unsigned char* data;
  size_t dataSize;
  size_t offset;
  bool featureNull;

  template<typename T>
  T readBinary() {
    if ((this->offset + sizeof(T)) > this->dataSize) {
      throw WKParseException("Reached end of RawVector input");
    }

    T dst;
    memcpy(&dst, &(this->data[this->offset]), sizeof(T));
    this->offset += sizeof(T);
    return dst;
  }
};

class WKRawVectorListExporter: public WKBytesExporter {
public:
  Rcpp::List output;
  std::vector<unsigned char> buffer;
  bool featureNull;

  R_xlen_t index;
  size_t offset;

  WKRawVectorListExporter(size_t size): WKBytesExporter(size), buffer(2048) {
    this->featureNull = false;
    this->index = 0;
    this->offset = 0;
    output = Rcpp::List(size);
  }

  void prepareNextFeature() {
    this->offset = 0;
    this->featureNull = false;
  }

  void writeNull() {
    this->featureNull = true;
  }

  void writeNextFeature() {
    if (this->index >= output.size()) {
      Rcpp::stop("Attempt to set index out of range (WKRawVectorListExporter)");
    }

    if (this->featureNull) {
      this->output[this->index] = R_NilValue;
    } else {
      Rcpp::RawVector item(this->offset);
      memcpy(&(item[0]), &(this->buffer[0]), this->offset);
      this->output[this->index] = item;
    }

    this->index++;
  }

  void setBufferSize(R_xlen_t bufferSize) {
    if (bufferSize <= 0) {
      throw std::runtime_error("Attempt to set zero or negative buffer size");
    }

    this->buffer = std::vector<unsigned char>(bufferSize);
  }

  void extendBufferSize(R_xlen_t bufferSize) {
    if (bufferSize < ((R_xlen_t) this->buffer.size())) {
      throw std::runtime_error("Attempt to shrink RawVector buffer size");
    }

    std::vector<unsigned char> newBuffer(bufferSize);
    memcpy(&newBuffer[0], &(this->buffer[0]), this->offset);
    this->buffer = newBuffer;
  }

  size_t writeCharRaw(unsigned char value) {
    return this->writeBinary<unsigned char>(value);
  }

  size_t writeDoubleRaw(double value) {
    return this->writeBinary<double>(value);
  }

  size_t writeUint32Raw(uint32_t value) {
    return this->writeBinary<uint32_t>(value);
  }

  template<typename T>
  size_t writeBinary(T value) {
    // Rcout << "Writing " << sizeof(T) << "(" << value << ") starting at " << this->offset << "\n";
    while ((this->offset + sizeof(T)) > ((size_t) this->buffer.size())) {
      // we're going to need a bigger boat
      this->extendBufferSize(this->buffer.size() * 2);
    }

    memcpy(&(this->buffer[this->offset]), &value, sizeof(T));
    this->offset += sizeof(T);
    return sizeof(T);
  }
};

class WKCharacterVectorProvider: public WKStringProvider {
public:
  const Rcpp::CharacterVector& container;
  R_xlen_t index;
  bool featureNull;
  std::string data;

  WKCharacterVectorProvider(const Rcpp::CharacterVector& container): container(container) {
    this->reset();
  }

  void reset() {
    this->index = -1;
    this->featureNull = false;
  }

  bool seekNextFeature() {
    this->index++;
    if (this->index >= this->container.size()) {
      return false;
    }

    if (Rcpp::CharacterVector::is_na(this->container[this->index])) {
      this->featureNull = true;
      this->data = std::string("");
    } else {
      this->featureNull = false;
      this->data = Rcpp::as<std::string>(this->container[this->index]);
    }

    return true;
  }

  const std::string featureString() {
    return this->data;
  }

  bool featureIsNull() {
    return this->featureNull;
  }

  size_t nFeatures() {
    return container.size();
  }
};

class WKCharacterVectorExporter: public WKStringStreamExporter {
public:
  Rcpp::CharacterVector output;
  R_xlen_t index;
  bool featureNull;

  WKCharacterVectorExporter(size_t size):
    WKStringStreamExporter(size), output(size), index(0), featureNull(false) {}

  void prepareNextFeature() {
    this->featureNull = false;
    this->stream.str("");
    this->stream.clear();
  }

  void writeNull() {
    this->featureNull = true;
  }

  void writeNextFeature() {
    if (this->index >= output.size()) {
      Rcpp::stop("Attempt to set index out of range (WKCharacterVectorExporter)");
    }

    if (this->featureNull) {
      this->output[this->index] = NA_STRING;
    } else {
      this->output[this->index] = this->stream.str();
    }

    this->index++;
  }
};

#endif
