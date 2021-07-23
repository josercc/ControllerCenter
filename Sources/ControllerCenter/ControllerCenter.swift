import UIKit

/// 便捷的获取路由中心
public let CC = ControllerCenter.center
/// 模块化路由中心
public class ControllerCenter {
    /// 获取一个全局的模块转发器
    public static var center = ControllerCenter()
    /// 已经注册的模块列表
    private var registerModuleMap:[String:MakeModuleHandle] = [:]
    
    /// 注册模块
    /// - Parameter model: 模块的类型
    /// - Parameter identifier: 模块的唯一标识符 默认为模块的`moduleIdentifier`
    /// - Parameter parameterHandle: 重写模块跳转参数
    public func register<M:Module>(model:M.Type,
                                   identifier:Identifier = M.moduleIdentifier,
                                   parameterHandle:CustomParameterHandle? = nil) {
        let handle:MakeModuleHandle = {
            let parameter:Parameter
            if let parameterHandle = parameterHandle {
                parameter = parameterHandle($0)
            } else {
                parameter = $0
            }
            return try M.make(module: parameter)
        }
        self.registerModuleMap[identifier.value] = handle
    }
    
    /// 通过标识符和参数创建一个模块实例
    /// - Parameters:
    ///   - identifier: 标识符
    ///   - parameter: 参数
    /// - Throws: 创建实例抛出异常
    /// - Returns: 模块实例
    public func make(with identifier:Identifier,
                     parameter:Parameter) throws -> Module {
        guard let handle = self.registerModuleMap[identifier.value] else {
            assertionFailure("\(identifier.value) 模块还没注册")
            throw ModuleError.notRegister
        }
        return try handle(parameter)
    }
    

    /// 注册组件闭包数组
    private var registerComponmentsMethodMap:[String:RegisterComponentsMethodHandle<Any,Any>] = [:]
    
    /// 注册一个组件
    /// - Parameters:
    ///   - identifier: 组件的唯一标识符
    ///   - method: 组件的方法
    ///   - handle: 调用组件的回掉
    public func register<T:Any>(identifier:String,
                                method:String = "_",
                                parse:T.Type,
                                handle:@escaping RegisterComponentsMethodHandle<T,Any>) {
        let registerHandle:((Any?,ExecuteComponentsMethodHandle<Any>?) -> Void) = { data, anyExecuteHandle in
            if let data = data {
                assert(data is T)
            }
            handle(data as? T,anyExecuteHandle)
        }
        let componentsMethodName = methodName(identifier: identifier, method: method)
        assert(!self.registerComponmentsMethodMap.keys.contains(componentsMethodName),"组件\(identifier) 方法\(method)已经被注册！")
        print("register \(componentsMethodName) successful!")
        self.registerComponmentsMethodMap[componentsMethodName] = registerHandle
    }
    
    /// 发送一个方法到组件
    /// - Parameters:
    ///   - identifier: 注册组件的唯一标识符
    ///   - method: 注册组件的方法名称
    ///   - parameter: 执行组件方法的参数
    ///   - handle: 执行方法的回掉方法
    public func send<M:Any>(identifier:String,
                            method:String = "_",
                            parameter:Any? = nil,
                            parse:M.Type,
                            handle:ExecuteComponentsMethodHandle<M>?) {
        let componentsMethodName = methodName(identifier: identifier, method: method)
        assert(self.registerComponmentsMethodMap.keys.contains(componentsMethodName),"组件\(identifier) 方法\(method)还没有注册！")
        print("send \(componentsMethodName) successful!")
        let registerHandle:((Any?,ExecuteComponentsMethodHandle<Any>?) -> Void)? = self.registerComponmentsMethodMap[componentsMethodName]
        registerHandle?(parameter, { data in
            if let data = data {
                assert(data is M)
            }
            handle?(data as? M)
        })
    }
    
    /// 获取组件的方法名称
    /// - Parameters:
    ///   - identifier: 组件注册的标识符
    ///   - method: 注册组件的名称
    /// - Returns: 组件的方法名称
    private func methodName(identifier:String, method:String) -> String {
        return "[\(identifier)]:[\(method)]"
    }

}

/// 定义闭包
public extension ControllerCenter {
    /// 自定义参数
    /// - Parameter parameter: 调用模块原始参数信息
    typealias CustomParameterHandle = (_ parameter:Parameter) -> Parameter
    /// 通过参数生成一个模块实例
    /// - Parameter parameter: 参数
    typealias MakeModuleHandle = (_ parameter:Parameter) throws -> Module
    /// 执行组件方法之后的回掉
    /// - Parameters data: 回掉的数据
    typealias ExecuteComponentsMethodHandle<M> = (_ data:M?) -> Void
    /// 注册组件方法的回掉
    /// - Parameters data: 注册回掉的参数
    /// - Parameters result: 执行组件方法的回掉闭包
    typealias RegisterComponentsMethodHandle<T,M> = (_ data:T?, _ result:ExecuteComponentsMethodHandle<M>?) -> Void
}
