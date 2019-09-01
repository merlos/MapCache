#
# Be sure to run `pod lib lint MapCache.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MapCache'
  s.version          = '0.5.1'
  s.summary          = 'Map caching for iOS. Support offline maps in your app.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Map cache for iOS applications for offline maps. Download tiles in disk as user browsers the map or download an area for supporting offline maps.
DESC

  s.homepage         = 'https://github.com/merlos/MapCache'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'merlos' => 'merlos@users.noreply.github.com' }
  s.source           = { :git => 'https://github.com/merlos/MapCache.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/merlos'

  s.ios.deployment_target = '8.0'
  s.swift_version = '5.0'
  s.source_files = 'MapCache/Classes/**/*'
  s.platform = :ios, '8.0'
  # s.resource_bundles = {
  #   'MapCache' => ['MapCache/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
   s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
