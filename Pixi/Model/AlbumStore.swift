//
//  Album.swift
//  Pixi
//
//  Created by Maria Wilfling on 13.06.21.
//  Copyright © 2021 Maria Wilfling. All rights reserved.
//

import UIKit


/// Stores and organizes the album data
class AlbumStore {
    
    static let sharedInstance: AlbumStore = {
        let instance = AlbumStore()
        // setup code
        return instance
    }()
    
    var albums = Dictionary<Int, PhotoAlbum>()
    
    private init() {}
    
    
    
    /// Transforms the response data into album objects and adds them into the data structure
    /// - Parameter albumData: The decoded response data from the API request
    func addAlbumsFrom(_ albumData: [PhotoAlbumResponse]) {
        
        for album in albumData {
            self.albums[album.id] = PhotoAlbum(id: album.id, title: album.title, photos: nil)
        }
    }
    
    /// Transforms the response data into photo objects and adds them into the data structure
    /// - Parameters:
    ///   - photoData: The decoded response data from the API request
    ///   - id: The album to which the photo objects should be added
    func addPhotosFrom(_ photoData: [PhotoResponse], toAlbum id: Int) {
        
        if self.albums[id]?.photos == nil && photoData.count > 0 {
            self.albums[id]?.photos = [Photo]()
        }
        
        for photo in photoData {
            
            let newPhoto = Photo(id: photo.id, title: photo.title, image: nil, imageUrl: photo.url, thumbnail: nil, thumbnailUrl: photo.thumbnailUrl)
            
            self.albums[id]?.photos?.append(newPhoto)
        }
    }
    
    
    /// Adds the image from the API request into the data structure
    /// - Parameters:
    ///   - image: The image that was loaded from the API request
    ///   - photoId: The photo object to which the image should be added
    ///   - albumId: The album object to which the image belongs to
    ///   - thumbnail: Use 'true' if the image should be added as the thumbnail image. Use 'false' if the image should be added as large image.
    func addPhoto(_ image: UIImage, photoId:Int, toAlbum albumId: Int, thumbnail: Bool) {
        
        guard let _ = self.albums[albumId], let _ = self.albums[albumId]!.photos else {return}
        
        if let i = self.albums[albumId]!.photos!.firstIndex(where: { $0.id == photoId }) {
            if thumbnail {
                self.albums[albumId]!.photos![i].thumbnail = image
            } else {
                self.albums[albumId]!.photos![i].image = image
            }
        }
    }
}
