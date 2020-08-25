//
//  PhotoInfoViewController.swift
//  Photorama
//
//  Created by Crispin Lloyd on 15/04/2020.
//  Copyright © 2020 Big Nerd Ranch. All rights reserved.
//

import UIKit

class PhotoInfoViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var viewCountLabel: UILabel!
    
    
    var photo: Photo! {
        didSet {
            navigationItem.title = photo.title
        }
    }
    var store: PhotoStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewCountLabel.text = "Photograph view count = \(photo.viewCount)"
        
        
        store.fetchImage(for: photo) { (result) -> Void in
            switch result {
            case let .success(image):
                self.imageView.image = image
            case let .failure(error):
                print("Error fetching image for photo: \(error)")
            }
        }
    }
    
    
    
}
