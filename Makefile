#!/usr/bin/make -f

NAME=jamesbrink/nginx
TEMPLATE=Dockerfile.template
SHELL=/usr/bin/env bash
.PHONY: test all clean 1.15.8
.DEFAULT_GOAL := 1.15.8

all: 1.15.8

1.15.8:
	mkdir -p $(@)
	cp -rp runtime-assets $(@)
	cp -rp build-assets $(@)
	cp -rp hooks $(@)
	cp Dockerfile.template $(@)/Dockerfile
	cp .dockerignore $(@)/.dockerignore
	sed -i -r 's/ARG NGINX_VERSION.*/ARG NGINX_VERSION="$(@)"/g' $(@)/Dockerfile
	cd $(@) && docker build --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
             --build-arg VCS_REF=`git rev-parse --short HEAD` \
             -t $(NAME):$(@) .
	docker tag $(NAME):$(@) $(NAME):latest

test: test-1.15.8

test-1.15.8:
	if [ "`docker run jamesbrink/nginx cat /etc/alpine-release`" != "3.8.1" ]; then exit 1;fi

clean:
	rm -rf 1.15.8
