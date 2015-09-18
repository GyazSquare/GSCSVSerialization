Pod::Spec.new do |s|
  s.name         = 'GSCSVSerialization'
  s.version      = '2.1.1'
  s.author       = 'GyazSquare'
  s.license      = { :type => 'MIT' }
  s.homepage     = 'https://github.com/GyazSquare/GSCSVSerialization'
  s.source       = { :git => 'https://github.com/GyazSquare/GSCSVSerialization.git', :tag => '2.1.1' }
  s.summary      = 'An Objective-C CSV parser for iOS, OS X and watchOS.'
  s.ios.deployment_target = '5.0'
  s.osx.deployment_target = '10.6'
  s.watchos.deployment_target = '2.0'
  s.requires_arc  = true
  s.source_files  = 'GSCSVSerialization/*.{h,m}'
end
