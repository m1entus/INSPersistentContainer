Pod::Spec.new do |s|
  s.name         = "INSPersistentContainer-Swift"
  s.version      = "1.0.1"
  s.summary      = "INSPersistentContainer-Swift"
  s.license      = 'MIT'
  s.homepage     = "http://inspace.io"
  s.author       = { "Michał Zaborowski" => "m1entus@gmail.com" }
  s.source       = { :git => "https://github.com/inspace-io/INSPersistentContainer.git", :tag => "1.0.1" }
  s.requires_arc = true

  s.ios.deployment_target = '8.0'

  s.ios.source_files = 'Source/Swift/**/*.{h,m}'

  s.frameworks = 'CoreData'
end
