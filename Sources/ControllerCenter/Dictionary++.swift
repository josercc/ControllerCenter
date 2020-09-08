//
//  Dictionary++.swift
//  
//
//  Created by 张行 on 2020/9/4.
//

import Foundation

extension Dictionary {
    public func toDecodable<T:Decodable>() -> T? {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: .fragmentsAllowed),
            let decodable = try? JSONDecoder().decode(T.self, from: data) else {
            return nil
        }
        return decodable
    }
}
