#!/bin/bash

# FIXME:  will not work with camel-case names (see _init_routes)
# NOTE:  override _init_default_gems to install preferred gems
# NOTE:  override $SWEET_DB

export APP_API=api
export APP_WEB=web
export APP_SRV=services
export APP_ADM=admin
export APP_BIN=bin
export SWEET_DB=postgresql

export RAILSWEET_BIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export RAILSWEET_BASE_DIR=$RAILSWEET_BIN_DIR/..

export DEVMODE=0

function _init_railsapps {
    echo "*** creating rails plugin"
    rails plugin new $ENGINE --mountable --database=$SWEET_DB
    sed -i -e "s/TODO: Your name/$USER/g" $APP_DIR/$ENGINE/$APP.gemspec
    sed -i -e "s/TODO: Your email/$USER@example.com/g" $APP_DIR/$ENGINE/$APP.gemspec
    sed -i -e "s/TODO: //g" $APP_DIR/$ENGINE/$APP.gemspec
    sed -i -e "s/TODO/http:\/\/example.com/g" $APP_DIR/$ENGINE/$ENGINE.gemspec
    # FIXME:  ensure this function is defined, warned if not
    eval $APP'_init_default_gems'

    echo "*** creating $APP_API"
    rails new $APP_API --database=$SWEET_DB

     if [[ "x$DEVMODE" != "x1" ]]; then
	 echo "*** creating $APP_WEB"
	 rails new $APP_WEB --database=$SWEET_DB
	 echo "*** creating $APP_SRV"
	 rails new $APP_SRV --database=$SWEET_DB
	 echo "*** creating $APP_ADM"
	 rails new $APP_ADM --database=$SWEET_DB
     fi
}

function _init_databaseyml {
    pushd $APP_API/config
    mv database.yml ../../$ENGINE/config
    ln -s ../../$ENGINE/config/database.yml .
    if [[ "x$DEVMODE" != "x1" ]]; then
	cd ../../$APP_WEB/config
	rm database.yml
	ln -s ../../$ENGINE/config/database.yml .
	cd ../../$APP_SRV/config
	rm database.yml
	ln -s ../../$ENGINE/config/database.yml .
	cd ../../$APP_ADM/config
	rm database.yml
	ln -s ../../$ENGINE/config/database.yml .
     fi
     popd
}

function _init_bundle_install {
    echo "** $APP_DIR/$ENGINE; bundle install"
    cd  $APP_DIR/$ENGINE; bundle install

    echo "** $APP_DIR/$APP_API; bundle install"
    cd  $APP_DIR/$APP_API; bundle install

    if [[ "x$DEVMODE" != "x1" ]]; then
	echo "** $APP_DIR/$APP_WEB; bundle install"
	cd  $APP_DIR/$APP_WEB; bundle install
	echo "** $APP_DIR/$APP_SRV; bundle install"
	cd  $APP_DIR/$APP_SRV; bundle install
	echo "** $APP_DIR/$APP_ADM; bundle install"
	cd  $APP_DIR/$APP_ADM; bundle install
    fi
    
    # echo "$APP_DIR; rails generate devise:install"
    # cd $APP_DIR/$ENGINE; rails generate devise:install
}

function _init_gemfiles {
    echo "gem '$ENGINE', path: '../$ENGINE'" >> $APP_DIR/$APP_API/Gemfile
    if [[ "x$DEVMODE" != "x1" ]]; then
	echo "gem '$ENGINE', path: '../$ENGINE'" >> $APP_DIR/$APP_WEB/Gemfile
	echo "gem '$ENGINE', path: '../$ENGINE'" >> $APP_DIR/$APP_SRV/Gemfile
	echo "gem '$ENGINE', path: '../$ENGINE'" >> $APP_DIR/$APP_ADM/Gemfile

	echo "gem 'activeadmin', github: 'gregbell/active_admin', branch: 'rails4'" >> $APP_DIR/$APP_ADM/Gemfile
	
	eval $APP'_did_init_gemfiles'  # FIXME:  check if function exists
    fi
    
}

function _init_routes {
    export NG_NAME=`echo "$(echo "$ENGINE" | sed 's/.*/\u&/')"`
    sed -i -e "2 i mount "$NG_NAME"::Engine, at: '/'" $APP_DIR/$APP_API/config/routes.rb

    if [[ "x$DEVMODE" != "x1" ]]; then
	sed -i -e "2 i mount "$NG_NAME"::Engine, at: '/'" $APP_DIR/$APP_WEB/config/routes.rb
	sed -i -e "2 i mount "$NG_NAME"::Engine, at: '/'" $APP_DIR/$APP_SRV/config/routes.rb
	sed -i -e "2 i mount "$NG_NAME"::Engine, at: '/'" $APP_DIR/$APP_ADM/config/routes.rb

	sed -i -e "3 i devise_for :admin_users, ActiveAdmin::Devise.config" $APP_DIR/$APP_ADM/config/routes.rb
	sed -i -e "4 i ActiveAdmin.routes(self)" $APP_DIR/$APP_ADM/config/routes.rb
    fi
}

function app_sweet_setup {
    # FIXME:  check for APP argument, check for definition of $APP_init_default_gems
    # FIXME:  add dry-run option
    # FIXME:  reimplement with thor

    export APP=$1
    export ENGINE=$APP
    export APP_DIR=`pwd`/$APP
    source `pwd`/bin/$APP.bash  # default value, check for function arg

    mkdir $APP_DIR
    pushd $APP_DIR

    echo "*** init rails apps"
    _init_railsapps

    echo "*** init database yml"
    _init_databaseyml

    echo "*** init routes"
    _init_routes

    echo "*** init gemfiles"
    _init_gemfiles

    echo "*** init bundle install"
    _init_bundle_install

    popd
}
