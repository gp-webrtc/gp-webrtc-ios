#!/bin/sh
#
# gp-webrtc-ios
# Copyright (c) 2024, Greg PFISTER. MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the “Software”), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

set -e

# General information
echo "===== App informations ========================================================="
echo "Building $CI_TEAM_ID.$CI_BUNDLE_ID on platform $CI_PRODUCT_PLATFORM using scheme $CI_XCODE_SCHEME"
echo "Commit $CI_COMMIT on branch $CI_BRANCH"

# If this is build from a tag
if [ -z $CI_TAG ]; then
    echo "No tag"
else
    APP_VERSION=`cat $CI_PRIMARY_REPOSITORY_PATH/gp-webrtc-ios.xcodeproj/project.pbxproj | grep -m1 'MARKETING_VERSION' | cut -d'=' -f2 | tr -d ';' | tr -d ' '`
    echo "App version $APP_VERSION (tag $CI_TAG)"
    if [ ! "$APP_VERSION" != "$CI_TAG" ]; then
        echo "App version doesn't match tag"
        exit 1
    fi
fi

# Install dependencies
echo "===== Dependencies ============================================================="
echo "Install SwiftFormat"
brew install swiftformat

# Mandatory files
echo "===== Firebase requirements ====================================================="
echo "OSKFirebaseEmulator.plist"
if [ -z $FIREBASE_GOOGLE_SERVICE ]; then
    echo "Ignoring GoogleService-Info.plist"
else
    echo "GoogleService-Info.plist"
    (cd $CI_PRIMARY_REPOSITORY_PATH/iOS/Resources && echo $FIREBASE_GOOGLE_SERVICE | base64 --decode > GoogleService-Info.plist)
fi
