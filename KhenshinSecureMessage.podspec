Pod::Spec.new do |s|
  s.name             = 'KhenshinSecureMessage'
  s.version          = '1.3.0'
  s.summary          = 'KhenshinSecureMessage allows to securely communicate with a Khenshin Server'
  s.description      = <<-DESC
  KhenshinSecureMessage uses NaCl to establish a secure channel that goes on top of a TLS connection.
                       DESC

  s.homepage         = 'https://github.com/khipu/KhenshinSecureMessage'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Khipu' => 'developers@khipu.com' }
  s.source           = { :git => 'https://github.com/khipu/KhenshinSecureMessage.git', :tag => s.version.to_s }
  s.ios.deployment_target = '12.0'

  s.source_files  = 'KhenshinSecureMessage/Classes/**/*'
  s.dependency 'KHTweetNacl', '1.1.4'
  s.swift_version = '5.0'
end
