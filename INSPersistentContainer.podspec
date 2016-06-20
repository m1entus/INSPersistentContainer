Pod::Spec.new do |s|
  s.name         = "INSPersistentContainer"
  s.version      = "1.0.0"
  s.summary      = "INSPersistentContainer"
  s.license      = 'MIT'
  s.homepage     = "http://inspace.io"
  s.author       = { "Michał Zaborowski" => "m1entus@gmail.com" }
  s.source       = { :git => "https://github.com/inspace-io/INSPersistentContainer.git", :tag => "1.0.0" }
  s.requires_arc = true

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'

  s.ios.source_files = 'Source/**/*.{h,m}'
  s.osx.source_files = 'Source/**/*.{h,m}'
  s.tvos.source_files = 'Source/**/*.{h,m}'
  s.frameworks = 'CoreData'
end
