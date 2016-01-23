DOCKER_IMAGE_NAME=outcoldman/outcoldman.com
DOCKER_CONTAINER_NAME=outcoldman.com

docker-bower-build:
	@docker run --rm --volume $$(pwd):/outcoldman.com node:latest bash -c "(\
        npm install -g bower \
        && mkdir -p /tmp/outcoldman.com \
        && cd /tmp/outcoldman.com/ \
        && bower install --allow-root normalize-css#3.0.3 font-awesome#4.3.0 pygments#2.0.2 \
        && cp /tmp/outcoldman.com/bower_components/pygments/css/monokai.css               /outcoldman.com/css/syntax.css \
        && cp /tmp/outcoldman.com/bower_components/normalize-css/normalize.css            /outcoldman.com/css/normalize.css \
        && cp /tmp/outcoldman.com/bower_components/font-awesome/css/font-awesome.min.css  /outcoldman.com/css/font-awesome.min.css \
        && cp /tmp/outcoldman.com/bower_components/font-awesome/fonts/*                   /outcoldman.com/fonts/ \
        )"

docker-jekyll-pull:
	@docker pull jekyll/jekyll:2.5.3

docker-jekyll-local:
	docker run --rm -it --volume $$(pwd):/srv/jekyll --publish 4000:80 jekyll/jekyll:2.5.3 \
		jekyll build --draft --config _config.yml,_local_config.yml --watch

docker-jekyll-build:
	docker run --rm --volume $$(pwd):/srv/jekyll jekyll/jekyll:2.5.3 \
		jekyll build --config _config.yml

docker-nginx-build:
	@docker build -t $(DOCKER_IMAGE_NAME) --pull=true .

FILENAME:=_drafts/$$(echo "$(name)" | tr ' ' '-' | tr '[:upper:]' '[:lower:]').markdown
define DRAFT_YAML
---
layout: post
title: "$(name)"
categories: en
tags: []
---
endef
export DRAFT_YAML
draft:
	@echo $(FILENAME)
	@echo "$$DRAFT_YAML" > $(FILENAME)
	@vim $(FILENAME)

draft-list:
	@find ./_drafts -name "*.markdown" | nl

draft-publish:
	@find ./_drafts -name "*.markdown" | tail -n+$(draft) | head -n1 | xargs zsh -c 'mv $$0 ./_posts/en/$$(date "+%Y-%m-%d")-$${0:t}'
