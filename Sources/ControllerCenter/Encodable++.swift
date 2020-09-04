//
//  Encodable++.swift
//  
//
//  Created by 张行 on 2020/9/4.
//

import Foundation

extension Encodable {
    public func toMap() -> [String:Any]? {
        guard let data = try? JSONEncoder().encode(self),
            let map = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String:Any] else {
            return nil
        }
        return map
    }
}
