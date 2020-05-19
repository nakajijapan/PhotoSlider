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
  s.version          = "1.2.0"
  s.summary          = "PhotoSlider can a simple photo slider and delete slider with swiping."
  s.homepage         = "https://github.com/nakajijapan/PhotoSlider"
  s.license          = 'MIT'
  s.author           = { "nakajijapan" => "pp.kupepo.gattyanmo@gmail.com" }
  s.source           = { :git => "https://github.com/nakajijapan/PhotoSlider.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/nakajijapan'

  s.platform     = :ios, '10.0'
  s.requires_arc = true
  s.swift_versions = ['4.2']

  s.source_files = 'Sources/Classes/**/*'
  s.resource_bundles = {
    'PhotoSlider' => ['Sources/Assets/*.png']
  }

  s.dependency 'Kingfisher'
end
