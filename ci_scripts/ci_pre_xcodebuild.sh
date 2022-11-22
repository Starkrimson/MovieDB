#! /bin/sh

/usr/libexec/PlistBuddy -c "Set :api_key ${API_KEY}" "$CI_WORKSPACE/Shared/Info.plist"