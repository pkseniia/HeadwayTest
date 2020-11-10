//
//  HTTPClient.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 10.11.2020.
//

import Foundation
import RxSwift
import RxCocoa

protocol HTTPClientProvider {
    func get(url: String, token: String) -> Observable<Data?>
    func post(url: String, params: [String: Any], base64Credentials: String?) -> Observable<Data?>
}

final class HTTPClient: HTTPClientProvider {
    func get(url: String, token: String) -> Observable<Data?> {
        guard let url = URL(string: url) else { return Observable.empty() }
        var request = URLRequest(url: url)
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.rx.data(request: request)
            .map { Optional.init($0) }
            .catchErrorJustReturn(nil)
    }
    
    func post(url: String, params: [String: Any], base64Credentials: String? = nil) -> Observable<Data?> {
        guard let url = URL(string: url) else { return Observable.empty() }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        if let encodedCreds = base64Credentials {
            request.setValue("Basic \(encodedCreds)", forHTTPHeaderField: "Authorization")
        }
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let jsonData = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        request.httpBody = jsonData
        return URLSession.shared.rx.data(request: request)
            .map { Optional.init($0) }
            .catchError { (error) -> Observable<Data?> in
                throw error
            }
    }
}
