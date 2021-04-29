
Pod::Spec.new do |s|
  s.name             = 'DRACOON-Crypto-SDK'
  s.version          = '2.1.0'
  s.summary          = 'Official DRACOON Crypto SDK'

  s.description      = <<-DESC
  This SDK implements client-side encryption for DRACOON.
                       DESC

  s.homepage         = 'https://github.com/dracoon/dracoon-swift-crypto-sdk'
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { 'Mathias Schreiner' => 'm.schreiner@dracoon.com' }
  s.source           = { :git => 'https://github.com/dracoon/dracoon-swift-crypto-sdk.git', :tag => "v" + s.version.to_s }
  s.module_name      = 'crypto_sdk'

  s.ios.deployment_target = '11.4'
  s.swift_version = '5.3'
  s.pod_target_xcconfig = { 'VALID_ARCHS' => 'x86_64 arm64' }

  s.source_files = 'crypto-sdk/**/*'
  s.vendored_frameworks = 'OpenSSL/openssl.framework'
end
