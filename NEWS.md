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

* Change C code from 'distance.c' to 'GeographicLib'
* Use C code through the C API instead of 'Rcpp'

## nngeo 0.2.9 (2019-08-07)

* Added 'raster_focal', a wrapper around 'raster::focal'
* Added 'raster_clump', a wrapper around 'raster::clump'
* Added 'raster_slope' and 'raster_aspect', wrappers around 'raster::terrain' for calculating topographic slope and aspect rasters
* Added 'raster_extract', a wrapper around 'raster::extract'
* Added 'raster_trim', a wrapper around 'raster::trim'

## nngeo 0.3.0 (2019-12-03)

* Added 'raster_extend', a wrapper around 'raster::extend'
* When using 'returnDist=TRUE', distances are now returned as sparse 'list' rather than a 'matrix'

## nngeo 0.3.4 (2020-02-03)

* 'st_nn' with 'returnDist=TRUE' returns named list with elements 'nn' and 'dist'
* Replaced 'towns' dataset
* Removed 'raster_*" functions (moved to package 'geobgu')
* Added 'focal2' function (a 3x3 focal filter on 'stars')
* Added 'line' and 'pnt' sample data (based on pgRouting tutorial)
* Added 'st_split_junctions' function
* 'st_connect' now uses 'st_nearest_point' rather than point sampling
* 'st_connect' removes CRS before calculating nearest point, to omit the warning when using lon-lat

## nngeo 0.3.7 (2020-04-04)

* Added parallel processing option for 'st_nn'
* Added 'st_azimuth' function
* Removed 'focal2' function (moved to package 'starsExtra')
* 'st_nn' now raises error if any geometry is empty
* Switched C API from '.Call' to '.C'

## nngeo 0.3.8 (2020-06-10)

* Switched from 'testthat' to 'tinytest'

## nngeo 0.3.9 (2020-08-11)

* Fixed bug in 'st_nn' when 'parallel>1'

## nngeo 0.4.0 (2020-10-18)

* Added 'pkgdown' site
* Ignoring 'parallel' argument for projected points input in 'st_nn'
* Switched from 'RANN' to 'nabor'

## nngeo 0.4.1 (2021-01-07)

* Removed 'st_split_junctions' function
* Added 'max_area' argument in 'st_remove_holes' (Luigi Ranghetti)

## nngeo 0.4.2 (2021-03-15)

* Minor fixes in vignette

## nngeo 0.4.3 (2021-06-13)

* Modified vignette, with an example of adding "distance to nearest" column

## nngeo 0.4.4 (2021-09-06)

* Improved 'st_segments' using 'data.table' (Attilio Benini)
* In 'st_remove_holes', when polygons are in lat/lon, 'lwgeoim::st_geod_area' is used automatically instead of 'sf::st_area' (Arnaud Tarroux)

## nngeo 0.4.5 (2022-01-13)

* Fixed 'st_nn' error when units are 'us-ft'

## nngeo 0.4.6 (2022-05-29)

* Renamed geometry column name from 'geom' to 'geometry' in 'st_remove_holes'
* Fixed e-mail and example ((Attilio Benini))

## nngeo 0.4.7

* Fixed C warning

Other ideas:

* Keep 'x' and 'y' attributes in output of 'st_connect'
* http://r-posts.com/isovists-using-uniform-ray-casting-in-r/
* Add 'data-raw'
* Add 'arrowhead' function
* Add UTM zone function
* Parallel processing message
* Parallel processing in other functions
* Add 'split line to equal parts' function
* Add 'round coord' function
* Add 'extend lines' function
* Add 'bridge lines to network' function
* Geodesic buffer (using geographiclib)
* 'igraph' object from layer based on proximity
* 3D distance of 'POINT Z' layers

