Pod::Spec.new do |s|
  s.name         = 'GSCSVSerialization'
  s.version      = '2.1.3'
  s.author       = 'GyazSquare'
  s.license      = { :type => 'MIT' }
  s.homepage     = 'https://github.com/GyazSquare/GSCSVSerialization'
  s.source       = { :git => 'https://github.com/GyazSquare/GSCSVSerialization.git', :tag => 'v2.1.3' }
  s.summary      = 'An Objective-C CSV parser for iOS, OS X, watchOS and tvOS.'
  s.ios.deployment_target = '5.0'
  s.osx.deployment_target = '10.6'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'
  s.requires_arc  = true
  s.source_files  = 'GSCSVSerialization/*.{h,m}'
end
