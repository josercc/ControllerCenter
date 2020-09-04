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
    @available(*, deprecated, message: "将在2.0.0废弃 请替换为`make(_ modify:Modify) -> Module?`")
    static func make(_ parameter:[String:Any]) -> Module
    /// 根据另外模块传递过来的参数修改器生成模块对象 可以允许创建为空
    /// - Parameter modify: 参数修改器
    static func make(_ modify:Modify) -> Module?
    /// 模块对应的标识符
    static var identifier:String { get }
}

extension Module {
    static func make(_ modify:Modify) -> Module? {
        return self.make(modify.parameter)
    }
}


