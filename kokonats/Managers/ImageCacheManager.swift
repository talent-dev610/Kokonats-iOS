////  ImageCacheManager.swift
//  kokonats
//
//  Created by sean on 2021/11/03.
//  
//

import Foundation

final class ImageCacheManager {
    static var shared = ImageCacheManager()
    private let urlSession: URLSession

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.urlSession = URLSession(configuration: configuration)
    }

    func loadImage(urlString: String, completion: @escaping (Result<Data, CommonError>) -> Void){
        //TODO: check local file storage first.

        let url = URL(string: urlString)!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(.failure(.connectionFailure))
                Logger.debug("failed to load image data.")
                return
            }

            guard let data = data,
                  let response = response as? HTTPURLResponse else {
                return
            }

            completion(.success(data))
        }

        task.resume()
    }

}
