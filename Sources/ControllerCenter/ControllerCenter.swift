import UIKit
public struct ControllerCenter {
    /**
     创建一个模块的回掉代理
     - parameter modify:模块配置
     - returns: 返回该模块的实例对象
     */
    internal typealias MakeControllerBlock = ((_ modify:Modify) -> Module)
    /// 获取一个全局的模块转发器
    public static var center = ControllerCenter()
    /// 储存已经注册模块的回掉
    internal var registerControllers:[String:MakeControllerBlock] = [:]
    /// 储存全局参数设置
    internal var globaleParameterModifyBlock:((Modify) -> Modify)?
    /// 全局参数通过其他模块已经进行修改的回掉
    var globaleParameterModifyDidChangedBlock:((Modify) -> Void)?
    /// 获取最新的全局修改器
    var globaleParameterModify:Modify {
        if let block = globaleParameterModifyBlock {
            return block(_tempModify)
        }
        return _tempModify
    }
    /// 一个可以临时修改的全局修改器
    var _tempModify:Modify = Modify(identifier: "ControllerCenter")
    
    /// 注册对应的模块
    /// - Parameter controllerType: 模块视图类型
    /// - Parameter block: 可以模块跳转之前在App内部重新修改设置的参数
    public mutating func register<T:Module>(_ controllerType:T.Type, customModify block:((Modify) -> Modify)? = nil) {
        let block:((Modify) -> Module) = { modify in
            if let block = block {
                if let module = T.make(block(modify)) {
                    return module
                } else {
                    return T.make(block(modify).parameter)
                }
            } else {
                if let module = T.make(modify) {
                    return module
                } else {
                    return T.make(modify.parameter)
                }
            }
        }
        self.registerControllers[T.identifier] = block
    }
    
    /// 设置全局参数
    /// - Parameter block: 设置全局修改器的回掉
    public mutating func set(globaleParameter block:@escaping((Modify) -> Modify)) {
        globaleParameterModifyBlock = block
    }
    
    /// 监听全局函数值已经发生了改变
    /// - Parameter block: 发生改变的回掉
    @available(*,deprecated,message: "Please use other func `parameter(key: , block: )`动态修改 不需要监听")
    public mutating func listen(globaleParameterChanged block:@escaping((Modify) -> Void)) {
        globaleParameterModifyDidChangedBlock = block
    }
    
}

extension ControllerCenter: ModifyParameter {
    public func get<T>(globaleParameter key: String) -> T? {
        return globaleParameterModify.get(globaleParameter: key)
    }
    
    public func get<T>(globaleParameter key: String, default: T) -> T {
        return globaleParameterModify.get(globaleParameter: key, default: `default`)
    }
    
    public mutating func update(globaleParameter key: String, value: Any?) {
        _tempModify.update(globaleParameter: key, value: value)
        globaleParameterModifyDidChangedBlock?(_tempModify)
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
