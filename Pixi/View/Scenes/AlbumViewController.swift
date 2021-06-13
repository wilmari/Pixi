//
//  ViewController.swift
//  Pixi
//
//  Created by Maria Wilfling on 10.06.21.
//  Copyright © 2021 Maria Wilfling. All rights reserved.
//

import UIKit

class AlbumViewController: UIViewController {

    @IBOutlet private weak var collectionView: UICollectionView!
    
    private let albumManager = AlbumDataManager()
    private var albumDict: Dictionary<Int, PhotoAlbum> {
        return albumManager.albumStore.albums
    }
    
    private let albumsPerRow = 2
    private let padding: CGFloat = 20.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        albumManager.delegate = self
        albumManager.fetchAlbumData()
    }
}

//MARK: - Navigation
extension AlbumViewController {
    
    func showPhotosOfAlbum(id: Int) {
        if let _album = albumDict[id], let _photos = _album.photos {
            
            let pictureVC = storyboard?.instantiateViewController(identifier: "PictureViewController") as! PictureViewController
            
            pictureVC.photos = _photos
            pictureVC.albumTitle = _album.title
            pictureVC.albumId = _album.id
            
            self.present(pictureVC, animated: true, completion: nil)
        }
    }
}

//MARK: - UICollectionView Delegate & DataSource
extension AlbumViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
      return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let albumCount = albumDict.keys.count
        return albumCount
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: "AlbumCell",
          for: indexPath) as! AlbumCell
        
        if let album = albumDict[indexPath.item + 1] {
            cell.imageView.image = album.photos?.first?.thumbnail
            cell.titleLabel.text = album.title
            cell.pictureCountLabel.text = "\(album.photos?.count ?? 0)"
        }
            
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = padding
        let availableWidth = collectionView.frame.width - paddingSpace
        let albumWidth = availableWidth / CGFloat(albumsPerRow)
        
        return CGSize(width: albumWidth, height: albumWidth+85)
    }
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout:UICollectionViewLayout,insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
      return padding
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let album = albumDict[indexPath.item + 1] {
            
            // this album already has all the thumbnails downloaded
            if album.photos?.allSatisfy({$0.thumbnail != nil}) ?? false {
                showPhotosOfAlbum(id: album.id)
            } else {
                // fetch the thumbnails for this album
                albumManager.fetchAllThumbnailsForAlbum(id: album.id)
            }
        }
    }
}

//MARK: - AlbumDataManagerDelegate
extension AlbumViewController: AlbumDataManagerDelegate {
    
    func didFetchAlbumPhotoData() {

        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func didFetchAllThumbnailsForAlbum(id: Int) {
        
        showPhotosOfAlbum(id: id)
    }
    
    func didFailWithError(_ error: Error?) {
        
        print("--- ERROR: %@", error?.localizedDescription ?? "An error occured.")
        
        // display alert for the user
        let alert = UIAlertController(title: "Error", message: "Oops, something went wrong. Check your internet connection and try again.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Retry", style: UIAlertAction.Style.default, handler: { action in
            
            //try again
            self.albumManager.fetchAlbumData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

