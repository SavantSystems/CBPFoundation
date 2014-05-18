Pod::Spec.new do |s|
  s.name         = "CBPFoundation"
  s.version      = "0.0.1"
  s.summary      = "Useful mapping/filtering/threading foundation extensions."
  s.homepage     = "https://github.com/noremac/CBPFoundation"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = "Cameron Pulsford"
  s.platform     = :ios, "5.0"
  s.source       = { :git => "https://github.com/noremac/CBPFoundation.git", :tag => "0.0.1" }
  s.source_files = 'CBPFoundation/**/*.{h,m}'
  s.requires_arc = true
end
