DOCKER_IMAGE_NAME=outcoldman/outcoldman.com
DOCKER_CONTAINER_NAME=outcoldman.com
NODE_VERSION=4.2.6
JEKYLL_VERSION=3.0.2
FONT_AWESOME_VERSION=4.3.0
NORMALIZE_VERSION=3.0.3
PYGMENTS_VERSION=2.0.2

docker-bower-build:
	@docker run --rm --volume $$(pwd):/outcoldman.com node:$(NODE_VERSION) bash -c "(\
        npm install -g bower \
        && mkdir -p /tmp/outcoldman.com \
        && cd /tmp/outcoldman.com/ \
        && bower install --allow-root \
			normalize-css#$(NORMALIZE_VERSION) \
			font-awesome#$(FONT_AWESOME_VERSION) \
			pygments#$(PYGMENTS_VERSION) \
        && cp /tmp/outcoldman.com/bower_components/pygments/css/monokai.css               /outcoldman.com/css/syntax.css \
        && cp /tmp/outcoldman.com/bower_components/normalize-css/normalize.css            /outcoldman.com/css/normalize.css \
        && cp /tmp/outcoldman.com/bower_components/font-awesome/css/font-awesome.min.css  /outcoldman.com/css/font-awesome.min.css \
        && cp /tmp/outcoldman.com/bower_components/font-awesome/fonts/*                   /outcoldman.com/fonts/ \
        )"

docker-jekyll-local:
	@docker run --rm -it \
		--volume $$(pwd):/srv/jekyll \
		--publish 4000:80 \
		--env JEKYLL_ENV=development \
		jekyll/jekyll:$(JEKYLL_VERSION) \
		jekyll build --draft --config _config.yml,_local_config.yml --watch

docker-jekyll-build:
	@docker run --rm \
		--volume $$(pwd):/srv/jekyll \
		--env JEKYLL_ENV=production \
		jekyll/jekyll:$(JEKYLL_VERSION) \
		jekyll build --config _config.yml

docker-aws-deploy:
	@docker run --rm \
		--volume $$(pwd)/_site:/usr/src/www.outcoldman.com \
		--env AWS_ACCESS_KEY_ID=$${AWS_ACCESS_KEY_ID} \
		--env AWS_SECRET_ACCESS_KEY=$${AWS_SECRET_ACCESS_KEY} \
		--env AWS_DEFAULT_REGION=$${AWS_DEFAULT_REGION} \
		xueshanf/awscli aws s3 sync /usr/src/www.outcoldman.com s3://www.outcoldman.com

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
