# PhotoSlider for Swift

[![Carthage](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/PhotoSlider.svg?style=flat)](http://cocoapods.org/pods/PhotoSlider)
[![License](https://img.shields.io/cocoapods/l/PhotoSlider.svg?style=flat)](http://cocoapods.org/pods/PhotoSlider)
[![Platform](https://img.shields.io/cocoapods/p/PhotoSlider.svg?style=flat)](http://cocoapods.org/pods/PhotoSlider)
[![Language](https://img.shields.io/badge/language-Swift%204-orange.svg)](https://swift.org)

PhotoSlider is a simple photo slider and can delete slider with swiping. 

<img src="https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/demo.gif" width="300" />

## Requirements

- Xcode 9+
- Swift 4.0+
- iOS 10+

## Installation

### CocoaPods

PhotoSlider is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "PhotoSlider"
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager for Cocoa application.

``` bash
$ brew update
$ brew install carthage
```

To integrate PhotoSlider into your Xcode project using Carthage, specify it in your `Cartfile`:

``` ogdl
github "nakajijapan/PhotoSlider"
```

Then, run the following command to build the PhotoSlider framework:

``` bash
$ carthage update
```

## Usage

### Using ZoomingAnimationControllerTransitioning

```swift

func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

    var slider = PhotoSlider.ViewController(imageURLs: self.images)
    slider.currentPage = indexPath.row
    photoSlider.transitioningDelegate = self
    present(photoSlider, animated: true, completion: nil)

}

```

#### ZoomingAnimationControllerTransitioning

return imageView for starting position

```swift
// MARK: ZoomingAnimationControllerTransitioning

func transitionSourceImageView() -> UIImageView {

    let indexPath = collectionView.indexPathsForSelectedItems?.first
    let cell = collectionView.cellForItem(at: indexPath!) as! ImageCollectionViewCell
    let imageView = UIImageView(image: cell.imageView.image)

    var frame = cell.imageView.frame
    frame.origin.y += UIApplication.shared.statusBarFrame.height

    imageView.frame = frame
    imageView.clipsToBounds = true
    imageView.contentMode = .scaleAspectFill

    return imageView

}
```


return sourceImageView for finished position

```swift
func transitionDestinationImageView(sourceImageView: UIImageView) {
    
    guard let image = sourceImageView.image else {
        return
    }
    
    let indexPath = collectionView.indexPathsForSelectedItems?.first
    let cell = collectionView.cellForItem(at: indexPath!) as! ImageCollectionViewCell
    let statusBarHeight = UIApplication.shared.statusBarFrame.height

    // snip..

    sourceImageView.frame = frame
    
}
```


#### UIViewControllerTransitioningDelegate

```swift
// MARK: UIViewControllerTransitioningDelegate

func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    let animationController = PhotoSlider.ZoomingAnimationController(present: false)
    animationController.sourceTransition = dismissed as? ZoomingAnimationControllerTransitioning
    animationController.destinationTransition = self
    return animationController
}

func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    let animationController = PhotoSlider.ZoomingAnimationController(present: true)
    animationController.sourceTransition = source as? ZoomingAnimationControllerTransitioning
    animationController.destinationTransition = presented as? ZoomingAnimationControllerTransitioning
    return animationController
}

```


### Using UIModalTransitionStyle

select ZoomingAnimationController

```swift

func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

    var slider = PhotoSlider.ViewController(imageURLs: self.images)
    slider.modalPresentationStyle = .OverCurrentContext
    slider.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
    slider.index = indexPath.row
    self.presentViewController(slider, animated: true, completion: nil)

}

```

## Delegation

You can handle the following event:

- optional func photoSliderControllerWillDismiss(viewController: PhotoSlider.ViewController)
- optional func photoSliderControllerDidDismiss(viewController: PhotoSlider.ViewController)

## Multiple Image Loader

PhotoSlider use Kingfisher for remote image.
If use SDWebImage in your project, image cache is not shared between Kingfisher and SDWebImage.
In this case you can make custom ImageLoader. default ImageLoader is Kingfisher.

Here is how to change SDWebImage.

First, create custom ImageLoader.

```swift
import PhotoSlider

class PhotoSliderSDImageLoader: PhotoSlider.ImageLoader {
    public func load(
        imageView: UIImageView?,
        fromURL url: URL?,
        progress: @escaping PhotoSlider.ImageLoader.ProgressBlock,
        completion: @escaping PhotoSlider.ImageLoader.CompletionBlock)
    {
        imageView?.sd_setImage(
            withURL: url,
            placeholderImage: nil,
            options: SDWebImageOptions.retryFailed,
            progress: { (receivedSize, totalSize) in
                progress(receivedSize, totalSize)
            },
            completed: { (image, _, _, _) in
                completion(image)
            }
        )
    }
}
```

and set ImageLoader.

```swift
let slider = PhotoSlider.ViewController(imageURLs: images)
slider.modalPresentationStyle = .OverCurrentContext
slider.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
slider.index = indexPath.row
slider.imageLoader = PhotoSliderSDImageLoader()
present(slider, animated: true, completion: nil)
```

## Author

nakajijapan, pp.kupepo.gattyanmo@gmail.com

## License

PhotoSlider is available under the MIT license. See the LICENSE file for more info.
