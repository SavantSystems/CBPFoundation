Pod::Spec.new do |s|
  s.name         = "CBPFoundation"
  s.version      = "1.0.0"
  s.summary      = "Useful mapping/filtering/threading foundation extensions."
  s.homepage     = "https://github.com/noremac/CBPFoundation"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = "Cameron Pulsford"
  s.platform     = :ios, "5.0"
  s.source       = { :git => "https://github.com/noremac/CBPFoundation.git", :tag => "1.0.0" }
  s.source_files = 'CBPFoundation/**/*.{h,m}'
  s.requires_arc = true
  s.subspec "Threading" do |sp|
    sp.source_files = "CBPFoundation/CBPDeref.{h,m}", "CBPFoundation/CBPDerefSubclass.h", "CBPFoundation/NSThread+CBPExtensions.{h,m}", "CBPFoundation/CBPPromise.{h,m}", "CBPFoundation/CBPFuture.{h,m}"
  end
end

