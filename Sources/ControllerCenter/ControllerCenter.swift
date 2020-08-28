import UIKit
public struct ControllerCenter {
    /**
     创建一个模块的回掉代理
     - parameter modify:模块配置
     - returns: 返回该模块的实例对象
     */
    internal typealias MakeControllerBlock = ((_ modify:Modify) -> Module)
    public static var center = ControllerCenter()
    /// 储存已经注册模块的回掉
    internal var registerControllers:[String:MakeControllerBlock] = [:]
    /// 储存全局参数
    internal var globalModify:Modify = Modify(identifier: "ControllerCenter")
    /// 注册对应的模块
    /// - Parameter controllerType: 模块视图类型
    /// - Parameter block: 可以模块跳转之前在App内部重新修改设置的参数
    public mutating func register<T:Module>(_ controllerType:T.Type, customModify block:((Modify) -> Modify)? = nil) {
        let block:((Modify) -> Module) = { modify in
            if let block = block {
                return T.make(block(modify).parameter)
            } else {
                return T.make(modify.parameter)
            }
        }
        self.registerControllers[T.identifier] = block
    }
    
    /// 设置全局参数
    /// - Parameter block: 设置全局修改器的回掉
    public mutating func set(globaleParameter block:@escaping((Modify) -> Modify)) {
        globalModify = block(globalModify)
    }
    
    /// 获取全局参数
    /// - Parameter key: 参数对应的key
    /// - Parameter default: 默认值
    /// - Returns: 对应类型的值
    public func get<T>(globaleParameter key:String, default:T? = nil) -> T? {
        return globalModify.parameter[key] as? T ?? `default``
    }
}

extension ControllerCenter {
    /// 创建一个前往模块修改器
    /// - Parameter identifier: 前往模块的标识符
    /// - Returns: 模块修改器
    public static func make(_ identifier:String) -> Modify {
        return Modify(identifier: identifier)
    }
}
