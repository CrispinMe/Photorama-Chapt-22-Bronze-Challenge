//
//  PhotosViewController.swift
//  Photorama
//
//  Created by Crispin Lloyd on 06/04/2020.
//  Copyright © 2020 Big Nerd Ranch. All rights reserved.
//

import Foundation
import UIKit

class PhotosViewController: UIViewController , UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var store: PhotoStore!
    let photoDataSource = PhotoDataSource()
    
    override func viewDidLoad() {   
        super.viewDidLoad()
        
        collectionView.dataSource = photoDataSource
        collectionView.delegate = self
        
        updateDataSource()
        
        store.fetchInterestingPhotos {
            (photosResult) -> Void in
            
            self.updateDataSource()
            

        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let photo = photoDataSource.photos[indexPath.row]
        
        //Download the image data, which could take some time
        store.fetchImage(for: photo) { (result) -> Void in
            
            //The index path for the photo might have changed between the time the request started and finished, so find the most recent index path
            
            //(Note: You will have and error on the next line; you will fix it soon)
            guard let photoIndex = self.photoDataSource.photos.firstIndex(of: photo),
                case let .success(image) = result else {
                    return
            }
            let photoIndexPath = IndexPath(item: photoIndex, section: 0)
            
            //When the request finishes, only update the cell if it's still visible
            if let cell = self.collectionView.cellForItem(at: photoIndexPath) as? PhotoCollectionViewCell {
                cell.update(with: image)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showPhoto"?:
            if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
                
                let photo = photoDataSource.photos [selectedIndexPath.row]
                
                //Update viewCount property on the photo
                photo.viewCount += 1

                //Save updated viewCount    
                //Create reference to viewContext property on persistentContainer property of the PhotoStore
                let context = store.persistentContainer.viewContext
                
                context.perform {
                    
                    
                    do {
                        try context.save()
                    } catch let error {
                        print("Error saving viewCount for photo: (\(String(describing: photo.photoID))) ,error: (\(error)) ")
                    }
                }
                
                
                             
                let destinationVC = segue.destination as! PhotoInfoViewController
                destinationVC.photo = photo
                destinationVC.store = store
            }
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }
    
    private func updateDataSource() {
        store.fetchAllPhotos {
            (photoResult) in
            
            switch photoResult {
            case let .success(photos):
                self.photoDataSource.photos = photos
            case .failure:
                self.photoDataSource.photos.removeAll()
            }
            self.collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
    

}
