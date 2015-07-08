deps:
	bower install
	bundle install
	cp bower_components/pygments/css/monokai.css css/syntax.css
	cp bower_components/normalize-css/normalize.css css/normalize.css
	cp bower_components/font-awesome/css/font-awesome.min.css css/font-awesome.min.css
	cp bower_components/font-awesome/fonts/* fonts/

build:
	bundle exec jekyll build

local:
	bundle exec jekyll server --watch --config _local_config.yml
