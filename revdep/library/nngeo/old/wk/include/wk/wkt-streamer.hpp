
#ifndef WK_WKT_STREAMER_H
#define WK_WKT_STREAMER_H

#include <clocale>
#include <cstring>
#include "wk/reader.hpp"
#include "wk/geometry-handler.hpp"
#include "wk/io-string.hpp"
#include <Rcpp.h>
using namespace Rcpp;

class WKParseableStringException: public WKParseException {
public:
  WKParseableStringException(std::string expected, std::string found, const char* src, size_t pos):
  WKParseException(makeError(expected, found, src, pos)),
  expected(expected), found(found), src(src), pos(pos) {}

  std::string expected;
  std::string found;
  std::string src;
  size_t pos;

  static std::string makeError(std::string expected, std::string found, const char* src, size_t pos) {
    std::stringstream stream;
    stream << "Expected " << expected << " but found " << found << " (:" << pos << ")";
    return stream.str().c_str();
  }
};


class WKParseableString {
public:
  WKParseableString(const char* str, const char* whitespace, const char* sep):
  str(str), length(strlen(str)), offset(0), whitespace(whitespace), sep(sep) {}

  // Change the position of the cursor
  size_t seek(size_t position) {
    if (position > this->length) {
      position = this->length;
    } else if (position < 0) {
      position = 0;
    }

    size_t delta = position - this->offset;
    this->offset = position;
    return delta;
  }

  void advance() {
    if (this->offset < this->length) {
      this->offset++;
    }
  }

  void advance(int n) {
    if ((this->offset + n) <= this->length) {
      this->offset += n;
    } else {
      this->offset = this->length;
    }
  }

  bool finished() {
    return this->offset >= this->length;
  }

  // Returns the character at the cursor and advances the cursor
  // by one
  char readChar() {
    char out = this->peekChar();
    this->advance();
    return out;
  }

  // Returns the character currently ahead of the cursor
  // without advancing the cursor (skips whitespace)
  char peekChar() {
    this->skipWhitespace();
    if (this->offset < this->length) {
      return this->str[this->offset];
    } else {
      return '\0';
    }
  }

  // Returns true if the next character is one of `chars`
  bool is(char c) {
    return c == this->peekChar();
  }

  // Returns true if the next character is one of `chars`
  bool isOneOf(const char* chars) {
    return strchr(chars, this->peekChar()) != nullptr;
  }

  // Returns true if the next character is most likely to be a number
  bool isNumber() {
    // complicated by nan and inf
    if (this->isOneOf("-nNiI")) {
      std::string text = this->peekUntilSep();
      try {
        std::stod(text);
        return true;
      } catch(std::exception& e) {
        return false;
      }
    } else {
      return this->isOneOf("-0123456789");
    }
  }

  // Returns true if the next character is a letter
  bool isLetter() {
    char found = this->peekChar();
    return (found >= 'a' && found <= 'z') || (found >= 'A' && found <= 'Z');
  }

  std::string assertWord() {
    std::string text = this->peekUntilSep();
    if (!this->isLetter()) {
      this->error("a word", quote(text));
    }

    this->advance(text.size());
    return text;
  }

  // Returns the integer currently ahead of the cursor,
  // throwing an exception if whatever is ahead of the
  // cursor cannot be parsed into an integer
  uint32_t assertInteger() {
    std::string text = this->peekUntilSep();
    try {
      uint32_t out = std::stoul(text);
      this->advance(text.size());
      return out;
    } catch (std::exception& e) {
      if (this->finished()) {
        this->error("an integer", "end of input");
      } else {
        this->error("an integer", quote(text));
      }
    }
  }

  // Returns the double currently ahead of the cursor,
  // throwing an exception if whatever is ahead of the
  // cursor cannot be parsed into a double. This will
  // accept "inf", "-inf", and "nan".
  double assertNumber() {
    std::string text = this->peekUntilSep();
    try {
      double out = std::stod(text);
      this->advance(text.size());
      return out;
    } catch (std::exception& e) {
      if (this->finished()) {
        this->error("a number", "end of input");
      } else {
        this->error("a number", quote(text));
      }
    }
  }

  // Asserts that the character at the cursor is whitespace, and
  // returns a std::string of whitespace characters, advancing the
  // cursor to the end of the whitespace.
  std::string assertWhitespace() {
    if (this->finished()) {
      this->error("whitespace", "end of input");
    }

    char found = this->str[this->offset];
    if (strchr(this->whitespace, found) == nullptr) {
      this->error("whitespace", quote(this->peekUntilSep()));
    }

    size_t offset0 = this->offset;
    size_t nWhitespaceChars = this->skipWhitespace();
    return std::string(&(this->str[offset0]), nWhitespaceChars);
  }

