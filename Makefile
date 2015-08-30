installtools:
	@npm install bower
	@rbenv install -s
	@rbenv exec gem install bundle

updateclientdeps:
	@bower install
	@cp bower_components/pygments/css/monokai.css css/syntax.css
	@cp bower_components/normalize-css/normalize.css css/normalize.css
	@cp bower_components/font-awesome/css/font-awesome.min.css css/font-awesome.min.css
	@cp bower_components/font-awesome/fonts/* fonts/

deps:
	@rbenv exec bundle install
	@rbenv rehash

build-local:
	@rbenv exec bundle exec jekyll build --draft --config=_config.yml,_local_config.yml

build-staging:
	@rbenv exec bundle exec jekyll build --draft --config=_config.yml,_staging_config.yml

build-production:
	@rbenv exec bundle exec jekyll build --config _config.yml

server-local:
	@rbenv exec bundle exec jekyll server --watch --draft --config=_config.yml,_local_config.yml

predeploy-fix-permissions:
	@find ./_site/ -type f -exec chmod 644 {} +
	@find ./_site/ -type d -exec chmod 755 {} +

deploy-staging: predeploy-fix-permissions
	@rsync -r --rsh="ssh -p9022" --checksum --delete-after --delete-excluded --numeric-ids ./_site/ root@outcoldbuntu:

deploy-production: predeploy-fix-permissions
	@rsync -r --rsh="ssh -p9022" --checksum --delete-after --delete-excluded --numeric-ids ./_site/ root@outcoldman.com:
