#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

/* 
GENERATED WITH:
tools::package_native_routine_registration_skeleton(".")
*/

/* .C calls */
extern void dist_geo_vector(void *, void *, void *, void *, void *, void *);

static const R_CMethodDef CEntries[] = {
    {"dist_geo_vector", (DL_FUNC) &dist_geo_vector, 6},
    {NULL, NULL, 0}
};

void R_init_nngeo(DllInfo *dll)
{
    R_registerRoutines(dll, CEntries, NULL, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}


