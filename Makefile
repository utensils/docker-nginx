#!/usr/bin/make -f

NAME=utensils/nginx
TEMPLATE=Dockerfile.template
SHELL=/usr/bin/env bash
.DEFAULT_GOAL := 1.17.1

.PHONY: all
all: 1.17.1 1.15.8

.PHONY: 1.17.1
1.17.1:
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

.PHONY: 1.15.8
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

.PHONY: test
test: test-1.17.1 test-1.15.8

.PHONY: test-1.17.1
test-1.17.1:
	if [ "`docker run utensils/nginx:1.17.1 cat /etc/alpine-release`" != "3.8.4" ]; then exit 1;fi
	docker run utensils/nginx nginx -t

.PHONY: test.15.8
test-1.15.8:
	if [ "`docker run utensils/nginx:1.15.8 cat /etc/alpine-release`" != "3.8.4" ]; then exit 1;fi
	docker run utensils/nginx nginx -t

.PHONY: push
push:
	docker push $(NAME):1.17.1
	docker push $(NAME):1.15.8
	docker push $(NAME):latest

.PHONY: clean
clean:
	rm -rf 1.17.1
	rm -rf 1.15.8
