#define R_NO_REMAP
#include "geodesic.h"

/*
## Function 'dist_geo_vector' parameters:
n = number of 'y' points (length 1)
lon0, lat0 = x point coordinates (length 1)
lon1, lat1 = y points coordinates (length n)
dist = distances (length n)

## Test in R:
.C(
    "dist_geo_vector", 
    as.integer(3), 
    as.double(c(0)), 
    as.double(c(0)), 
    as.double(c(0,1,2)), 
    as.double(c(0,0,0)), 
    as.double(c(0,0,0))
)
*/

void dist_geo_vector(int *n, double *lon0, double *lat0, double *lon1, double *lat1, double *dist) {

  /* Initialize 'geodesic' object */
  double a = 6378137, f = 1/298.257223563;
  double azi1, azi2, s12;
  struct geod_geodesic g;
  geod_init(&g, a, f);

  /* Calculate distances */
  int i;
  for(i = 0; i < *n; i++) {
      geod_inverse(&g, *lat0, *lon0, lat1[i], lon1[i], &s12, &azi1, &azi2);
      dist[i] = s12;
  }

}


