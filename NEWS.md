## nngeo 0.1.0 (2018-01-16)

* Initial version

## nngeo 0.1.5 (2018-03-16)

* Added tests for 'st_nn'
* Added progress bar for 'st_nn' (except when using projected points method) and for 'st_connect'
* Added C code (Vincenty) for 'st_nn' lon-lat points method
* Fixed sample size mistake in 'st_nn' example
* Fixed error when using 'sfc' objects

## nngeo 0.1.8 (2018-05-15)

* 'st_connect' lines snap to polygon/line outline instead of centroid
* Added new examples
* Fixed progress bar issues
* Changed formatting in vignette

## nngeo 0.2.0 (2018-07-18)

* Added OpenMP support
* Added 'dist' (sampling point interval) parameter for 'st_connect'
* Fixed progress bar issues in 'st_connect'
* Switched from 'for' loop to 'lapply' in 'st_connect'

## nngeo 0.2.1 (2018-07-21)

* Removed OpenMP support due to issue with Solaris

## nngeo 0.2.2 (2018-09-29)

* Using 'STRICT_R_HEADERS' in Rcpp

## nngeo 0.2.4 (2018-12-06)

* Added 'st_ellipse' function
* Added 'st_remove_holes' function

## nngeo 0.2.7 (2019-03-12)

* Added 'st_postgis' function
* Added 'st_segments' function

## nngeo 0.2.8 (2019-05-12)

* Change C code fron 'distance.c' to 'GeographicLib'
* Use C code through the C API instead of 'Rcpp'

## nngeo 0.2.9 (2019-08-07)

* Added 'raster_focal', a wrapper around 'raster::focal'
* Added 'raster_clump', a wrapper around 'raster::clump'
* Added 'raster_slope' and 'raster_aspect', wrappers around 'raster::terrain' for calculating topographic slope and aspect rasters
* Added 'raster_extract', a wrapper around 'raster::extract'
* Added 'raster_trim', a wrapper around 'raster::trim'

## nngeo 0.3.0

* Added 'raster_extend', a wrapper around 'raster::extend'
* When using 'returnDist=TRUE', distances are now returned as sparse 'list' rather than a 'matrix'

## Other ideas:

* Add parallel processing option
* Add 'st_az' function
* Geodesic buffer
* 'igraph' object from layer based on proximity
* 3D distance of 'POINT Z' layers




