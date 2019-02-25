#
#  Be sure to run `pod spec lint ReactNativeHotFix.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "ReactNativeHotFix"
  s.version      = "0.0.1"
  s.summary      = "hot fix for react native ios"

  s.description  = "for hot fix"

  s.homepage     = "http://abc/ReactNativeHotFix"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  s.license      = "MIT (nothing)"
  s.author             = { "kimber" => "jinbangzhu@gmail.com" }
  s.platform     = :ios
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "http://abc/ReactNativeHotFix.git", :tag => "#{s.version}" }


  s.source_files  = "ReactNativeHotFix/*.m","ReactNativeHotFix/*.h", "ReactNativeHotFix/**/*.{h,m,c}"
  s.public_header_files = 'ReactNativeHotFix/*.h', "ReactNativeHotFix/**/*.h"
  s.library = 'z'
  s.requires_arc = true

  #s.dependency 'SSZipArchive'

end
