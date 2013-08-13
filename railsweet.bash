#!/bin/bash

# FIXME:  will not work with camel-case names (see _init_routes)
# NOTE:  override _init_default_gems to install preferred gems
# NOTE:  override $SWEET_DB

export APP_API=api
export APP_WEB=web
export APP_SRV=services
export APP_ADM=admin
export SWEET_DB=postgresql

export RAILSWEET_BIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export RAILSWEET_BASE_DIR=$RAILSWEET_BIN_DIR/..

function _init_railsapps {
     rails plugin new $APP --mountable --database=$SWEET_DB
     rails new $APP_API --database=$SWEET_DB
     rails new $APP_WEB --database=$SWEET_DB
     rails new $APP_SRV --database=$SWEET_DB
     rails new $APP_ADM --database=$SWEET_DB
}

function _init_databaseyml {
     pushd $APP_API/config
     mv database.yml ../../$APP/config
     ln -s ../../$APP/config/database.yml .
     cd ../../$APP_WEB/config
     rm database.yml
     ln -s ../../$APP/config/database.yml .
     cd ../../$APP_SRV/config
     rm database.yml
     ln -s ../../$APP/config/database.yml .
     cd ../../$APP_ADM/config
     rm database.yml
     ln -s ../../$APP/config/database.yml .
     popd
}

function _init_bundle_install {
    echo "** $APP_DIR/$APP; bundle install"
    cd  $APP_DIR/$APP; bundle install
    echo "** $APP_DIR/$APP_API; bundle install"
    cd  $APP_DIR/$APP_API; bundle install
    echo "** $APP_DIR/$APP_WEB; bundle install"
    cd  $APP_DIR/$APP_WEB; bundle install
    echo "** $APP_DIR/$APP_SRV; bundle install"
    cd  $APP_DIR/$APP_SRV; bundle install
    echo "** $APP_DIR/$APP_ADM; bundle install"
    cd  $APP_DIR/$APP_ADM; bundle install
    
    # echo "$APP_DIR; rails generate devise:install"
    # cd $APP_DIR/$APP; rails generate devise:install
}

function _init_gemfiles {
    echo "gem '$APP', path: '../$APP'" >> $APP_DIR/$APP_API/Gemfile
    echo "gem '$APP', path: '../$APP'" >> $APP_DIR/$APP_WEB/Gemfile
    echo "gem '$APP', path: '../$APP'" >> $APP_DIR/$APP_SRV/Gemfile
    echo "gem '$APP', path: '../$APP'" >> $APP_DIR/$APP_ADM/Gemfile
    $APP_init_default_gems $APP
}

function _init_routes {
    export NG_NAME=`echo "$(echo "$APP" | sed 's/.*/\u&/')"`
    sed -i -e "2 i mount "$NG_NAME"::Engine, at: '/'" $APP_DIR/$APP_API/config/routes.rb
    sed -i -e "2 i mount "$NG_NAME"::Engine, at: '/'" $APP_DIR/$APP_WEB/config/routes.rb
    sed -i -e "2 i mount "$NG_NAME"::Engine, at: '/'" $APP_DIR/$APP_SRV/config/routes.rb
    sed -i -e "2 i mount "$NG_NAME"::Engine, at: '/'" $APP_DIR/$APP_ADM/config/routes.rb
}

function app_sweet_setup {
    export APP=$1
    export APP_DIR=$dcbin/../$APP
    source $dcbin/$APP.bash

    mkdir $APP_DIR
    pushd $APP_DIR
    echo "*** init rails apps"
    _init_railsapps $APP
    echo "*** init database yml"
    _init_databaseyml $APP
    echo "*** init routes"
    _init_routes $APP
    echo "*** init gemfiles"
    _init_gemfiles $APP
    echo "*** init bundle install"
    _init_bundle_install $APP
    popd
}
