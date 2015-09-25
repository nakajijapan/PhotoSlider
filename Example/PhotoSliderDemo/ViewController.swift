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
    var selectedIndexPath: NSIndexPath?
    
    var imageURLs = [
        NSURL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Example/Resources/image001.jpg")!,
        NSURL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Example/Resources/image002.jpg")!,
        NSURL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Example/Resources/image003.jpg")!,
        NSURL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Example/Resources/image004.jpg")!,
        NSURL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Example/Resources/image005.jpg")!,
        NSURL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Example/Resources/image006.jpg")!,
        NSURL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Example/Resources/image007.jpg")!,
        NSURL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Example/Resources/image008.jpg")!,
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
            self.collectionView.contentOffset = CGPoint(x: CGFloat(indexPath.row) * self.view.bounds.width, y: 0)
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
            if UIDevice.currentDevice().orientation == UIDeviceOrientation.Portrait || UIDevice.currentDevice().orientation == UIDeviceOrientation.PortraitUpsideDown {
                return tableView.bounds.size.width
            } else {
                return tableView.bounds.size.height
            }
        }
        
        return 0.0;
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
        imageView!.sd_setImageWithURL(self.imageURLs[indexPath.row])
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.Portrait ||
            UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.PortraitUpsideDown {
                
                return CGSize(width:collectionView.bounds.size.width, height:collectionView.bounds.size.width)
                
        } else {
            
            return CGSize(width:self.tableView.bounds.size.width, height:collectionView.bounds.size.height)

        }
        
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        self.selectedIndexPath = indexPath
        
        // Using transition
        let photoSlider = PhotoSlider.ViewController(imageURLs: self.imageURLs)
        //let photoSlider = PhotoSlider.ViewController(images: self.images)
        photoSlider.delegate = self
        photoSlider.currentPage = indexPath.row
        //photoSlider.visibleCloseButton = false
        //photoSlider.visiblePageControl = false
        photoSlider.transitioningDelegate = self
        
        self.presentViewController(photoSlider, animated: true) { () -> Void in
            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
        }
    }
    
    // MARK: - PhotoSliderDelegate
    
    func photoSliderControllerWillDismiss(viewController: PhotoSlider.ViewController) {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
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
        frame.origin.y += 20
        
        imageView.frame = frame
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        imageView.clipsToBounds = true
        imageView.userInteractionEnabled = false
        
        return imageView
    }
    
    func transitionDestinationImageViewFrame() -> CGRect {
        let indexPath = self.collectionView.indexPathsForSelectedItems()?.first
        let cell = self.collectionView.cellForItemAtIndexPath(indexPath!) as! ImageCollectionViewCell

        var frame = cell.imageView.frame
        frame.origin.y += 20

        return frame
    }
    
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
    
}


