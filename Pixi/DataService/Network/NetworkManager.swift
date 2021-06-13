//
//  DataManager.swift
//  Pixi
//
//  Created by Maria Wilfling on 10.06.21.
//  Copyright © 2021 Maria Wilfling. All rights reserved.
//

import UIKit
import Moya


protocol Networkable {
    
    var provider: MoyaProvider<PhotoAlbumAPI> {get}
    
    func fetchAlbumData(completion: @escaping (Result<[PhotoAlbumResponse], Error>) -> ())
    func fetchPhotoDataForAlbum(id: Int, completion: @escaping (Result<[PhotoResponse], Error>) -> ())
    func fetchImageFromUrl(urlString: String, completion: @escaping (Result<Data, Error>) -> ())
}

/// Manages API requests and maps the response to data objects
struct NetworkManager: Networkable {
    
    var provider = MoyaProvider<PhotoAlbumAPI>()
    
    func fetchAlbumData(completion: @escaping (Result<[PhotoAlbumResponse], Error>) -> ()) {
        request(target: .albums, completion: completion)
    }
    
    func fetchPhotoDataForAlbum(id: Int, completion: @escaping (Result<[PhotoResponse], Error>) -> ()) {
        request(target: .photoDataForAlbumId(id), completion: completion)
    }
    
    func fetchImageFromUrl(urlString: String, completion: @escaping (Result<Data, Error>) -> ()) {
        provider.request(.imageFromUrl(urlString)) { result in
            switch result {
            case let .success(response):
                completion(.success(response.data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

private extension NetworkManager {
    private func request<T: Decodable>(target: PhotoAlbumAPI, completion: @escaping (Result<T, Error>) -> ()) {
        provider.request(target) { result in
            switch result {
            case let .success(response):
                do {
                    let results = try JSONDecoder().decode(T.self, from: response.data)
                    completion(.success(results))
                } catch let error {
                    completion(.failure(error))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
}
