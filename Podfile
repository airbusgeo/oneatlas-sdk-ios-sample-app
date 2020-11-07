# ==============================================================================
# OneAtlasData sample app Podfile
# ==============================================================================
platform :ios, '12.0'


# ==============================================================================
# Pods
# ==============================================================================
target 'OneAtlasSampleApp' do
  use_frameworks!

  pod 'OneAtlas', '~> 1.4.3'

  # Mapbox
  pod 'MapboxGeocoder.swift', '~> 0.12.0'
  pod 'Mapbox-iOS-SDK', '~> 5.9.0'
  
  # nice notifications
  pod 'Toast-Swift', '~> 5.0.1' # MIT
  
  # map view drawers
  pod 'Pulley', '~> 2.8.4' # MIT
  
  # used by 'do not show' button
  pod 'GDCheckbox' # MIT
  pod 'M13Checkbox', '~> 3.4.0' # MIT
  
  # streaming for images
  pod 'SDWebImage', '~> 5.9.4' # MIT
  
  # used for 'xx days/minutes/seconds ago' strings
  pod 'DateToolsSwift', '~> 5.0.0' # MIT

  # used to select a date in filters
  pod 'RMDateSelectionViewController', '~> 2.3.1' # MIT
end


# ==============================================================================
# Post-install customization:
# - suppress "IPHONEOS_DEPLOYMENT_TARGET is set to 8.0" warnings
# - do not build for arm64/simulator
# ==============================================================================
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      config.build_settings['IPHONESIMULATOR_DEPLOYMENT_TARGET'] = '12.0'
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
  end
end
