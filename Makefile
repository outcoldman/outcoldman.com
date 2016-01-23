DOCKER_IMAGE_NAME=outcoldman/outcoldman.com
DOCKER_CONTAINER_NAME=outcoldman.com
NODE_VERSION=4.2.6
JEKYLL_VERSION=3.0.2
FONT_AWESOME_VERSION=4.3.0
NORMALIZE_VERSION=3.0.3
PYGMENTS_VERSION=2.0.2

BOWER_CONTAINER_NAME=wwwoutcoldmancom_bowerbuild
JEKYLL_CONTAINER_NAME=wwwoutcoldmancom_jekyllbuild

docker-bower-build:
	@docker run -d \
		--name $(BOWER_CONTAINER_NAME) \
		--label wwwoutcoldmancom=build \
		node:$(NODE_VERSION) tail -F /var/log/syslog
	@docker exec $(BOWER_CONTAINER_NAME) \
		bash -c "(\
        npm install -g bower \
        && mkdir -p /usr/src/wwwoutcoldmancom \
        && cd /usr/src/wwwoutcoldmancom/ \
        && bower install --allow-root \
			normalize-css#$(NORMALIZE_VERSION) \
			font-awesome#$(FONT_AWESOME_VERSION) \
			pygments#$(PYGMENTS_VERSION) \
        )"
	docker cp $(BOWER_CONTAINER_NAME):'/usr/src/wwwoutcoldmancom/bower_components/pygments/css/monokai.css' 				./css/syntax.css
	docker cp $(BOWER_CONTAINER_NAME):'/usr/src/wwwoutcoldmancom/bower_components/normalize-css/normalize.css' 				./css/normalize.css
	docker cp $(BOWER_CONTAINER_NAME):'/usr/src/wwwoutcoldmancom/bower_components/font-awesome/css/font-awesome.min.css' 	./css/font-awesome.min.css
	docker cp $(BOWER_CONTAINER_NAME):'/usr/src/wwwoutcoldmancom/bower_components/font-awesome/fonts' 						./
	@docker kill $(BOWER_CONTAINER_NAME)
	@docker rm -v $(BOWER_CONTAINER_NAME)

docker-jekyll-local:
	@docker exec -it \
		--volume $$(pwd):/srv/jekyll \
		--publish 4000:80 \
		--env JEKYLL_ENV=development \
		jekyll/jekyll:$(JEKYLL_VERSION) \
		jekyll build --draft --config _config.yml,_local_config.yml --watch

docker-jekyll-build:
	@rm -fR ./_site/*
	@docker run -d \
		--name $(JEKYLL_CONTAINER_NAME) \
		--label wwwoutcoldmancom=build \
		--env JEKYLL_ENV=production \
		jekyll/jekyll:$(JEKYLL_VERSION) tail -F /var/log/syslog
	@docker exec $(JEKYLL_CONTAINER_NAME) mkdir -p /usr/src/wwwoutcoldmancom/
	@docker cp . $(JEKYLL_CONTAINER_NAME):/usr/src/wwwoutcoldmancom/
	docker exec \
		$(JEKYLL_CONTAINER_NAME) \
		bash -c "(\
			cd /usr/src/wwwoutcoldmancom/ \
			&& chown -R jekyll:jekyll /usr/src/wwwoutcoldmancom/ \
			&& JEKYLL_ENV=production jekyll build --config _config.yml \
		)"
	@docker cp $(JEKYLL_CONTAINER_NAME):'/usr/src/wwwoutcoldmancom/_site' .
	@docker kill $(JEKYLL_CONTAINER_NAME)
	@docker rm -v $(JEKYLL_CONTAINER_NAME)

docker-aws-deploy:
	@docker run --rm \
		--label wwwoutcoldmancom=build \
		--volume $$(pwd)/_site:/usr/src/www.outcoldman.com \
		--env AWS_ACCESS_KEY_ID=$${AWS_ACCESS_KEY_ID} \
		--env AWS_SECRET_ACCESS_KEY=$${AWS_SECRET_ACCESS_KEY} \
		--env AWS_DEFAULT_REGION=$${AWS_DEFAULT_REGION} \
		xueshanf/awscli aws s3 sync /usr/src/www.outcoldman.com s3://www.outcoldman.com --delete

docker-clean:
	-@docker kill $$(docker ps -q --filter=label=wwwoutcoldmancom=build) >/dev/null 2>&1
	-@docker rm -v $$(docker ps -aq --filter=label=wwwoutcoldmancom=build) >/dev/null 2>&1

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
