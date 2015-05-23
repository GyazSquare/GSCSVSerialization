Pod::Spec.new do |s|
  s.name         = 'GSCSVSerialization'
  s.version      = '1.0.1'
  s.author       = 'GyazSquare'
  s.license      = { :type => 'MIT' }
  s.homepage     = 'https://github.com/GyazSquare/GSCSVSerialization'
  s.source       = { :git => 'https://github.com/GyazSquare/GSCSVSerialization.git', :tag => '1.0.1' }
  s.summary      = 'An Objective-C CSV parser for iOS and OS X.'
  s.ios.deployment_target = '5.0'
  s.osx.deployment_target = '10.6'
  s.requires_arc  = true
  s.source_files  = 'GSCSVSerialization/*.{h,m}'
end
