#! /bin/sh

# 安装 swiftlint
brew install swiftlint

# 设置 api key
/usr/libexec/PlistBuddy -c "Set :api_key ${API_KEY}" "$CI_WORKSPACE/Shared/Info.plist"