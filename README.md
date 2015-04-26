# PhotoSlider for Swift

[![CI Status](http://img.shields.io/travis/nakajijapan/PhotoSlider.svg?style=flat)](https://travis-ci.org/nakajijapan/PhotoSlider)
[![Version](https://img.shields.io/cocoapods/v/PhotoSlider.svg?style=flat)](http://cocoapods.org/pods/PhotoSlider)
[![License](https://img.shields.io/cocoapods/l/PhotoSlider.svg?style=flat)](http://cocoapods.org/pods/PhotoSlider)
[![Platform](https://img.shields.io/cocoapods/p/PhotoSlider.svg?style=flat)](http://cocoapods.org/pods/PhotoSlider)

PhotoSlider can a simple photo slider and delete slider with swiping.

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

PhotoSlider is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "PhotoSlider"
```

## Use

```swift

func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

    var slider = PhotoSlider.ViewController(imageURLs: self.images)
    slider.modalPresentationStyle = .OverCurrentContext
    slider.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
    slider.index = indexPath.row
    self.presentViewController(slider, animated: true, completion: nil)

}

```


## Author

nakajijapan, pp.kupepo.gattyanmo@gmail.com

## License

PhotoSlider is available under the MIT license. See the LICENSE file for more info.
