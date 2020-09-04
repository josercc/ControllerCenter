//
//  Modify.swift
//  
//
//  Created by 张行 on 2020/8/21.
//

import UIKit

public struct Modify {
    /// 模块的标识符
    private let identifier:String
    /// 设置的模块局部参数
    var parameter:[String:Any] = [:]
    /// 模块弹出的类型
    private var modalPresentationStyle:UIModalPresentationStyle?
    /// 修改值之后通知回掉方法
    var modifyNoticeCompletionDic:[String:((Any?,Bool) -> Parameter)] = [:]
    /// 之前的模块标识符
    fileprivate var fromIdentifier:String?
    
    init(identifier:String) {
        self.identifier = identifier
    }
    
    private func module() -> Module? {
        guard let makeBlock = ControllerCenter.center.registerControllers[identifier] else {
            return nil
        }
        return makeBlock(self)
    }
    
    /// 获取前往模块的对象控制器
    /// - Returns: 控制器对象
    public func controller() -> UIViewController? {
        let controller = module() as? UIViewController
        controller?.modify = self
        return controller
    }
    
    /// Push跳转
    /// - Parameters:
    ///   - navigationController: 需要执行跳转的导航控制器
    ///   - animated: 是否有动画
    public func push(in navigationController:UINavigationController?, animated:Bool) {
        guard let viewController = self.controller() else {
            return
        }
        navigationController?.pushViewController(viewController, animated: animated)
    }
    
    /// 模态弹出
    /// - Parameters:
    ///   - presentController: 需要执行模态弹出的控制器
    ///   - animated: 是否有动画
    ///   - completion: 执行完毕动画
    public func present(in presentController:UIViewController?, animated:Bool, completion:(() -> Void)?) {
        guard let viewController = self.controller() else {
            return
        }
        if let modalPresentationStyle = self.modalPresentationStyle {
            viewController.modalPresentationStyle = modalPresentationStyle
        }
        presentController?.present(viewController, animated: animated, completion: completion)
    }
}

extension Modify {
    /// 添加前往模块的参数 使用最新的`parameter(key: , block: )`
    /// - Parameters:
    ///   - key: 参数对应的唯一Key
    ///   - value: 参数对应的值可以允许为空
    ///   - from: 上一个模块来源 默认不设置 如果设置如果上个模块不对应则无法赋值
    /// - Returns: 模块修改器
    @available(*,deprecated,message: "Please use other func `parameter(key: , block: )`")
    public func parameter<T:Any>(_ key:String, value:T?, from:String? = nil) -> Modify {
        guard let value = value else {
            return self
        }
        var modify = self
        if let from = from, let fromIdentifier = fromIdentifier, from == fromIdentifier  {
            modify.parameter[key] = value
        } else if from == nil {
            modify.parameter[key] = value
        }
        return modify
    }
    
    /// 设置参数
    /// - Parameters:
    ///   - key: 参数对应的Key
    ///   - from: 上一个模块来源 默认不设置 如果设置如果上个模块不对应则无法赋值
    ///   - block: 设置的回掉
    /// - Returns: 模块修改器
    public func parameter(key:String, from:String? = nil, block:@escaping((Parameter) -> Parameter)) -> Modify {
        var modify = self
        let modifyNoticeBlock:((Any?,Bool) -> Parameter) = { newValue,isNewValue in
            let parameter = block(Parameter(key: key, value: newValue, isNewValue: isNewValue, from: from))
            return parameter
        }
        modify.modifyNoticeCompletionDic[key] = modifyNoticeBlock
        return parameter(key, value: block(Parameter(key: key, value: nil, isNewValue: false, from: from)), from: from)
    }
    
    /// 设置来源模块标识符
    /// - Parameter identifier: 模块标识符
    /// - Returns: 修改器
    public func from(_ identifier:String) -> Modify {
        var modify = self
        modify.fromIdentifier = identifier
        return modify
    }
    /// 设置模态弹出的样式
    /// - Parameter style: 模态的样式
    /// - Returns: 模块修改器
    public func modalPresentationStyle(_ style:UIModalPresentationStyle) -> Modify {
        var modify = self
        modify.modalPresentationStyle = style
        return modify
    }
}

extension Modify {
    /// 调用参数
    public struct Parameter {
        /// 参数的Key
        let key:String
        /// 参数当前的值
        let value:Any?
        /// 是否是一个全新的值
        let isNewValue:Bool
        /// 来源的模块
        let from:String?
        
        /// 设置参数的值 用于只读参数
        /// - Parameter value: 最新参数的值
        /// - Returns: 参数结构体
        public func parameter<T:Any>(value:T?) -> Parameter {
            return Parameter(key: self.key, value: value, isNewValue: false, from: self.from)
        }
        
        /// 设置参数的值 用于可以修改的参数 如果修改的是可选值请使用`parameter(modifyOptional:)`
        /// - Parameter value: 可以被修改的值
        /// - Returns: 参数结构体
        public func parameter<T:Any>(modify value:inout T) -> Parameter {
            if self.isNewValue {
                if let newValue = self.value, let _newValue = newValue as? T {
                    value = _newValue
                } else {
                    assert(false, "If you want to set to nil, use the parameter(modifyOptional:) method")
                }
            }
            return parameter(value: value)
        }
        
        /// 设置参数的值 用于可以修改可选值的参数
        /// - Parameter value: 可以被修改的值
        /// - Returns: 参数的结构体
        public func parameter<T:Any>(modifyOptional value:inout T?) -> Parameter {
            if self.isNewValue {
                if let newValue = self.value, let _newValue = newValue as? T {
                    value = _newValue
                } else {
                    value = nil
                }
            }
            return parameter(value: value)
        }
        
    }
}

extension Modify {
    /// 获取全局函数返回可选值
    /// - Parameter key: 参数对应的key
    /// - Returns: 返回类型的可选值
    public func get<T>(globaleParameter key:String) -> T? {
        assert(self.modifyNoticeCompletionDic.keys.contains(key), "\(key)没有提前进行设置获取失败 请进行设置")
        let value:T? = self.parameter[key] as? T
        guard let block = self.modifyNoticeCompletionDic[key] else {
            return value
        }
        return block(value,false).value as? T
    }
    /// 获取全局参数
    /// - Parameter key: 参数对应的key
    /// - Parameter default: 默认值
    /// - Returns: 对应类型的值
    public func get<T>(globaleParameter key:String, default:T) -> T {
        return get(globaleParameter: key) ?? `default`
    }
    
    /// 更新全局参数
    /// - Parameters:
    ///   - key: 全局参数的Key
    ///   - value: 更新的值
    public mutating func update(globaleParameter key:String, value:Any?) {
        guard let block = self.modifyNoticeCompletionDic[key] else {
            return
        }
        let parameter = block(value,true)
        self.parameter[key] = parameter.value
    }
}


extension Module {
    /// 通过调用模块生成前往模块的修改器为了可以获取上个模块的标识符
    /// - Parameter identifier: 前往模块的标识符
    /// - Returns: 修改器
    public static func make(_ identifier:String) -> Modify {
        var modify = Modify(identifier: identifier)
        modify.fromIdentifier = self.identifier
        return modify
    }
}



