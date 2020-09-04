//
//  ModifyParameter.swift
//  
//
//  Created by 张行 on 2020/9/3.
//

import UIKit

public protocol ModifyParameter {
    /// 获取全局函数返回可选值
    /// - Parameter key: 参数对应的key
    /// - Returns: 返回类型的可选值
    func get<T>(globaleParameter key:String) -> T?
    /// 获取全局参数
    /// - Parameter key: 参数对应的key
    /// - Parameter default: 默认值
    /// - Returns: 对应类型的值
    func get<T>(globaleParameter key:String, default:T) -> T
    /// 更新全局参数
    /// - Parameters:
    ///   - key: 全局参数的Key
    ///   - value: 更新的值
    mutating func update(globaleParameter key:String, value:Any?)
}

extension UIViewController: ModifyParameter {
    struct ModifyParameterKey {
        static var modify = "modify"
    }
    public func get<T>(globaleParameter key: String) -> T? {
        return modify?.get(globaleParameter: key)
    }
    
    public func get<T>(globaleParameter key: String, default: T) -> T {
        return modify?.get(globaleParameter: key, default: `default`) ?? `default`
    }
    
    public func update(globaleParameter key: String, value: Any?) {
        modify?.update(globaleParameter: key, value: value)
    }
    
    var modify:Modify? {
        get {
            let modify = objc_getAssociatedObject(self, &ModifyParameterKey.modify) as? Modify
            assert(modify != nil, "禁止在<ModifyModule>协议方法和<UIViewController>初始化方法内部使用此属性")
            return modify
        }
        set {
            objc_setAssociatedObject(self, &ModifyParameterKey.modify, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}
