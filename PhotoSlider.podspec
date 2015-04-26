#
# Be sure to run `pod lib lint PhotoSlider.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "PhotoSlider"
  s.version          = "0.2.1"
  s.summary          = "PhotoSlider can a simple photo slider and delete slider with swiping."
  s.homepage         = "https://github.com/nakajijapan/PhotoSlider"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "nakajijapan" => "pp.kupepo.gattyanmo@gmail.com" }
  s.source           = { :git => "https://github.com/nakajijapan/PhotoSlider.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/nakajijapan'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'PhotoSlider' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  #s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'SDWebImage'
end
