//
//  ViewController.swift
//  PhotoSlider
//
//  Created by nakajijapan on 4/12/15.
//  Copyright (c) 2015 net.nakajijapan. All rights reserved.
//

import UIKit
import PhotoSlider

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PhotoSliderDelegate {
    
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
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return UIScreen.mainScreen().bounds.size.width
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
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("hcell", forIndexPath: indexPath) as! UICollectionViewCell
        
        var imageView = cell.viewWithTag(1) as! UIImageView
        imageView.sd_setImageWithURL(self.imageURLs[indexPath.row])
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width:collectionView.bounds.size.width, height:collectionView.bounds.size.width)
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        var slider = PhotoSlider.ViewController(imageURLs: self.imageURLs)
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


