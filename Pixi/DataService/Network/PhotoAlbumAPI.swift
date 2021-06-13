//
//  PhotoAlbumEndpoint.swift
//  Pixi
//
//  Created by Maria Wilfling on 10.06.21.
//  Copyright © 2021 Maria Wilfling. All rights reserved.
//

import Moya

/// Collection of API requests to retrieve photo album data
public enum PhotoAlbumAPI {

    case albums
    case photoDataForAlbumId(Int)
    case imageFromUrl(String)
}

extension PhotoAlbumAPI: TargetType {
    
    public var baseURL: URL {
        switch self {
        case .albums, .photoDataForAlbumId:
            return URL(string: "https://jsonplaceholder.typicode.com")!
        case .imageFromUrl(let urlString) :
            return URL(string: urlString)!
        }
    }
    
    public var path: String {
        switch self {
        case .albums: return "/albums"
        case .photoDataForAlbumId(let id): return "/albums/\(id)/photos"
        case .imageFromUrl: return ""
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .albums: return .get
        case .photoDataForAlbumId: return .get
        case .imageFromUrl: return .get
        }
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var task: Task {
        return .requestPlain
    }
    
    public var headers: [String: String]? {
        switch self {
        case .albums, .photoDataForAlbumId:
            return ["Content-Type": "application/json"]
        case .imageFromUrl:
            return nil
        }
    }
    
    public var validationType: ValidationType {
        return .successCodes
    }
}
