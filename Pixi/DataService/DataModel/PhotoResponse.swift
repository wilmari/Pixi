//
//  Photo.swift
//  Pixi
//
//  Created by Maria Wilfling on 10.06.21.
//  Copyright © 2021 Maria Wilfling. All rights reserved.
//

import Foundation

/// Represents the API response for a photo
struct PhotoResponse: Codable {

    let id: Int
    let title: String
    let url: String
    let thumbnailUrl: String
}
