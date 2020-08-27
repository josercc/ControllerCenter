//
//  Modify.swift
//  
//
//  Created by 张行 on 2020/8/21.
//

import UIKit

public struct Modify {
    private let identifier:String
    var parameter:[String:Any] = [:]
    private var modalPresentationStyle:UIModalPresentationStyle?
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
        return module() as? UIViewController
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
    /// 添加前往模块的参数
    /// - Parameters:
    ///   - key: 参数对应的唯一Key
    ///   - value: 参数对应的值可以允许为空
    ///   - from: 上一个模块来源 默认不设置 如果设置如果上个模块不对应则无法赋值
    /// - Returns: 模块修改器
    public func parameter(_ key:String, value:Any?, from:String? = nil) -> Modify {
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
