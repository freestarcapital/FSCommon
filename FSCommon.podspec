Pod::Spec.new do |s|
  s.name         = "FSCommon"
  s.version      = "#{version}#"
  s.summary      = "Common module for Freestar Ad SDK."
  s.description  = "A library consisting of common frameworks used in the Freestar SDK."
  s.homepage     = "https://freestar.io"
  s.license      = "MIT"
  s.author       = { "Freestar Mobile Engineering" => "sdk@freestar.io" }
  s.source       = { :http => 'https://storage.googleapis.com/freestar-sdk/FSCommon/FSCommon-#{version}#.tar.gz' }
  s.ios.deployment_target  = "9.0"
  s.ios.vendored_frameworks = "build/FSCommon.framework"
end
