//
//  Parameter.swift
//  
//
//  Created by 张行 on 2020/8/21.
//

import UIKit
/// 初始化模块的参数信息
public struct Parameter {
    /// 模块的标识符
    public let identifier:Identifier
    /// 设置的模块局部参数
    private var values:[String:Any] = [:]

    /// 初始化参数
    /// - Parameter identifier: 模块的唯一标识符
    public init(identifier:Identifier) {
        self.identifier = identifier
    }
    
    /// 添加属性
    /// - Parameters:
    ///   - value: 属性的值
    ///   - key: 属性的`Key`
    /// - Returns: `Parameter`
    public func set(value:Any,
                    for key:String) -> Self {
        var parameter = self
        parameter.values[key] = value
        return parameter
    }
    
    /// 获取一个值
    /// - Parameter key: 值对应的Key
    /// - Throws: 获取值失败 抛出异常
    /// - Returns: 对应的值
    public func get<T>(for key:String) throws -> T {
        guard let data = self.values[key] else {
            assertionFailure("\(key)的值没有设置")
            throw ModuleError.valueNotSet
        }
        guard let value = data as? T else {
            assertionFailure("当前值类型为\(type(of: data))")
            throw ModuleError.valueTypeWrong
        }
        return value
    }
    
}