  void assert_(char c) {
    char found = this->peekChar();
    if (found != c) {
      this->error(quote(c), quote(found));
    }
    this->advance();
  }

  // Asserts the that the character at the cursor is one of `chars`
  // and advances the cursor by one (throwing an exception otherwise).
  char assertOneOf(const char* chars) {
    char found = this->peekChar();

    if ((strlen(chars) > 0) && this->finished()) {
      this->error(expectedFromChars(chars), "end of input");
    } else if (strchr(chars, found) == nullptr) {
      this->error(expectedFromChars(chars), quote(this->peekUntilSep()));
    }

    this->advance();
    return found;
  }

  // Asserts that the cursor is at the end of the input
  void assertFinished() {
    this->assertOneOf("");
  }

  // Returns the text between the cursor and the next separator,
  // which is defined to be whitespace or the following characters: =;,()
  // advancing the cursor. If we are at the end of the string, this will
  // return std::string("")
  std::string readUntilSep() {
    this->skipWhitespace();
    size_t wordLen = peekUntil(this->sep);
    bool finished = this->finished();
    if (wordLen == 0 && !finished) {
      wordLen = 1;
    }
    std::string out(&(this->str[this->offset]), wordLen);
    this->advance(wordLen);
    return out;
  }

  // Returns the text between the cursor and the next separator
  // (" \r\n\t,();=") without advancing the cursor.
  std::string peekUntilSep() {
    this->skipWhitespace();
    size_t wordLen = peekUntil(this->sep);
    if (wordLen == 0 && !this->finished()) {
      wordLen = 1;
    }
    return std::string(&(this->str[this->offset]), wordLen);
  }

  // Advances the cursor past any whitespace, returning the
  // number of characters skipped.
  size_t skipWhitespace() {
    return this->skipChars(this->whitespace);
  }

  // Skips all of the characters in `chars`, returning the number of
  // characters skipped.
  size_t skipChars(const char* chars) {
    size_t offset0 = this->offset;
    char c = this->str[this->offset];
    while ((c != '\0') && strchr(chars, c)) {
      this->offset++;
      if (this->offset >= this->length) {
        break;
      }

      c = this->str[this->offset];
    }

    return this->offset - offset0;
  }

  // Returns the number of characters until one of `chars` is encountered,
  // which may be 0.
  size_t peekUntil(const char* chars) {
    size_t offset0 = this->offset;
    size_t offseti = this->offset;
    char c = this->str[offseti];
    while ((c != '\0') && !strchr(chars, c)) {
      offseti++;
      if (offseti >= this->length) {
        break;
      }

      c = this->str[offseti];
    }

    return offseti - offset0;
  }

  [[ noreturn ]] void errorBefore(std::string expected, std::string found) {
    throw WKParseableStringException(expected, quote(found), this->str, this->offset - found.size());
  }

  [[noreturn]] void error(std::string expected, std::string found) {
    throw WKParseableStringException(expected, found, this->str, this->offset);
  }

  [[noreturn]] void error(std::string expected) {
    throw WKParseableStringException(expected, quote(this->peekUntilSep()), this->str, this->offset);
  }

private:
  const char* str;
  size_t length;
  size_t offset;
  const char* whitespace;
  const char* sep;

  static std::string expectedFromChars(const char* chars) {
    size_t nChars = strlen(chars);
    if (nChars == 0) {
      return "end of input";
    } else if (nChars == 1) {
      return quote(chars);
    }

    std::stringstream stream;
    for (size_t i = 0; i < nChars; i++) {
      if (nChars > 2) {
        stream << ",";
      }
      if (i > 0) {
        stream << " or ";
      }
      stream << quote(chars[i]);
    }

    return stream.str();
  }

  static std::string quote(std::string input) {
    if (input.size() == 0) {
      return "end of input";
    } else {
      std::stringstream stream;
      stream << "'" << input << "'";
      return stream.str();
    }
  }

  static std::string quote(char input) {
    if (input == '\0') {
      return "end of input";
    } else {
      std::stringstream stream;
      stream << "'" << input << "'";
      return stream.str();
    }
  }
};


class WKTString: public WKParseableString {
public:
  WKTString(const char* str): WKParseableString(str, " \r\n\t", " \r\n\t,();=") {}

  WKGeometryMeta assertGeometryMeta() {
    WKGeometryMeta meta;
    std::string geometryType = this->assertWord();

    if (geometryType == "SRID") {
      this->assert_('=');
      meta.srid = this->assertInteger();
      meta.hasSRID = true;
      this->assert_(';');
      geometryType = this->assertWord();
    }

    if (this->is('Z')) {
      this->assert_('Z');
      meta.hasZ = true;
    }

    if (this->is('M')) {
      this->assert_('M');
      meta.hasM = true;
    }

    if (this->isEMPTY()) {
      meta.hasSize = true;
      meta.size = 0;
    }

    meta.geometryType = this->geometryTypeFromString(geometryType);
    return meta;
  }

