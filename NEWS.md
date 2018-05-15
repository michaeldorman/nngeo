# nngeo 0.1.0 (2018-01-16)

* Initial version

# nngeo 0.1.5 (2018-03-16)

* Added tests for 'st_nn'
* Added progress bar for 'st_nn' (except when using projected points method) and for 'st_connect'
* Added C code (Vincenty) for 'st_nn' lon-lat points method
* Fixed sample size mistake in 'st_nn' example
* Fixed error when using 'sfc' objects

# nngeo 0.1.8

* 'st_connect' lines snap to polygon/line outline instead of centroid
* Added new examples
* Fixed progress bar issues
* Changed formatting in vignette

# To do:

* Geodesic buffer
* Refine outline point sampling, to determine sample size relatively to outline length
* 'igraph' object from layer based on proximity
