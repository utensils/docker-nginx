#!/usr/bin/make -f

NAME=utensils/nginx
TEMPLATE=Dockerfile.template
SHELL=/usr/bin/env bash
.DEFAULT_GOAL := 1.17.1

.PHONY: all
all: 1.17.1 1.16.0 1.15.8

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

.PHONY: 1.16.0
1.16.0:
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
	docker tag $(NAME):$(@) $(NAME):stable

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
test: test-1.17.1 test-1.16.0 test-1.15.8

.PHONY: test-1.17.1
test-1.17.1:
	docker run -t utensils/nginx:1.17.1 nginx -V | grep "nginx/1.17.1"
	docker run utensils/nginx:1.17.1 nginx -t

.PHONY: test-1.16.0
test-1.16.0:
	docker run -t utensils/nginx:1.16.0 nginx -V | grep "nginx/1.16.0"
	docker run utensils/nginx:1.16.0 nginx -t

.PHONY: test.15.8
test-1.15.8:
	docker run -t utensils/nginx:1.15.8 nginx -V | grep "nginx/1.15.8"
	docker run utensils/nginx:1.15.8 nginx -t

.PHONY: push
push:
	docker push $(NAME):1.17.1
	docker push $(NAME):1.16.0
	docker push $(NAME):1.15.8
	docker push $(NAME):latest
	docker push $(NAME):stable

.PHONY: clean
clean:
	rm -rf 1.17.1
	rm -rf 1.16.0
	rm -rf 1.15.8
