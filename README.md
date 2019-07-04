# Docker Image with NGINX + mod_pagespeed

[![CircleCI](https://circleci.com/gh/utensils/docker-nginx.svg?style=svg)](https://circleci.com/gh/utensils/docker-nginx)
[![Docker Automated build](https://img.shields.io/docker/automated/utensils/nginx.svg)](https://hub.docker.com/r/utensils/nginx/) [![Docker Pulls](https://img.shields.io/docker/pulls/utensils/nginx.svg)](https://hub.docker.com/r/utensils/nginx/) [![Docker Stars](https://img.shields.io/docker/stars/utensils/nginx.svg)](https://hub.docker.com/r/utensils/nginx/) [![](https://images.microbadger.com/badges/image/utensils/nginx.svg)](https://microbadger.com/images/utensils/nginx "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/version/utensils/nginx.svg)](https://microbadger.com/images/utensils/nginx "Get your own version badge on microbadger.com")  


## About

This is a Docker container for NGINX + [mod_pagespeed](https://developers.google.com/speed/pagespeed/module/). This container build is nearly identical to the official nginx [docker image](https://hub.docker.com/_/nginx), the only difference is the inclusion of the pagespeed module.  

## Available Docker Images


| Image Name            | Description                 |
| --------------------- | --------------------------- |
| utensils/nginx:latest | The latest release of nginx |
| utensils/nginx:stable | The stable release of nginx |
| utensils/nginx:1.17.1 | nginx 1.17.1                |
| utensils/nginx:1.16.0 | nginx 1.16.0                |
| utensils/nginx:1.15.8 | nginx 1.15.8                |


## Building

This build is driven by a `Makefile`, to build the latest image simply run:  
```shell
make
```

or to build all images/version run:  
```shell
make all
```