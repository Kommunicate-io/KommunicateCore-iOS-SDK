Pod::Spec.new do |s|
  s.name             = 'KommunicateCore-iOS-SDK'
  s.version          = '0.0.1'
  s.summary          = 'KommunicateCore-iOS SDK pod'
  s.description      = <<-DESC
The KommunicateCore-iOS SDK helps you build your own custom UI in your iOS app
                       DESC
  s.homepage         = 'https://github.com/Kommunicate-io/KommunicateCore-iOS-SDK'
  s.license          = { :type => 'BSD 3-Clause', :file => 'LICENSE' }
  s.author           = { 'Kommunicate' => 'team.engineering@kommunicate.io' }
  s.source           = { :git => 'https://github.com/Kommunicate-io/KommunicateCore-iOS-SDK.git', :tag => s.version.to_s }
  s.swift_version = '5.0'
  s.ios.deployment_target = '12.0'
  s.source_files = 'Sources/KommunicateCore-iOS-SDK/Classes/**/*.{h,m,swift}'
  s.requires_arc = true
  s.resources = 'Sources/KommunicateCore-iOS-SDK/**/*.{xcassets,xcdatamodeld,json}'
  s.frameworks = "Foundation", "SystemConfiguration"
end
