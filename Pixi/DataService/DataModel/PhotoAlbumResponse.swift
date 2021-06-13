//
//  PhotoAlbum.swift
//  Pixi
//
//  Created by Maria Wilfling on 10.06.21.
//  Copyright © 2021 Maria Wilfling. All rights reserved.
//

import Foundation


/// Represents the API response for a photo album
struct PhotoAlbumResponse: Decodable {
    
    let id: Int
    let title: String
}
