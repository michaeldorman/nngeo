#define R_NO_REMAP
#include <stdio.h>
#include "geodesic.h"
#include <R.h>
#include <Rinternals.h>

SEXP addr_dist_one(SEXP v) {

  SEXP out = PROTECT(Rf_allocVector(REALSXP, 1));
  
  double a = 6378137, f = 1/298.257223563; /* WGS84 */
  double azi1, azi2, s12;
  struct geod_geodesic g;
  geod_init(&g, a, f);
  
  double lon1 = REAL(v)[0];
  double lat1 = REAL(v)[1];
  double lon2 = REAL(v)[2];
  double lat2 = REAL(v)[3];
  
  geod_inverse(&g, lat1, lon1, lat2, lon2, &s12, &azi1, &azi2);

  REAL(out)[0] = s12;

  UNPROTECT(1);

  return out;
}


