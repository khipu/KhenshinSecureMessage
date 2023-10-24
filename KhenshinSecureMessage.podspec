#
# Be sure to run `pod lib lint KhenshinSecureMessage.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KhenshinSecureMessage'
  s.version          = '1.0.0'
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
  s.dependency 'Sodium', '0.9.1'
end
