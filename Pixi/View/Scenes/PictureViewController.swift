//
//  PictureViewController.swift
//  Pixi
//
//  Created by Maria Wilfling on 10.06.21.
//  Copyright © 2021 Maria Wilfling. All rights reserved.
//

import UIKit

class PictureViewController: UIViewController {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var pictureCountLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private let photosPerRow = 5
    private let padding: CGFloat = 2
    
    private let pictureDataManager = PictureDataManager()
    
    var photos = [Photo]()
    var albumId = 0
    var albumTitle = String()
    
        
    var largePhotoIndexPath: IndexPath? {
      didSet {
        var indexPaths: [IndexPath] = []
        if let largePhotoIndexPath = largePhotoIndexPath {
          indexPaths.append(largePhotoIndexPath)
        }

        if let oldValue = oldValue {
          indexPaths.append(oldValue)
        }
        collectionView.performBatchUpdates({
          self.collectionView.reloadItems(at: indexPaths)
        }) { _ in
          if let largePhotoIndexPath = self.largePhotoIndexPath {
            self.collectionView.scrollToItem(at: largePhotoIndexPath,
                                             at: .centeredVertically,
                                             animated: true)
          }
        }
      }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel.text = albumTitle
        self.pictureCountLabel.text = String(photos.count)
                
        collectionView.delegate = self
        collectionView.dataSource = self
        
        pictureDataManager.delegate = self
    }
}

//MARK: - UICollectionView Delegate & DataSource
extension PictureViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
      return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: "PhotoCell",
          for: indexPath) as! PhotoCell
        
        let photo = photos[indexPath.item]
        
        if indexPath != largePhotoIndexPath {
            
             cell.imageView.image = photo.thumbnail
        } else {
            
            if let image = photo.image {
                cell.imageView.image = image
            } else {
                cell.imageView.image = photo.thumbnail
                //fetch image if it doesn't exist yet
                pictureDataManager.fetchImageFromUrl(urlString: photo.imageUrl, albumId: albumId, photoId: photo.id)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath == largePhotoIndexPath {
            let size = collectionView.bounds.size
            return CGSize(width: size.width, height: size.width)
        }
        
        let availableWidth = collectionView.frame.width - (padding * CGFloat(photosPerRow - 1))
        let photoWidth = availableWidth / CGFloat(photosPerRow)

        return CGSize(width: photoWidth, height: photoWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout:UICollectionViewLayout,insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return padding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return padding
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                 shouldSelectItemAt indexPath: IndexPath) -> Bool {
      if largePhotoIndexPath == indexPath {
        largePhotoIndexPath = nil
      } else {
        largePhotoIndexPath = indexPath
      }

      return false
    }
    
}

//MARK: - PictureDataManagerDelegate
extension PictureViewController: PictureDataManagerDelegate {
    
    func didFetchPhoto(id: Int, fromAlbum albumId: Int) {
        
        guard let cell = collectionView.cellForItem(at: largePhotoIndexPath!) as? PhotoCell else {return}
        guard let photos = pictureDataManager.albumStore.albums[albumId]?.photos else {return}
        guard let photo = photos.first(where: {$0.id == id}) else {return}
        
        cell.imageView.image = photo.image
    }
    
    func didFailWithError(_ error: Error?) {
        
        print("--- ERROR: %@", error?.localizedDescription ?? "An error occured.")
        
        // display alert for the user
        let alert = UIAlertController(title: "Error", message: "Oops, something went wrong. Check your internet connection and try again.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}