  int geometryTypeFromString(std::string geometryType) {
    if (geometryType == "POINT") {
      return WKGeometryType::Point;
    } else if(geometryType == "LINESTRING") {
      return WKGeometryType::LineString;
    } else if(geometryType == "POLYGON") {
      return WKGeometryType::Polygon;
    } else if(geometryType == "MULTIPOINT") {
      return WKGeometryType::MultiPoint;
    } else if(geometryType == "MULTILINESTRING") {
      return WKGeometryType::MultiLineString;
    } else if(geometryType == "MULTIPOLYGON") {
      return WKGeometryType::MultiPolygon;
    } else if(geometryType == "GEOMETRYCOLLECTION") {
      return WKGeometryType::GeometryCollection;
    } else {
      this->errorBefore("geometry type or 'SRID='", geometryType);
    }
  }

  bool isEMPTY() {
    return this->peekUntilSep() == "EMPTY";
  }

  bool assertEMPTYOrOpen() {
    if (this->isLetter()) {
      std::string word = this->assertWord();
      if (word != "EMPTY") {
        this->errorBefore("'(' or 'EMPTY'", word);
      }

      return true;
    } else if (this->is('(')) {
      this->assert_('(');
      return false;
    } else {
      this->error("'(' or 'EMPTY'");
    }
  }
};


class WKTStreamer: public WKReader {
public:

  WKTStreamer(WKStringProvider& provider): WKReader(provider), provider(provider) {
    // constructor and deleter set the thread locale while the object is in use
#ifdef _MSC_VER
    _configthreadlocale(_ENABLE_PER_THREAD_LOCALE);
#endif
    char* p = std::setlocale(LC_NUMERIC, nullptr);
    if(p != nullptr) {
      this->saved_locale = p;
    }
    std::setlocale(LC_NUMERIC, "C");
  }

  ~WKTStreamer() {
    std::setlocale(LC_NUMERIC, saved_locale.c_str());
  }

  void readFeature(size_t featureId) {
    this->handler->nextFeatureStart(featureId);

    if (this->provider.featureIsNull()) {
      this->handler->nextNull(featureId);
    } else {
      std::string str = this->provider.featureString();
      WKTString s(str.c_str());
      this->readGeometryWithType(s, PART_ID_NONE);
      // we probably want to assert finished here, but
      // keeping this commented-out until all examples of this
      // are removed from downstream packages (notably, s2)
      // s.assertFinished();
    }

    this->handler->nextFeatureEnd(featureId);
  }

protected:
  WKStringProvider& provider;

  void readGeometryWithType(WKTString& s, uint32_t partId) {
    WKGeometryMeta meta = s.assertGeometryMeta();
    this->handler->nextGeometryStart(meta, partId);

    switch (meta.geometryType) {

    case WKGeometryType::Point:
      this->readPoint(s, meta);
      break;

    case WKGeometryType::LineString:
      this->readLineString(s, meta);
      break;

    case WKGeometryType::Polygon:
      this->readPolygon(s, meta);
      break;

    case WKGeometryType::MultiPoint:
      this->readMultiPoint(s, meta);
      break;

    case WKGeometryType::MultiLineString:
      this->readMultiLineString(s, meta);
      break;

    case WKGeometryType::MultiPolygon:
      this->readMultiPolygon(s, meta);
      break;

    case WKGeometryType::GeometryCollection:
      this->readGeometryCollection(s, meta);
      break;

    default:
      throw WKParseException("Unknown geometry type integer"); // # nocov
    }

    this->handler->nextGeometryEnd(meta, partId);
  }

  void readPoint(WKTString& s, const WKGeometryMeta& meta) {
    if (!s.assertEMPTYOrOpen()) {
      this->readPointCoordinate(s, meta);
      s.assert_(')');
    }
  }

  void readLineString(WKTString& s, const WKGeometryMeta& meta) {
    this->readCoordinates(s, meta);
  }

  void readPolygon(WKTString& s, const WKGeometryMeta& meta)  {
    this->readLinearRings(s, meta);
  }

