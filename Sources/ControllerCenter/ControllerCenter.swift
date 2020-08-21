import UIKit
public struct ControllerCenter {
    /**
     创建一个模块的回掉代理
     - parameter parameter:其他模块传递过来的参数
     - returns: 返回该模块的实例对象
     */
    internal typealias MakeControllerBlock = ((_ parameter:[String:Any]) -> Module)
    public static var center = ControllerCenter()
    /// 储存已经注册模块的回掉
    internal var registerControllers:[String:MakeControllerBlock] = [:]
    /// 注册对应的模块
    /// - Parameter controllerType: 模块视图类型
    public mutating func register<T:Module>(_ controllerType:T.Type) {
        let block = { parameter in
            return T.make(parameter)
        }
        self.registerControllers[T.identifier] = block
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
