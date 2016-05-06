Pod::Spec.new do |s|
  s.name         = "MUPullToRefresh"
  s.version      = "1.0.1"
  s.license      = "MIT"
  s.summary      = "pull-to-refresh & infinite scrolling."
  s.homepage     = "https://github.com/muer2000/MUPullToRefresh"
  s.author       = { "muer" => "muer2000@gmail.com" }
  s.platform     = :ios, "5.0"
  s.ios.deployment_target = "5.0"
  s.source       = { :git => "https://github.com/muer2000/MUPullToRefresh.git", :tag => s.version }
  s.source_files = "MUPullToRefresh/MUPullToRefresh.{h,m}"
  s.requires_arc = true
  s.resource     = "MUPullToRefresh/MUPullToRefresh.bundle"
end
