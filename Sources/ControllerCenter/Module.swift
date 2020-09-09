//
//  Module.swift
//  
//
//  Created by 张行 on 2020/8/21.
//

import UIKit

public protocol ModifyModule {
    /// 根据另外模块传递过来的参数修改器生成模块对象 可以允许创建为空
    /// - Parameter modify: 参数修改器
    static func make(_ modify:Modify) -> ModifyModule?
    /// 模块对应的标识符
    static var identifier:String { get }
}



