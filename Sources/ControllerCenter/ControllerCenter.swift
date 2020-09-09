import UIKit
public class ControllerCenter {
    /**
     创建一个模块的回掉代理
     - parameter modify:模块配置
     - returns: 返回该模块的实例对象
     */
    internal typealias MakeControllerBlock = ((_ modify:Modify) -> ModifyModule?)
    /// 获取一个全局的模块转发器
    public static var center = ControllerCenter()
    /// 储存已经注册模块的回掉
    internal var registerControllers:[String:MakeControllerBlock] = [:]
    /// 储存全局参数设置
    internal var globaleParameterModifyBlock:((Modify) -> Modify)?
    /// 全局参数通过其他模块已经进行修改的回掉
    var globaleParameterModifyDidChangedBlock:((Modify) -> Void)?
    /// 一个可以临时修改的全局修改器
    var _tempModify:Modify = Modify(identifier: "ControllerCenter")
    
    /// 注册对应的模块
    /// - Parameter controllerType: 模块视图类型
    /// - Parameter block: 可以模块跳转之前在App内部重新修改设置的参数
    public func register<T:ModifyModule>(_ controllerType:T.Type, customModify block:((Modify) -> Modify)? = nil) {
        let block:((Modify) -> ModifyModule?) = { modify in
            var _modify = modify
            if let block = block {
                _modify = block(_modify)
            }
            return T.make(_modify)
        }
        self.registerControllers[T.identifier] = block
    }
    
    /// 设置全局参数
    /// - Parameter block: 设置全局修改器的回掉
    public func set(globaleParameter block:@escaping((Modify) -> Modify)) {
        globaleParameterModifyBlock = block
    }

}

extension ControllerCenter: ModifyParameter {
    public func get<T>(globaleParameter key: String) -> T? {
        return globaleParameterModify(readOnlyKey: key).get(globaleParameter: key)
    }
    
    public func get<T>(globaleParameter key: String, default: T) -> T {
        return globaleParameterModify(readOnlyKey: key).get(globaleParameter: key, default: `default`)
    }
    
    public func update(globaleParameter key: String, value: Any?) {
        var _globaleParameterModify = globaleParameterModify(readOnlyKey: key)
        _globaleParameterModify.update(globaleParameter: key, value: value)
        _tempModify = _globaleParameterModify
    }
    
    func globaleParameterModify(readOnlyKey:String?) -> Modify {
        var modify = _tempModify
        modify.readOnlyKey = readOnlyKey
        if let block = globaleParameterModifyBlock {
            modify = block(modify)
        }
        return modify
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
