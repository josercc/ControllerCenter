//
//  Modify.swift
//  
//
//  Created by 张行 on 2020/8/21.
//

import UIKit

public struct Modify {
    private let identifier:String
    private var parameter:[String:Any] = [:]
    private var modalPresentationStyle:UIModalPresentationStyle?
    init(identifier:String) {
        self.identifier = identifier
    }
    
    private func module() -> Module? {
        guard let makeBlock = ControllerCenter.center.registerControllers[identifier] else {
            return nil
        }
        return makeBlock(parameter)
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
    /// - Returns: 模块修改器
    public func parameter(_ key:String, value:Any?) -> Modify {
        guard let value = value else {
            return self
        }
        var modify = self
        modify.parameter[key] = value
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
