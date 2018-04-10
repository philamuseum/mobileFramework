# This file allows you to install the mobileFramework with CocoaPods.
# For more information on CocoaPods see: https://guides.cocoapods.org/using/getting-started.html
Pod::Spec.new do |s|
  s.name             = "PMAMobileFramework"
  s.version          = "1.0"
  s.summary          = "A collection of utilities which we found to be repeated across multiple museum-related apps"
  s.homepage         = "https://github.com/philamuseum/mobileFramework"
  s.author           = { "Peter Alt" => "peter.alt@philamuseum.org" }
  s.source           = { git: "git@github.com:philamuseum/mobileFramework.git" }
  s.ios.deployment_target = '10.0'
  s.requires_arc = true
  s.ios.source_files = 'mobileFramework/**/*.swift'
end
