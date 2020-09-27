#
# MapCache
#
# MIT License
# Copyright (c) 2019-2020 Juan M. Merlos @merlos
#
# Be sure to run `pod lib lint MapCache.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MapCache'
  s.version          = '0.8.0'
  s.summary          = 'Map caching for iOS. Support offline maps in your app.'
  s.description      = <<-DESC
Cache for iOS applications for supporting offline tile maps. Downloads and keeps tiles in disk as user browses the map. Also, it can download a complete area at all different zoom levels for a complete offline experience (beta).
DESC

  s.homepage         = 'https://github.com/merlos/MapCache'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'merlos' => 'merlos@users.noreply.github.com' }
  s.source           = { :git => 'https://github.com/merlos/MapCache.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/merlos'

  s.swift_version = '5.0'
  s.source_files = 'MapCache/Classes/**/*'
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  # s.resource_bundles = {
  #   'MapCache' => ['MapCache/Assets/*.png']
  # }
   s.frameworks = 'Foundation', 'MapKit'
end
