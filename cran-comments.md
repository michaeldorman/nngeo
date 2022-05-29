## Test environments

* local Ubuntu 20.04 install, R 4.2.0
* win-builder (devel and release)

## R CMD check results

There were no ERRORs or WARNINGs.

## Downstream dependencies

I have also run R CMD check on downstream dependencies of 'nngeo', namely 'starsExtra'. All packages passed. 

## Resubmission

This is a resubmission. In this version I have:

* Fixed NOTE on win-devel (by stopping the cluster 'on.exit()')