//
//  Module.swift
//  
//
//  Created by 张行 on 2020/8/21.
//

import UIKit
/// 模块化协议
public protocol Module {
    /// 根据另外模块传递过来的参数创建对应模块对象
    /// - Parameter parameter: 参数
    static func make(module parameter:Parameter) throws -> Self
    /// 模块对应的标识符
    static var moduleIdentifier:Identifier { get }
}


extension Module {
    /// 标识符默认实现为模块的名字
    static var moduleIdentifier:Identifier { Identifier(self) }
}




