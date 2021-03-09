#
# Be sure to run `pod lib lint ApplozicCore.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
    s.name             = 'ApplozicCore'
    s.version          = '8.0.0'
    s.summary          = 'ApplozicCore pod'
    s.description      = <<-DESC
    The ApplozicCore SDK helps you build your own custom UI in your iOS app.
    DESC
    s.homepage         = 'https://github.com/AppLozic/Applozic-Chat-iOS-Framework'
    s.license = { :type => "BSD 3-Clause", :file => "LICENSE" }
    s.source           = { :git => 'https://github.com/AppLozic/Applozic-Chat-iOS-Framework.git', :tag => s.version.to_s }
    s.social_media_url = 'https://www.twitter.com/AppLozic'
    s.authors = { 'Applozic Inc.' => 'support@applozic.com' }
    s.swift_version = '5.0'
    s.ios.deployment_target = '10.0'
    s.source_files = 'ApplozicCore/**/*.{h,m,swift}'
    s.requires_arc = true
    s.resources = 'ApplozicCore/**/*.{xcassets,xcdatamodeld,json}'
    s.frameworks = "Foundation", "SystemConfiguration"
end