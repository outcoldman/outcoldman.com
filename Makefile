deps:
	@npm install bower
	@rbenv install -s
	@rbenv exec gem install bundle
	@bower install
	@rbenv exec bundle install
	@rbenv rehash
	@cp bower_components/pygments/css/monokai.css css/syntax.css
	@cp bower_components/normalize-css/normalize.css css/normalize.css
	@cp bower_components/font-awesome/css/font-awesome.min.css css/font-awesome.min.css
	@cp bower_components/font-awesome/fonts/* fonts/

build:
	@rbenv exec bundle exec jekyll build

local:
	@rbenv exec bundle exec jekyll server --watch --config _local_config.yml
