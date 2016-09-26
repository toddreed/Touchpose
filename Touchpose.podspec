Pod::Spec.new do |s|
  s.name     = 'Touchpose'
  s.version  = '2.0.0-beta.1'
  s.license  =  { :type => 'Apache', :file => 'LICENSE.txt' }
  s.summary  = 'Touchposé is a set of classes for iOS that renders screen touches when a device is connected to a mirrored display.'
  s.homepage = 'http://github.com/toddreed/Touchpose'
  s.author   = { 'Todd Reed' => 'todd@toddreed.name' }
  s.source   = { :git => 'https://github.com/toddreed/Touchpose.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.platform = :ios
  s.source_files = 'Pod/Source/**/*.{h,m}'
  s.frameworks = 'QuartzCore'
end
