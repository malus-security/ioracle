#!/bin/bash

# Prerequisites: 
# brew: /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
# node: brew install node
# ios-deploy: npm install -g ios-deploy

APP_NAME=$1

#Build the app
APP_NAME=`xcodebuild -project "$APP_NAME/CallingMethodsApp.xcodeproj" -scheme CallingMethodsApp build | grep builtin-validationUtility | xargs | cut -d " " -f2`

# Run the app (I only have 1 device connected; haven't specified where to run)
ios-deploy --debug --bundle $APP_NAME

