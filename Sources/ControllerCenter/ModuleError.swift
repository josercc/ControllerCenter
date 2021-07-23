//
//  ModuleError.swift
//  
//
//  Created by joser on 2021/7/23.
//

import Foundation

/// 注册模块和初始化模块的异常错误
public enum ModuleError: Error {
    /// 模块还没注册
    case notRegister
    /// 对应值没有设置
    case valueNotSet
    /// 值类型不正确
    case valueTypeWrong
}
