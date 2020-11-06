#!/bin/zsh


# ------------------------------------------------------------------------------
SCHEME_NAME=OneAtlasSampleApp
WORKSPACE_FILE=OneAtlasSampleApp.xcworkspace
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
echo "ℹ️  Cleanup..."
rm -rf ./DerivedData
rm -rf ./Pods
rm -rf $WORKSPACE_FILE
rm Podfile.lock
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install the Pods for the framework target
echo
echo "ℹ️  Installing required Pods..."
export LANG=en_US.UTF-8
pod install
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Build for device (arm64)
echo
echo "ℹ️  Building for device..."
xcodebuild build -workspace $WORKSPACE_FILE \
               	 -scheme $SCHEME_NAME \
                 -destination="iOS" \
                 -configuration Release \
                 -sdk iphoneos
echo
if [[ $PIPESTATUS == 0 ]]; then
  echo "✅ Device build passed."
else
  echo "🔴 Device build failed !"
  exit 1
fi
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Build for simulator (x64)
echo
echo "ℹ️  Building for simulator..."
xcodebuild build -workspace $WORKSPACE_FILE \
                 -scheme $SCHEME_NAME \
                 -destination="iOS Simulator" \
                 -configuration Release \
                 -sdk iphonesimulator \
				 VALID_ARCHS="x86_64" \

echo
if [[ $PIPESTATUS == 0 ]]; then
  echo "✅ Simulator build passed."
else
  echo "🔴 Simulator build failed !"
  exit 1
fi
# ------------------------------------------------------------------------------


echo 
echo "✅ Done !"
exit 0

