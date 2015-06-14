//
//  ViewController.swift
//  PhotoSliderDemo
//
//  Created by nakajijapan on 4/12/15.
//  Copyright (c) 2015 net.nakajijapan. All rights reserved.
//

import UIKit
import PhotoSlider

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PhotoSliderDelegate {
    
    @IBOutlet var tableView:UITableView!
    
    var collectionView:UICollectionView!

    var images = [
        "https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Example/Resources/image001.jpg",
        "https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Example/Resources/image002.jpg",
        "https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Example/Resources/image003.jpg",
        "https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Example/Resources/image004.jpg",
        "https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Example/Resources/image005.jpg",
        "https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Example/Resources/image006.jpg",
        "https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Example/Resources/image007.jpg",
        "https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Example/Resources/image008.jpg",
    ]
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("cell01") as! UITableViewCell
        
        var collectionView = cell.viewWithTag(1) as! UICollectionView
        collectionView.delegate = self
        collectionView.dataSource = self
        
        var insets = collectionView.contentInset
        insets.top = -20
        collectionView.contentInset = insets

        return cell
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("hcell", forIndexPath: indexPath) as! UICollectionViewCell
        
        var imageView = cell.viewWithTag(1) as! UIImageView
        imageView.sd_setImageWithURL(NSURL(string: self.images[indexPath.row])!)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width:UIScreen.mainScreen().bounds.size.width, height:UIScreen.mainScreen().bounds.size.width)
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        var slider = PhotoSlider.ViewController(imageURLs: self.images)
        slider.modalPresentationStyle = .OverCurrentContext
        slider.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        slider.delegate = self
        slider.index = indexPath.row

        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
        self.presentViewController(slider, animated: true, completion: nil)
    }
    
    // MARK: - PhotoSliderDelegate

    func photoSliderControllerWillDismiss(viewController: PhotoSlider.ViewController) {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
    }

}


