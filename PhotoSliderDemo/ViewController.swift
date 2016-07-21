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
        URL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Resources/image001.jpg")!,
        URL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Resources/image002.jpg")!,
        URL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Resources/image003.jpg")!,
        URL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Resources/image004.jpg")!,
        URL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Resources/image005.jpg")!,
        URL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Resources/image006.jpg")!,
        URL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Resources/image007.jpg")!,
        URL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Resources/image008.jpg")!,
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
        PhotoSlider.Photo(imageURL:URL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Resources/image001.jpg")!, caption: "In San Francisco, I went walking in the night. The city is still bright."),
        PhotoSlider.Photo(imageURL:URL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Resources/image002.jpg")!, caption: "This is a very good photo. \nGood!"),
        PhotoSlider.Photo(imageURL:URL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Resources/image003.jpg")!, caption: ""),
        PhotoSlider.Photo(imageURL:URL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Resources/image004.jpg")!, caption: "Fire Alerm"),
        PhotoSlider.Photo(imageURL:URL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Resources/image005.jpg")!, caption: "He is misyobun. He is from Japan."),
        PhotoSlider.Photo(imageURL:URL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Resources/image006.jpg")!, caption: "Bamboo grove.\nGreen\nGood"),
        PhotoSlider.Photo(imageURL:URL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Resources/image007.jpg")!, caption: "Railroad"),
        PhotoSlider.Photo(imageURL:URL(string:"https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Resources/image008.jpg")!, caption: "Japan. \nRice paddy."),
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {

        if self.collectionView != nil {
            let indexPath = self.collectionView.indexPathsForVisibleItems().first!
            self.collectionView.contentOffset = CGPoint(x: CGFloat((indexPath as NSIndexPath).row) * self.view.bounds.width, y: 0.0)
        }

    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell01")!
        
        self.collectionView = cell.viewWithTag(1) as! UICollectionView
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (indexPath as NSIndexPath).row == 0 {
            
            if self.view.bounds.size.width < self.view.bounds.height {
                return tableView.bounds.size.width
            } else {
                return tableView.bounds.size.height
            }
        }
        
        return 0.0
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hcell", for: indexPath) as! ImageCollectionViewCell
        let imageView = cell.imageView
        imageView!.kf_setImageWithURL(self.imageURLs[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if self.view.bounds.size.width < self.view.bounds.height {

            return CGSize(width:self.tableView.bounds.size.width, height:self.tableView.bounds.size.width)

        } else {
            
            return CGSize(width:self.tableView.bounds.size.width, height:collectionView.bounds.size.height)

        }
        
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
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
    
    func photoSliderControllerWillDismiss(_ viewController: PhotoSlider.ViewController) {

        UIApplication.shared().setStatusBarHidden(false, with: UIStatusBarAnimation.fade)
        
        let indexPath = IndexPath(forItem: viewController.currentPage, inSection: 0)
        self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.None, animated: false)
    }

    // MARK: - UIContentContainer
    
    internal override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.tableView.reloadData()
        
    }
    
    // MARK: ZoomingAnimationControllerTransitioning
    
    func transitionSourceImageView() -> UIImageView {
        
        let indexPath = self.collectionView.indexPathsForSelectedItems()?.first
        let cell = self.collectionView.cellForItem(at: indexPath!) as! ImageCollectionViewCell
        let imageView = UIImageView(image: cell.imageView.image)
        
        var frame = cell.imageView.frame
        frame.origin.y += UIApplication.shared().statusBarFrame.height
        
        imageView.frame = frame
        imageView.clipsToBounds = true
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        
        return imageView
    }
    
    func transitionDestinationImageView(_ sourceImageView: UIImageView) {
        
        guard let image = sourceImageView.image else {
            return
        }
        
        let indexPath = self.collectionView.indexPathsForSelectedItems()?.first
        let cell = self.collectionView.cellForItem(at: indexPath!) as! ImageCollectionViewCell
        let statusBarHeight = UIApplication.shared().statusBarFrame.height
        var frame = CGRect.zero
        
        if self.view.bounds.size.width < self.view.bounds.height {

            if image.size.height < image.size.width {
                let width = (sourceImageView.image!.size.width * sourceImageView.bounds.size.width) / sourceImageView.image!.size.height
                let x = width * 0.5 - cell.imageView.bounds.width * 0.5
                frame = CGRect(x: -1.0 * x, y: statusBarHeight, width: width, height: cell.imageView.bounds.height)
            } else {
                frame = CGRect(x: 0.0, y: statusBarHeight, width: cell.imageView.bounds.width, height: cell.imageView.bounds.height)
            }
            
        } else {

            let height = (image.size.height * cell.imageView.bounds.width) / image.size.width
            let y = height * 0.5 - cell.imageView.bounds.height * 0.5 - statusBarHeight
            frame = CGRect(x: 0.0, y: -1.0 * y, width: self.view.bounds.width, height: height)

        }
        
        sourceImageView.frame = frame
        
    }
    
    // MARK: UIViewControllerTransitioningDelegate
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let animationController = PhotoSlider.ZoomingAnimationController(present: false)
        animationController.sourceTransition = dismissed as? ZoomingAnimationControllerTransitioning
        animationController.destinationTransition = self
        
        // for orientation
        if self.responds(to: #selector(UIViewControllerTransitioningDelegate.animationController(forDismissed:))) {
            self.view.frame = dismissed.view.bounds
        }
        
        return animationController
        
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let animationController = PhotoSlider.ZoomingAnimationController(present: true)
        animationController.sourceTransition = source as? ZoomingAnimationControllerTransitioning
        animationController.destinationTransition = presented as? ZoomingAnimationControllerTransitioning
        return animationController
        
    }
    
}


