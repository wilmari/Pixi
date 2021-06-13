//
//  PhotoAlbum.swift
//  Pixi
//
//  Created by Maria Wilfling on 11.06.21.
//  Copyright © 2021 Maria Wilfling. All rights reserved.
//

import Foundation

/// Represents a photo album object
struct PhotoAlbum {
    
    let id: Int
    let title: String
    var photos: [Photo]?
}
