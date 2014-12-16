Pod::Spec.new do |s|
  s.name         = "RedditKit"
  s.version      = "0.1.1"
  s.summary      = "A simple Objective-C wrapper for the Reddit API."
  s.homepage     = "https://github.com/rdougan/RedditKit"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Robert Dougan" => "rdougan@me.com" }
  s.source       = { :git => "https://github.com/rdougan/RedditKit.git", :tag => "0.1.1" }
  s.source_files = 'RedditKit', 'RedditKit/**/*.{h,m}'
  s.framework  = 'CoreData'
  s.requires_arc = true
  s.osx.deployment_target = '10.7'
  s.dependency 'AFNetworking', '~> 1.1.0'
  s.dependency 'SSKeychain', '~> 0.1.4'
  s.dependency 'SSDataKit', { :git => 'git://github.com/rdougan/ssdatakit.git', :commit => '11292399e2dad2f6c65649cb99da89b545b4b92c' }
end
