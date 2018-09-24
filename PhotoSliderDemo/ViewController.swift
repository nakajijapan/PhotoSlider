//
//  ViewController.swift
//  PhotoSliderDemo
//
//  Created by nakajijapan on 4/12/15.
//  Copyright (c) 2015 net.nakajijapan. All rights reserved.
//

import UIKit
import PhotoSlider

let imageUrlString = "https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/Resources/"

class ViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    var collectionView: UICollectionView!
    let imageURLs = [
        URL(string: "\(imageUrlString)image001.jpg")!,
        URL(string: "\(imageUrlString)image002.jpg")!,
        URL(string: "\(imageUrlString)image003.jpg")!,
        URL(string: "\(imageUrlString)image004.jpg")!,
        URL(string: "\(imageUrlString)image005.jpg")!,
        URL(string: "\(imageUrlString)image006.jpg")!,
        URL(string: "\(imageUrlString)image007.jpg")!,
        URL(string: "\(imageUrlString)image008.jpg")!,
    ]
    let images = [
        UIImage(named: "image001.jpg")!,
        UIImage(named: "image002.jpg")!,
        UIImage(named: "image003.jpg")!,
        UIImage(named: "image004.jpg")!,
        UIImage(named: "image005.jpg")!,
        UIImage(named: "image006.jpg")!,
        UIImage(named: "image007.jpg")!,
        UIImage(named: "image008.jpg")!,
    ]
    
    let photos = [
        PhotoSlider.Photo(imageURL: URL(string: "\(imageUrlString)image001.jpg")!, caption: "In San Francisco, I went walking in the night. The city is still bright."),
        PhotoSlider.Photo(imageURL: URL(string: "\(imageUrlString)image002.jpg")!, caption: "This is a very good photo. \nGood!"),
        PhotoSlider.Photo(imageURL: URL(string: "\(imageUrlString)image003.jpg")!, caption: ""),
        PhotoSlider.Photo(imageURL: URL(string: "\(imageUrlString)image004.jpg")!, caption: "Fire Alerm"),
        PhotoSlider.Photo(imageURL: URL(string: "\(imageUrlString)image005.jpg")!, caption: "He is misyobun. He is from Japan."),
        PhotoSlider.Photo(imageURL: URL(string: "\(imageUrlString)image006.jpg")!, caption: "Bamboo grove.\nGreen\nGood\nSo Good"),
        PhotoSlider.Photo(imageURL: URL(string: "\(imageUrlString)image007.jpg")!, caption: "Railroad"),
        PhotoSlider.Photo(imageURL: URL(string: "\(imageUrlString)image008.jpg")!, caption: "Japan. \nRice paddy."),
    ]
    
    var currentRow = 0

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
        super.traitCollectionDidChange(previousTraitCollection)

        guard let collectionView = collectionView else {
            return
        }

        var width = view.bounds.width
        if #available(iOS 11.0, *) {
            width = view.bounds.width - view.safeAreaInsets.left - view.safeAreaInsets.right
        }
        collectionView.contentOffset = CGPoint(x: CGFloat(currentRow) * width, y: 0.0)
    }
    
    // MARK: - UIContentContainer
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        updateCurrentRow(to: size)
        tableView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension ViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hcell", for: indexPath) as! ImageCollectionViewCell
        let imageView = cell.imageView
        imageView!.kf.setImage(with: imageURLs[indexPath.row])
        return cell
    }

}

// MARK: - UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Using transition
        //let photoSlider = PhotoSlider.ViewController(imageURLs: imageURLs)
        //let photoSlider = PhotoSlider.ViewController(images: images)
        let photoSlider = PhotoSlider.ViewController(photos: photos)
        photoSlider.backgroundViewColor = .clear
        photoSlider.delegate = self
        photoSlider.currentPage = indexPath.row
        //photoSlider.visibleCloseButton = false
        //photoSlider.visiblePageControl = false
        photoSlider.captionNumberOfLines = 0
       
        // UIViewControllerTransitioningDelegate
        photoSlider.transitioningDelegate = self
        photoSlider.modalPresentationStyle = .overCurrentContext
        
        // Here implemention is better if you want to use ZoomingAnimationControllerTransitioning.

        //photoSlider.modalTransitionStyle   = .CrossDissolve
        present(photoSlider, animated: true, completion: nil)
        
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if view.bounds.width < view.bounds.height {
            
            return CGSize(width: tableView.bounds.width, height: tableView.bounds.width)
            
        } else {
            let height: CGFloat
            if #available(iOS 11.0, *) {
                height = view.safeAreaLayoutGuide.layoutFrame.height
            } else {
                height = view.bounds.height
            }

            return CGSize(width: tableView.bounds.width, height: height)
            
        }
        
    }
    
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell01")!
        
        collectionView = cell.viewWithTag(1) as? UICollectionView
        collectionView.delegate = self
        collectionView.dataSource = self
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if indexPath.row == 0 {
            
            if view.bounds.width < view.bounds.height {
                return tableView.bounds.width
            } else {
                return tableView.bounds.height
            }
        }
        
        return 0.0

    }
    
}

