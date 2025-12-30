#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint klc_klaviyo_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'klc_klaviyo_flutter'
  s.version          = '0.0.1'
  s.summary          = 'Klaviyo Flutter Plugin for iOS and Android'
  s.description      = <<-DESC
A Flutter plugin for integrating Klaviyo SDK for marketing automation,
push notifications, and user tracking.
                       DESC
  s.homepage         = 'https://github.com/020996/klc_klaviyo-flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Name' => 'diepmac020996@gmail' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  
  # Dependencies
  s.dependency 'Flutter'
  s.dependency 'KlaviyoSwift', '~> 5.1.1'
  s.dependency 'KlaviyoForms', '~> 5.1.1'
  
  s.platform         = :ios, '13.0'
  s.swift_version    = '5.0'
  
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES', 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' 
  }
end