  uint32_t readMultiPoint(WKTString& s, const WKGeometryMeta& meta) {
    if (s.assertEMPTYOrOpen()) {
      return 0;
    }

    WKGeometryMeta childMeta;
    uint32_t partId = 0;

    if (s.isNumber()) { // (0 0, 1 1)
      do {
        childMeta = this->childMeta(s, meta, WKGeometryType::Point);

        this->handler->nextGeometryStart(childMeta, partId);
        if (s.isEMPTY()) {
          s.assertWord();
        } else {
          this->readPointCoordinate(s, childMeta);
        }
        this->handler->nextGeometryEnd(childMeta, partId);

        partId++;
      } while (s.assertOneOf(",)") != ')');

    } else { // ((0 0), (1 1))
      do {
        childMeta = this->childMeta(s, meta, WKGeometryType::Point);
        this->handler->nextGeometryStart(childMeta, partId);
        this->readPoint(s, childMeta);
        this->handler->nextGeometryEnd(childMeta, partId);
        partId++;
      } while (s.assertOneOf(",)") != ')');
    }

    return partId;
  }

  uint32_t readMultiLineString(WKTString& s, const WKGeometryMeta& meta) {
    if (s.assertEMPTYOrOpen()) {
      return 0;
    }

    WKGeometryMeta childMeta;
    uint32_t partId = 0;
    do {
      childMeta = this->childMeta(s, meta, WKGeometryType::LineString);
      this->handler->nextGeometryStart(childMeta, partId);
      this->readLineString(s, childMeta);
      this->handler->nextGeometryEnd(childMeta, partId);
      partId++;
    } while (s.assertOneOf(",)") != ')');

    return partId;
  }

  uint32_t readMultiPolygon(WKTString& s, const WKGeometryMeta& meta) {
    if (s.assertEMPTYOrOpen()) {
      return 0;
    }

    WKGeometryMeta childMeta;
    uint32_t partId = 0;
    do {
      childMeta = this->childMeta(s, meta, WKGeometryType::Polygon);
      this->handler->nextGeometryStart(childMeta, partId);
      this->readPolygon(s, childMeta);
      this->handler->nextGeometryEnd(childMeta, partId);
      partId++;
    } while (s.assertOneOf(",)") != ')');

    return partId;
  }

  uint32_t readGeometryCollection(WKTString& s, const WKGeometryMeta& meta) {
    if (s.assertEMPTYOrOpen()) {
      return 0;
    }

    uint32_t partId = 0;
    do {
      this->readGeometryWithType(s, partId);
      partId++;
    } while (s.assertOneOf(",)") != ')');

    return partId;
  }

  uint32_t readLinearRings(WKTString& s, const WKGeometryMeta& meta) {
    if (s.assertEMPTYOrOpen()) {
      return 0;
    }

    uint32_t ringId = 0;
    do {
      this->handler->nextLinearRingStart(meta, WKGeometryMeta::SIZE_UNKNOWN, ringId);
      this->readCoordinates(s, meta);
      this->handler->nextLinearRingEnd(meta, WKGeometryMeta::SIZE_UNKNOWN, ringId);
      ringId++;
    } while (s.assertOneOf(",)") != ')');

    return ringId;
  }

  // Point coordinates are special in that there can only be one
  // coordinate (and reading more than one might cause errors since
  // writers are unlikely to expect a point geometry with many coordinates).
  // This assumes that `s` has already been checked for EMPTY or an opener
  // since this is different for POINT (...) and MULTIPOINT (.., ...)
  uint32_t readPointCoordinate(WKTString& s, const WKGeometryMeta& meta) {
    WKCoord coord = this->childCoordinate(meta);
    this->readCoordinate(s, coord);
    handler->nextCoordinate(meta, coord, 0);
    return 1;
  }

  uint32_t readCoordinates(WKTString& s, const WKGeometryMeta& meta) {
    WKCoord coord = this->childCoordinate(meta);

    if (s.assertEMPTYOrOpen()) {
      return 0;
    }

    uint32_t coordId = 0;
    do {
      this->readCoordinate(s, coord);
      handler->nextCoordinate(meta, coord, coordId);
      coordId++;
    } while (s.assertOneOf(",)") != ')');

    return coordId;
  }

  void readCoordinate(WKTString& s, WKCoord& coord) {
    coord[0] = s.assertNumber();
    for (size_t i = 1; i < coord.size(); i++) {
      s.assertWhitespace();
      coord[i] = s.assertNumber();
    }
  }

  WKCoord childCoordinate(const WKGeometryMeta& meta) {
    WKCoord coord;
    coord.hasZ = meta.hasZ;
    coord.hasM = meta.hasM;
    return coord;
  }

  WKGeometryMeta childMeta(WKTString& s, const WKGeometryMeta& parent, int geometryType) {
    WKGeometryMeta childMeta(parent);
    childMeta.geometryType = geometryType;
    if (s.isEMPTY()) {
      childMeta.hasSize = true;
      childMeta.size = 0;
    } else {
      childMeta.hasSize = false;
      childMeta.size = WKGeometryMeta::SIZE_UNKNOWN;
    }

    return childMeta;
  }

private:
  std::string saved_locale;
};

#endif
