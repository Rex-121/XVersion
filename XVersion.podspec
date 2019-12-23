#
# Be sure to run `pod lib lint XVersion.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XVersion'
  s.version          = '0.1.0'
  s.summary          = '版本控制'

  s.description      = <<-DESC
用于版本比较等功能
                       DESC

  s.homepage         = 'https://github.com/Tyrant/XVersion'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Tyrant' => 'ray_wzc@163.com' }
  s.source           = { :git => 'git@114.242.31.175:wangzhichen/XVersion.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'XVersion/Classes/**/*'
end
