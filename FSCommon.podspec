Pod::Spec.new do |s|
  s.name         = "FSCommon"
  s.version      = "0.0.1"
  s.summary      = "A library consisting of common frameworks used in the Freestar SDK."
  s.description  = "A library consisting of common frameworks used in the Freestar SDK."
  s.homepage     = "https://freestar.io"
  s.license      = "MIT"
  s.author   = { "Freestar Mobile Engineering" => "sdk@freestar.io" }
  s.source       = { :git => "https://github.com/freestarcapital/FSCommon.git", :tag => s.version.to_s }
  s.requires_arc = true
  s.source_files = "Source/*.{h,m}"
  s.ios.deployment_target  = "8.0"
end
