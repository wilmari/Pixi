//
//  PictureDataManager.swift
//  Pixi
//
//  Created by Maria Wilfling on 13.06.21.
//  Copyright © 2021 Maria Wilfling. All rights reserved.
//

import UIKit


protocol PictureDataManagerDelegate {
    
    func didFetchPhoto(id: Int, fromAlbum albumId: Int)
    func didFailWithError(_ error: Error?)
}

class PictureDataManager {
    
    private let networkManager = NetworkManager()
    
    var delegate: PictureDataManagerDelegate?
    
    var albumStore = AlbumStore.sharedInstance
    
    
    /// Fetches an image and adds the data to the storage
    /// - Parameters:
    ///   - urlString: The url string of the image to fetch
    ///   - albumId: The album the image belongs to
    ///   - photoId: The photo object (id)  the image belongs to
    func fetchImageFromUrl(urlString: String, albumId: Int, photoId:Int) {
        
        networkManager.fetchImageFromUrl(urlString: urlString, completion: { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let photoData):
                if let image = UIImage(data: photoData) {
                    strongSelf.albumStore.addPhoto(image, photoId: photoId, toAlbum: albumId, thumbnail: false)
                    strongSelf.delegate?.didFetchPhoto(id: photoId, fromAlbum: albumId)
                } else {
                    strongSelf.delegate?.didFailWithError(nil)
                }
                
            case .failure(let error):
                strongSelf.delegate?.didFailWithError(error)
            }
        })
    }
}
