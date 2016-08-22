Pod::Spec.new do |s|
  s.name         = "INSPersistentContainer"
  s.version      = "1.0.2"
  s.summary      = "INSPersistentContainer"
  s.license      = 'MIT'
  s.homepage     = "http://inspace.io"
  s.author       = { "Michał Zaborowski" => "m1entus@gmail.com" }
  s.source       = { :git => "https://github.com/inspace-io/INSPersistentContainer.git", :tag => "1.0.2" }
  s.requires_arc = true

  s.ios.deployment_target = '8.0'

  s.ios.source_files = 'Source/Objective-C/**/*.{h,m}'

  s.frameworks = 'CoreData'
end
