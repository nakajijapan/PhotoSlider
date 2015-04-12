//
//  ViewController.swift
//
//  Created by nakajijapan on 3/28/15.
//  Copyright (c) 2015 net.nakajijapan. All rights reserved.
//

import UIKit
import SDWebImage

public class ViewController:UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    var collectionView: UICollectionView!
    var imageURLs:Array<String>?

    public var index:Int = 0
    public init(imageURLs:Array<String>) {
        super.init()
        self.imageURLs = imageURLs
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view.frame = UIScreen.mainScreen().bounds
        self.view.backgroundColor = UIColor.clearColor()
        self.view.userInteractionEnabled = true

        var backgroundView = UIView(frame: self.view.bounds)
        backgroundView.backgroundColor = UIColor.blackColor()
        backgroundView.alpha = 0.8;
        self.view.addSubview(backgroundView)

        // layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;

        //collectionView
        self.collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        self.collectionView.registerClass(CollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        self.collectionView.pagingEnabled = true
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.bounces = true
        self.collectionView.backgroundColor = UIColor.clearColor()
        self.collectionView.showsHorizontalScrollIndicator = true
        self.collectionView.alwaysBounceVertical = true
        self.view.addSubview(self.collectionView)

    }

    override public func viewWillAppear(animated: Bool) {
        let indexPath = NSIndexPath(forItem: self.index, inSection: 0)
        self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.None, animated: false)
    }

    override public func touchesBegan(touches: NSSet, withEvent event: UIEvent) {

        self.dismissViewControllerAnimated(true) { () -> Void in
            self.view.removeFromSuperview()
        }

    }

    // MARK: - UICollectionViewDataSource

    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageURLs!.count
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as CollectionViewCell
        cell.backgroundColor = UIColor.clearColor()

        if self.imageURLs != nil {
            let imageURL = NSURL(string: self.imageURLs![indexPath.row])!
            cell.imageView.imageView.sd_setImageWithURL(imageURL)
        }

        return cell
    }

    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return self.view.bounds.size
    }

    // MARK: - UIScrollViewDelegate
    var scrollPreviewPoint = CGPointZero;
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.scrollPreviewPoint = scrollView.contentOffset
    }

    public func scrollViewDidScroll(scrollView: UIScrollView) {

        let screenHeight = UIScreen.mainScreen().bounds.size.height
        let screenWidth = UIScreen.mainScreen().bounds.size.width


        if scrollView.contentOffset.y > 100 {

            self.collectionView.frame = scrollView.frame
            UIView.animateWithDuration(
                0.5,
                delay: 0,
                options: UIViewAnimationOptions.CurveEaseOut,
                animations: { () -> Void in
                    self.collectionView.frame = CGRectMake(0, -screenHeight, screenWidth, screenHeight)
                    self.dismissViewControllerAnimated(true, completion: nil)
                },
                completion: nil
            )
            return

        } else if scrollView.contentOffset.y < -100 {

            self.collectionView.frame = scrollView.frame
            UIView.animateWithDuration(
                0.5,
                delay: 0,
                options: UIViewAnimationOptions.CurveEaseOut,
                animations: { () -> Void in
                    self.collectionView.frame = CGRectMake(0, screenHeight, screenWidth, screenHeight)
                    self.dismissViewControllerAnimated(true, completion: nil)
                },
                completion: nil
            )
            
            return
        }

        var offsetX = fabs(scrollView.contentOffset.x - self.scrollPreviewPoint.x)
        var offsetY = fabs(scrollView.contentOffset.y - self.scrollPreviewPoint.y)
        if offsetY > offsetX {
            var contentOffset = scrollView.contentOffset
            contentOffset.x = self.scrollPreviewPoint.x
            scrollView.contentOffset = contentOffset
        } else {
            var contentOffset = scrollView.contentOffset
            contentOffset.y = self.scrollPreviewPoint.y
            scrollView.contentOffset = contentOffset
        }


    }

}
