//
//  Module.swift
//  
//
//  Created by 张行 on 2020/8/21.
//

import UIKit

public protocol Module {
    /// 根据另外的模块传递的参数生成此模块的对象
    /// - Parameter parameter: 其他模块传递过来的参数
    /// - Returns: 此模块的实例
    static func make(_ parameter:[String:Any]) -> Module
    /// 模块对应的标识符
    static var identifier:String { get }
}

