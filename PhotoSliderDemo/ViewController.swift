//
//  ViewController.swift
//  PhotoSliderDemo
//
//  Created by nakajijapan on 4/12/15.
//  Copyright (c) 2015 net.nakajijapan. All rights reserved.
//

import UIKit
import PhotoSlider

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PhotoSliderDelegate, UIViewControllerTransitioningDelegate, ZoomingAnimationControllerTransitioning {
    
    @IBOutlet var tableView:UITableView!
    var collectionView:UICollectionView!
    var imageURLs = [
        NSURL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Resources/image001.jpg")!,
        NSURL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Resources/image002.jpg")!,
        NSURL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Resources/image003.jpg")!,
        NSURL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Resources/image004.jpg")!,
        NSURL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Resources/image005.jpg")!,
        NSURL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Resources/image006.jpg")!,
        NSURL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Resources/image007.jpg")!,
        NSURL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Resources/image008.jpg")!,
    ]
    var images = [
        UIImage(named: "image001.jpg")!,
        UIImage(named: "image002.jpg")!,
        UIImage(named: "image003.jpg")!,
        UIImage(named: "image004.jpg")!,
        UIImage(named: "image005.jpg")!,
        UIImage(named: "image006.jpg")!,
        UIImage(named: "image007.jpg")!,
        UIImage(named: "image008.jpg")!,
    ]
    var photos = [
        PhotoSlider.Photo(imageURL:NSURL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Resources/image001.jpg")!, caption: "In San Francisco, I went walking in the night. The city is still bright."),
        PhotoSlider.Photo(imageURL:NSURL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Resources/image002.jpg")!, caption: "This is a very good photo. \nGood!"),
        PhotoSlider.Photo(imageURL:NSURL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Resources/image003.jpg")!, caption: ""),
        PhotoSlider.Photo(imageURL:NSURL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Resources/image004.jpg")!, caption: "Fire Alerm"),
        PhotoSlider.Photo(imageURL:NSURL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Resources/image005.jpg")!, caption: "He is misyobun. He is from Japan."),
        PhotoSlider.Photo(imageURL:NSURL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Resources/image006.jpg")!, caption: "Bamboo grove.\nGreen\nGood"),
        PhotoSlider.Photo(imageURL:NSURL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Resources/image007.jpg")!, caption: "Railroad"),
        PhotoSlider.Photo(imageURL:NSURL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Resources/image008.jpg")!, caption: "Japan. \nRice paddy."),
    ]
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let collectionView = self.collectionView else {
            return
        }
        
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        flowLayout.invalidateLayout()
        
    }
    
    // MARK: - UITraitEnvironment
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {

        if self.collectionView != nil {
            let indexPath = self.collectionView.indexPathsForVisibleItems().first!
            self.collectionView.contentOffset = CGPoint(x: CGFloat(indexPath.row) * self.view.bounds.width, y: 0.0)
        }

    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell01")!
        
        self.collectionView = cell.viewWithTag(1) as! UICollectionView
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            if UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation) {
                return tableView.bounds.size.width
            } else {
                return tableView.bounds.size.height
            }
        }
        
        return 0.0
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageURLs.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("hcell", forIndexPath: indexPath) as! ImageCollectionViewCell
        let imageView = cell.imageView
        imageView!.kf_setImageWithURL(self.imageURLs[indexPath.row])
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation) {

            return CGSize(width:self.tableView.bounds.size.width, height:self.tableView.bounds.size.width)

        } else {
            
            return CGSize(width:self.tableView.bounds.size.width, height:collectionView.bounds.size.height)

        }
        
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // Using transition
        //let photoSlider = PhotoSlider.ViewController(imageURLs: self.imageURLs)
        //let photoSlider = PhotoSlider.ViewController(images: self.images)
        let photoSlider = PhotoSlider.ViewController(photos: self.photos)
        photoSlider.delegate = self
        photoSlider.currentPage = indexPath.row
        //photoSlider.visibleCloseButton = false
        //photoSlider.visiblePageControl = false
        
        // ZoomingAnimationControllerTransitioning
        photoSlider.transitioningDelegate = self
        
        // Here implemention is better if you want to use ZoomingAnimationControllerTransitioning.
        //photoSlider.modalPresentationStyle = .OverCurrentContext
        //photoSlider.modalTransitionStyle   = .CrossDissolve
        
        self.presentViewController(photoSlider, animated: true) { () -> Void in
            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
        }
    }
    
    // MARK: - PhotoSliderDelegate
    
    func photoSliderControllerWillDismiss(viewController: PhotoSlider.ViewController) {

        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
        
        let indexPath = NSIndexPath(forItem: viewController.currentPage, inSection: 0)
        self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.None, animated: false)
    }
    
    func photoSliderControllerDidMoveToIndex(viewController: PhotoSlider.ViewController , index : Int) {
        
        print(index)
    }
    // MARK: - UIContentContainer
    
    internal override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        self.tableView.reloadData()
        
    }
    
    // MARK: ZoomingAnimationControllerTransitioning
    
    func transitionSourceImageView() -> UIImageView {
        
        let indexPath = self.collectionView.indexPathsForSelectedItems()?.first
        let cell = self.collectionView.cellForItemAtIndexPath(indexPath!) as! ImageCollectionViewCell
        let imageView = UIImageView(image: cell.imageView.image)
        
        var frame = cell.imageView.frame
        frame.origin.y += UIApplication.sharedApplication().statusBarFrame.height
        
        imageView.frame = frame
        imageView.clipsToBounds = true
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        
        return imageView
    }
    
    func transitionDestinationImageView(sourceImageView: UIImageView) {
        
        guard let image = sourceImageView.image else {
            return
        }
        
        let indexPath = self.collectionView.indexPathsForSelectedItems()?.first
        let cell = self.collectionView.cellForItemAtIndexPath(indexPath!) as! ImageCollectionViewCell
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        var frame = CGRectZero
        
        if UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation) {

            if image.size.height < image.size.width {
                let width = (sourceImageView.image!.size.width * sourceImageView.bounds.size.width) / sourceImageView.image!.size.height
                let x = width * 0.5 - CGRectGetWidth(cell.imageView.bounds) * 0.5
                frame = CGRectMake(-1.0 * x, statusBarHeight, width, CGRectGetHeight(cell.imageView.bounds))
            } else {
                frame = CGRectMake(0.0, statusBarHeight, CGRectGetWidth(cell.imageView.bounds), CGRectGetHeight(cell.imageView.bounds))
            }
            
        } else {

            let height = (image.size.height * CGRectGetWidth(cell.imageView.bounds)) / image.size.width
            let y = height * 0.5 - CGRectGetHeight(cell.imageView.bounds) * 0.5 - statusBarHeight
            frame = CGRectMake(0.0, -1.0 * y, CGRectGetWidth(self.view.bounds), height)

        }
        
        sourceImageView.frame = frame
        
    }
    
    // MARK: UIViewControllerTransitioningDelegate
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let animationController = PhotoSlider.ZoomingAnimationController(present: false)
        animationController.sourceTransition = dismissed as? ZoomingAnimationControllerTransitioning
        animationController.destinationTransition = self
        
        // for orientation
        if self.respondsToSelector(#selector(UIViewControllerTransitioningDelegate.animationControllerForDismissedController(_:))) {
            self.view.frame = dismissed.view.bounds
        }
        
        return animationController
        
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let animationController = PhotoSlider.ZoomingAnimationController(present: true)
        animationController.sourceTransition = source as? ZoomingAnimationControllerTransitioning
        animationController.destinationTransition = presented as? ZoomingAnimationControllerTransitioning
        return animationController
        
    }
    
}


