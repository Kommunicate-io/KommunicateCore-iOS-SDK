#
# Be sure to run `pod lib lint KommunicateCore-iOS-SDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'KommunicateCore-iOS-SDK'
  s.version          = '0.0.1'
  s.summary          = 'KommunicateCore-iOS SDK pod'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
The KommunicateCore-iOS SDK helps you build your own custom UI in your iOS app
                       DESC

  s.homepage         = 'https://github.com/Kommunicate-io/KommunicateCore-iOS-SDK'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'BSD 3-Clause', :file => 'LICENSE' }
  s.author           = { 'Applozic Inc.' => 'support@applozic.com' }
  s.source           = { :git => 'https://github.com/Kommunicate-io/KommunicateCore-iOS-SDK.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.swift_version = '5.0'
  s.ios.deployment_target = '12.0'

  s.source_files = 'KommunicateCore-iOS-SDK/Classes/**/*'
  s.requires_arc = true
  s.resources = 'ApplozicCore/**/*.{xcassets,xcdatamodeld,json}'
  s.frameworks = "Foundation", "SystemConfiguration"

  # s.resource_bundles = {
  #   'KommunicateCore-iOS-SDK' => ['KommunicateCore-iOS-SDK/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
