# PhotoSlider for Swift

[![Version](https://img.shields.io/cocoapods/v/PhotoSlider.svg?style=flat)](http://cocoapods.org/pods/PhotoSlider)
[![License](https://img.shields.io/cocoapods/l/PhotoSlider.svg?style=flat)](http://cocoapods.org/pods/PhotoSlider)
[![Platform](https://img.shields.io/cocoapods/p/PhotoSlider.svg?style=flat)](http://cocoapods.org/pods/PhotoSlider)

PhotoSlider can a simple photo slider and delete slider with swiping.


<img src="https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/demo.gif" width="300" />


## Installation

PhotoSlider is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "PhotoSlider"
```

## Usage

### Using ZoomingAnimationControllerTransitioning

```swift

func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

    var slider = PhotoSlider.ViewController(imageURLs: self.images)
    slider.index = indexPath.row
    photoSlider.transitioningDelegate = self
    self.presentViewController(slider, animated: true, completion: nil)
}

```

#### ZoomingAnimationControllerTransitioning

return imageView for starting position

```swift
// MARK: ZoomingAnimationControllerTransitioning

func transitionSourceImageView() -> UIImageView {
    let indexPath = self.collectionView.indexPathsForSelectedItems()?.first
    let cell = self.collectionView.cellForItemAtIndexPath(indexPath!) as! ImageCollectionViewCell
    let imageView = UIImageView(image: cell.imageView.image)
    imageView.contentMode = UIViewContentMode.ScaleAspectFit
    imageView.clipsToBounds = true
    imageView.userInteractionEnabled = false
    return imageView
}
```


return frame for finished position

```swift
func transitionDestinationImageViewFrame() -> CGRect {
    let indexPath = self.collectionView.indexPathsForSelectedItems()?.first
    let cell = self.collectionView.cellForItemAtIndexPath(indexPath!) as! ImageCollectionViewCell
    return cell.imageView.frame
}
```

#### UIViewControllerTransitioningDelegate

```swift
// MARK: UIViewControllerTransitioningDelegate

func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    let animationController = PhotoSlider.ZoomingAnimationController(present: false)
    animationController.sourceTransition = dismissed as? ZoomingAnimationControllerTransitioning
    animationController.destinationTransition = self
    return animationController
}

func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
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

## Requirements
Xcode 6 is required.

## Author

nakajijapan, pp.kupepo.gattyanmo@gmail.com

## License

PhotoSlider is available under the MIT license. See the LICENSE file for more info.
