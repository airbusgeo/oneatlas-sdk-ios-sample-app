# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'
use_frameworks!

plugin 'cocoapods-art', :sources => [
  'cocoa-local'
]
source 'https://cdn.cocoapods.org'

target 'OneAtlasSampleApp' do

  pod 'OneAtlas', '~> 1.4.3'

  # Mapbox
  pod 'MapboxGeocoder.swift'
  pod 'Mapbox-iOS-SDK', '~> 5.9.0'
  
  # nice notifications
  pod 'Toast-Swift' # MIT
  
  # map view drawers
  pod 'Pulley', '~> 2.8.4' # MIT
  
  # used by 'do not show' button
  pod 'GDCheckbox' # MIT
  
  # streaming for images
  pod 'SDWebImage' # MIT
  
  # used for 'xx days/minutes/seconds ago' strings
  pod 'DateToolsSwift' # MIT

  # used to select a date in filters
  pod 'RMDateSelectionViewController', '~> 2.3.1' # MIT
end

post_install do |installer|
  installer.pods_project.targets.each do |target|

    # suppress "IPHONEOS_DEPLOYMENT_TARGET is set to 8.0" warnings
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      config.build_settings['IPHONESIMULATOR_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
