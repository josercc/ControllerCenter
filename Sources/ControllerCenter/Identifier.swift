//
//  Identifier.swift
//  
//
//  Created by joser on 2021/7/23.
//

import Foundation
/// 模块的唯一标识符
public struct Identifier {
    /// 标识符的字符串
    let value:String
    
    /// 初始化唯一标识符 指定字符串初始化
    /// - Parameter value: 标识符字符串
    public init(_ value:String) {
        self.value = value
    }
    
    /// 初始化唯一标识符 指定模块类型作为唯一标识符
    /// - Parameter model: 模块类型
    public init<M:Module>(_ model:M.Type) {
        self.value = "\(M.self)"
    }
}
