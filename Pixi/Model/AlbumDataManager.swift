//
//  AlbumManager.swift
//  Pixi
//
//  Created by Maria Wilfling on 10.06.21.
//  Copyright © 2021 Maria Wilfling. All rights reserved.
//

import UIKit

protocol AlbumDataManagerDelegate {
    
    func didFetchAlbumPhotoData()
    func didFetchAllThumbnailsForAlbum(id: Int)
    func didFailWithError(_: Error?)
}

class AlbumDataManager {
    
    private let networkManager = NetworkManager()
    private let photoDataDispatchGroup = DispatchGroup()
    private let thumbnailDipatchGroup = DispatchGroup()
    private let albumThumbnailDispatchGroup = DispatchGroup()
    
    var delegate: AlbumDataManagerDelegate?
    
    var albumStore = AlbumStore.sharedInstance
    
    
    /// Fetches the album data JSON and adds the album objects to the storage
    /// If successfull triggers fetching the photo data JSON
    func fetchAlbumData() {
        networkManager.fetchAlbumData { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let albumData):
                strongSelf.albumStore.addAlbumsFrom(albumData)
                //after album data is fetched, start fetching the photo data
                strongSelf.fetchPhotoDataForAllAlbums()
            case .failure(let error):
                strongSelf.delegate?.didFailWithError(error)
            }
        }
    }

    /// Triggers fetching the photo data JSON for each album
    /// If successfull triggers fetching the first thumbnail images of each album
    func fetchPhotoDataForAllAlbums() {
        
        for id in albumStore.albums.keys.sorted() {
            
            photoDataDispatchGroup.enter()
            fetchPhotoDataForAlbum(id: id)
        }
        
        photoDataDispatchGroup.notify(queue: .main) {
            // after photo data is fetched, start fetching the first thumbnail for each album
            self.fetchFirstThumbnailForAllAlbums()
        }
    }
    
    
    /// Fetches the photo data JSON for exactly one album and adds the photo objects to the album in the storage
    /// - Parameter albumId: The id of the album whoose photos should be loaded
    func fetchPhotoDataForAlbum(id albumId: Int) {
        
        networkManager.fetchPhotoDataForAlbum(id: albumId, completion: { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let photos):
                strongSelf.albumStore.addPhotosFrom(photos, toAlbum: albumId)
                strongSelf.photoDataDispatchGroup.leave()
            case .failure(let error):
                strongSelf.delegate?.didFailWithError(error)
            }
        })
    }
    
    /// Fetches the photo data JSON for exactly one album and adds the photo objects to the album in the storage
    func fetchFirstThumbnailForAllAlbums() {
        
        for id in albumStore.albums.keys.sorted() {
            
            thumbnailDipatchGroup.enter()
            fetchFirstThumbnailForAlbum(id: id)
        }
        
        thumbnailDipatchGroup.notify(queue: .main) {
            self.delegate?.didFetchAlbumPhotoData()
        }
    }
    
    /// Fetches the first thumbnail image for exactly one album and adds the image data to the storage
    /// - Parameter albumId: The album for whoose thumbnail image should be fetched
    func fetchFirstThumbnailForAlbum(id albumId: Int) {
        
        let album = albumStore.albums[albumId]
        
        if let photos = album?.photos, let firstPicture = photos.first {
            
            if let _ = firstPicture.thumbnail {
                // picture already exists
            } else {
                networkManager.fetchImageFromUrl(urlString: firstPicture.thumbnailUrl, completion: {[weak self] result in
                    guard let strongSelf = self else { return }
                    switch result {
                    case .success(let photoData):
                        if let image = UIImage(data: photoData) {
                            strongSelf.albumStore.addPhoto(image, photoId: firstPicture.id, toAlbum: albumId, thumbnail: true)
                            strongSelf.thumbnailDipatchGroup.leave()
                        } else {
                            strongSelf.delegate?.didFailWithError(nil)
                        }
                        
                    case .failure(let error):
                        strongSelf.delegate?.didFailWithError(error)
                    }
                })
            }
        }
    }
    
    /// Triggers fetching all thumbnail images of exactly one album
    /// - Parameter id: The album whoose thumbnail images should be fetched
    func fetchAllThumbnailsForAlbum(id: Int) {
        
        guard let album = albumStore.albums[id], let photos = album.photos else {return}
        
        for photo in photos {
            if photo.thumbnail == nil {
                albumThumbnailDispatchGroup.enter()
                fetchThumbnailImageFromUrl(urlString: photo.thumbnailUrl, albumId: id, photoId: photo.id)
            }
        }
        
        albumThumbnailDispatchGroup.notify(queue: .main) {
            self.delegate?.didFetchAllThumbnailsForAlbum(id: id)
        }
    }
    
    
    /// Fetches a thumbnail image and adds the data to the storage
    /// - Parameters:
    ///   - urlString: The url string of the image to fetch
    ///   - albumId: The album the image belongs to
    ///   - photoId: The photo object (id)  the image belongs to
    func fetchThumbnailImageFromUrl(urlString: String, albumId: Int, photoId:Int) {
        
        networkManager.fetchImageFromUrl(urlString: urlString, completion: { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let photoData):
                if let image = UIImage(data: photoData) {
                    strongSelf.albumStore.addPhoto(image, photoId: photoId, toAlbum: albumId, thumbnail: true)
                    strongSelf.albumThumbnailDispatchGroup.leave()
                } else {
                    strongSelf.delegate?.didFailWithError(nil)
                }
                
            case .failure(let error):
                strongSelf.delegate?.didFailWithError(error)
            }
        })
    }
}
