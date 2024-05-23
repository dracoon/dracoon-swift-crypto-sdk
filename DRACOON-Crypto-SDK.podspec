
Pod::Spec.new do |s|
  s.name             = 'DRACOON-Crypto-SDK'
  s.version          = '2.3.1'
  s.summary          = 'Official DRACOON Crypto SDK'

  s.description      = <<-DESC
  This SDK implements client-side encryption for DRACOON.
                       DESC

  s.homepage         = 'https://github.com/dracoon/dracoon-swift-crypto-sdk'
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { 'Mathias Schreiner' => 'm.schreiner@dracoon.com' }
  s.source           = { :git => 'https://github.com/dracoon/dracoon-swift-crypto-sdk.git', :tag => "v" + s.version.to_s }
  s.module_name      = 'crypto_sdk'

  s.ios.deployment_target = '12.0'
  s.swift_version = '5.9'
  s.pod_target_xcconfig = { 'VALID_ARCHS' => 'x86_64 arm64' }

  s.subspec 'crypto_sdk_objc' do |objc|
    objc.source_files = 'crypto-sdk/crypto/include/*', 'crypto-sdk-objc/*', 'crypto-sdk/crypto/OpenSslCrypto.m'
    objc.public_header_files = 'crypto-sdk/crypto/include/*'
    objc.vendored_frameworks = 'OpenSSL/openssl.xcframework'
  end

  s.subspec 'crypto_sdk_swift' do |swift|
    swift.dependency 'DRACOON-Crypto-SDK/crypto_sdk_objc'
    swift.source_files = 'crypto-sdk/crypto/include/*', 'crypto-sdk-objc/crypto_sdk_objc.h', 'crypto-sdk/**/*'
    swift.exclude_files = 'crypto-sdk/swift-wrapper/Exports.swift'
    swift.public_header_files = 'crypto-sdk/crypto/include/*', 'crypto-sdk-objc/crypto_sdk_objc.h'
    swift.vendored_frameworks = 'OpenSSL/openssl.xcframework'
  end

end
