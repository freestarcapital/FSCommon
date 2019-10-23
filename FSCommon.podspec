Pod::Spec.new do |s|
  s.name         = "FSCommon"
  s.version      = "1.1.1"
  s.summary      = "Common module for Freestar Ad SDK."
  s.description  = "A library consisting of common frameworks used in the Freestar SDK."
  s.homepage     = "https://freestar.io"
  s.license      = "MIT"
  s.author   = { "Freestar Mobile Engineering" => "sdk@freestar.io" }
  s.source       = { :git => "https://github.com/freestarcapital/FSCommon.git", :tag => s.version.to_s }
  s.ios.deployment_target  = "9.0"
  s.ios.vendored_frameworks = "build/FSCommon.framework"
end
