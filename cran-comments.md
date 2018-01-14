## Test environments
* local Ubuntu 16.04 install, R 3.4.3
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

## Reverse dependencies

This is a new release, so there are no reverse dependencies.

## Resubmission

This is a resubmission. In this version I have:

* Replaced 'K-Nearest Neighbor' to 'K-nearest neighbor' in the DESCRIPTION. 
Thus I hope it is clear that the term does not refer to a specific algorithm, but to the general methodology, and does not require a reference. 

* Added further clarification of the algorithms currently used in the DESCRIPTION: 'Nearest neighbor search uses (1) function 'nn2' from package 'RANN' for projected point data, or (2) function 'st_distance' from package 'sf' for other types of spatial data.' 
