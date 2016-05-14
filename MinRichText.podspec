#
#  Be sure to run `pod spec lint MinRichText.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "MinRichText"
  s.version      = "1.0.1"
  s.summary      = "A custom CoreText rich text view"
  s.description  = <<-DESC
  					自定义CoreText富文本显示库，可以处理链接、@文字、表情图片的富文本显示。
                   DESC
  s.license      = "MIT"
  s.author             = { "zsm" => "zsmzhug@gmail.com" }
  s.homepage     = "https://github.com/zsmzhu/MinRichText.git"
  s.platform     = :ios, "6.0"
  s.source       = { :git => "https://github.com/zsmzhu/MinRichText.git", :tag => "1.0.1" }
  s.source_files  = "MinRichText/**/*.{h,m}"
  s.framework  = "UIKit", "Foundation"
  s.requires_arc = true

end
