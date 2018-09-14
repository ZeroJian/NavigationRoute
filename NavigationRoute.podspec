#
# Be sure to run `pod lib lint NavigationRoute.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NavigationRoute'
  s.version          = '1.0.0'
  s.summary          = 'StackView Navigation.'


  s.description      = <<-DESC
	iOS StackView Navigation Tool
                       DESC

  s.homepage         = 'https://github.com/zerojian/NavigationRoute'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zerojian' => 'zj17223412@outlook.com' }
  s.source           = { :git => 'https://github.com/ZeroJian/NavigationRoute.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  
  s.swift_version = '4.0'

  s.source_files = 'NavigationRoute/Classes/**/*'

  s.dependency "SnapKit"

end
