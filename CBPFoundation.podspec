Pod::Spec.new do |s|
  s.name         = "CBPFoundation"
  s.version      = "0.0.4"
  s.summary      = "Useful mapping/filtering/threading foundation extensions."
  s.homepage     = "https://github.com/noremac/CBPFoundation"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = "Cameron Pulsford"
  s.platform     = :ios, "5.0"
  s.source       = { :git => "https://github.com/noremac/CBPFoundation.git", :tag => "0.0.4" }
  s.source_files = 'CBPFoundation/**/*.{h,m}'
  s.requires_arc = true
  s.subspec "Threading" do |sp|
    sp.source_files = "CBPFoundation/CBPSynchronizationPrimitives.h", "CBPFoundation/CBPDeref.{h,m}", "CBPFoundation/NSThread+CBPExtensions.{h,m}", "CBPFoundation/CBPPromise.{h,m}", "CBPFoundation/CBPFuture.{h,m}", "CBPFoundation/CBPDerefSubclass.h"
  end
end

