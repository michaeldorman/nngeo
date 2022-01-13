
#ifndef WK_RCPP_TRANSLATE_HPP
#define WK_RCPP_TRANSLATE_HPP

#include "wk/wkt-writer.hpp"
#include "wk/wkt-reader.hpp"
#include "wk/wkb-writer.hpp"
#include "wk/wkb-reader.hpp"

#include "wk/xyzm.hpp"
#include "wk/rct.hpp"

#include <Rcpp.h>
#include "wk/rcpp-io.hpp"

class RcppWKFieldsProvider: public WKFieldsProvider<List> {
public:
  RcppWKFieldsProvider(const List& container):
  WKFieldsProvider<List>(container, Rf_xlength(container[0])) {}
};

class RcppFieldsExporter: public WKFieldsExporter<List> {
public:
  RcppFieldsExporter(const List& container):
  WKFieldsExporter<List>(container, Rf_xlength(container[0])) {}
};

class RcppXYZMReader: public WKXYZMReader<List, NumericVector> {
public:
  RcppXYZMReader(RcppWKFieldsProvider& provider):
  WKXYZMReader<List, NumericVector>(provider) {}
};

class RcppXYZMWriter: public WKXYZMWriter<List, NumericVector> {
public:
  RcppXYZMWriter(RcppFieldsExporter& exporter):
  WKXYZMWriter<List, NumericVector>(exporter) {}
};

class RcppWKRctReader: public WKRctReader<List, NumericVector> {
public:
  RcppWKRctReader(RcppWKFieldsProvider& provider):
  WKRctReader<List, NumericVector>(provider) {}
};

namespace wk {

inline void rcpp_translate_base(WKReader& reader, WKWriter& writer,
                                int includeZ = NA_INTEGER, int includeM = NA_INTEGER,
                                int includeSRID = NA_INTEGER) {
  writer.setIncludeZ(includeZ);
  writer.setIncludeM(includeM);
  writer.setIncludeSRID(includeSRID);

  reader.setHandler(&writer);

  while (reader.hasNextFeature()) {
    Rcpp::checkUserInterrupt();
    reader.iterateFeature();
  }
}

inline Rcpp::List rcpp_translate_wkb(WKReader& reader,
                                    int endian, int bufferSize = 2048,
                                    int includeZ = NA_INTEGER, int includeM = NA_INTEGER,
                                    int includeSRID = NA_INTEGER) {
  WKRawVectorListExporter exporter(reader.nFeatures());
  exporter.setBufferSize(bufferSize);
  WKBWriter writer(exporter);
  writer.setEndian(endian);

  rcpp_translate_base(reader, writer, includeZ, includeM, includeSRID);

  return exporter.output;
}


inline Rcpp::CharacterVector rcpp_translate_wkt(WKReader& reader,
                                                int precision = 16, bool trim = true,
                                                int includeZ = NA_INTEGER, int includeM = NA_INTEGER,
                                                int includeSRID = NA_INTEGER) {
  WKCharacterVectorExporter exporter(reader.nFeatures());
  exporter.setRoundingPrecision(precision);
  exporter.setTrim(trim);
  WKTWriter writer(exporter);

  rcpp_translate_base(reader, writer, includeZ, includeM, includeSRID);

  return exporter.output;
}

Rcpp::List rcpp_translate_xyzm(WKReader& reader, int includeZ = NA_INTEGER, int includeM = NA_INTEGER) {
  Rcpp::List xyzm = List::create(
    _["x"] = NumericVector(reader.nFeatures()),
    _["y"] = NumericVector(reader.nFeatures()),
    _["z"] = NumericVector(reader.nFeatures()),
    _["m"] = NumericVector(reader.nFeatures())
  );

  RcppFieldsExporter exporter(xyzm);
  RcppXYZMWriter writer(exporter);
  rcpp_translate_base(reader, writer, includeZ, includeM, false);
  return xyzm;
}

} // namespace wk

#endif