// MARK: - PhotoSliderDelegate

extension ViewController: PhotoSliderDelegate {

    func photoSliderControllerWillDismiss(_ viewController: PhotoSlider.ViewController) {
        currentRow = viewController.currentPage
        let indexPath = IndexPath(item: currentRow, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    }

}

// MARK: - ZoomingAnimationControllerTransitioning

extension ViewController: ZoomingAnimationControllerTransitioning {
    
    func transitionSourceImageView() -> UIImageView {
        
        let indexPath = collectionView.indexPathsForSelectedItems?.first
        let cell = collectionView.cellForItem(at: indexPath!) as! ImageCollectionViewCell
        let imageView = UIImageView(image: cell.imageView.image)
        
        var frame = cell.imageView.frame
        frame.origin.y += UIApplication.shared.statusBarFrame.height
        // tune in UIImageView
        if #available(iOS 11.0, *) {
            frame.origin.x = view.safeAreaInsets.left
            if view.bounds.width > view.bounds.height {
                frame.size.height = view.safeAreaLayoutGuide.layoutFrame.height
            }
        }
        imageView.frame = frame
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }
    
    func transitionDestinationImageView(sourceImageView: UIImageView) {
        
        guard let image = sourceImageView.image else {
            return
        }
        
        guard let cell = collectionView.visibleCells.first as? ImageCollectionViewCell else {
            return
        }
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
        var frame = CGRect.zero

        if view.bounds.size.width < view.bounds.height {

            if image.size.height < image.size.width {
                let width = (sourceImageView.image!.size.width * sourceImageView.bounds.size.width) / sourceImageView.image!.size.height
                let x = (width - cell.imageView.bounds.height) * 0.5
                frame = CGRect(x: -1.0 * x, y: statusBarHeight, width: width, height: cell.imageView.bounds.height)
            } else {
                frame = CGRect(x: 0.0, y: statusBarHeight, width: view.bounds.width, height: view.bounds.width)
            }
            
        } else {
            let width: CGFloat
            let x: CGFloat
            if #available(iOS 11.0, *) {
                width = view.bounds.width - view.safeAreaInsets.left - view.safeAreaInsets.right
                x = view.safeAreaInsets.left
            } else {
                width = view.bounds.width
                x = 0
            }

            let height: CGFloat
            if #available(iOS 11.0, *) {
                height = view.safeAreaLayoutGuide.layoutFrame.height
            } else {
                height = (image.size.height * width) / image.size.width
            }

            let y: CGFloat
            if #available(iOS 11.0, *) {
                y = (height - view.safeAreaLayoutGuide.layoutFrame.height - statusBarHeight) * 0.5
            } else {
                y = (height - UIScreen.main.bounds.height - statusBarHeight) * 0.5
            }

            frame = CGRect(x: x, y: -1.0 * y, width: width, height: height)
        }
        sourceImageView.frame = frame
        
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension ViewController: UIViewControllerTransitioningDelegate {

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
        let animationController = PhotoSlider.ZoomingAnimationController(present: false)
        animationController.sourceTransition = dismissed as? ZoomingAnimationControllerTransitioning
        animationController.destinationTransition = self
        
        view.frame = dismissed.view.bounds
        
        return animationController
        
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        let animationController = PhotoSlider.ZoomingAnimationController(present: true)
        animationController.sourceTransition = source as? ZoomingAnimationControllerTransitioning
        animationController.destinationTransition = presented as? ZoomingAnimationControllerTransitioning
        return animationController
        
    }
    
}

// MARK: - Private Methods

extension ViewController {
    
    func updateCurrentRow(to size: CGSize) {
        var row = Int(round(collectionView.contentOffset.x / collectionView.bounds.width))
        if row < 0 {
            row = 0
        }
        currentRow = row
    }
    
}
