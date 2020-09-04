# 版本说明

## 1.6.0版本

🟢 新增 Dictionary -> Decodable  `func toDecodable<T:Decodable>() -> T?`

🟢 新增 Encodable ->  Dictionary `public func toMap() -> [String:Any]? `

🟢 新增获取值没有设置断言报错 提前发现问题

🟢 新增一个全新Module协议方法`make(_ modify:Modify) -> Module?`替换之前`make(_ parameter:[String:Any]) -> Module`

## 1.5.0版本

1 修复了模块传递参数使用最新方法不生效
2 新增UIViewController实例可以调用获取传递参数的方法 修改参数的方法

## 1.4.0版本

废弃了之前设置全局变量方法

新增全局变量方法支持修改外部变量

## 1.3.0版本

修改获取方法设置为可以获取可选参数和确定参数

## 1.2.3版本

修复全局变量只能设置一次BUG

## 1.2.2版本

修改获取方法分为两种

## 1.2.1版本

修复了`1.2.0`编译问题

## 1.2.0版本

新增设置和获取全局参数的方法

```swift
/// 设置全局参数
/// - Parameter block: 设置全局修改器的回掉
public mutating mutating func set(globaleParameter block: @escaping ((Modify) -> Modify))

/// 获取全局参数
/// - Parameter key: 参数对应的key
/// - Parameter default: 默认值
/// - Returns: 对应类型的值
public func get<T>(globaleParameter key: String, default: T? = nil) -> T?
```



## 1.1.0版本

新增了在注册模块时候可以修改调用模块的参数

```swift
/// 注册对应的模块
/// - Parameter controllerType: 模块视图类型
/// - Parameter block: 可以模块跳转之前在App内部重新修改设置的参数
public mutating mutating func register<T>(_ controllerType: T.Type, customModify block: ((Modify) -> Modify)? = nil) where T : ControllerCenter.Module
```

Module新增创建Modify快捷方法

```swift
extension Module {

    /// 通过调用模块生成前往模块的修改器为了可以获取上个模块的标识符
    /// - Parameter identifier: 前往模块的标识符
    /// - Returns: 修改器
    public static func make(_ identifier: String) -> Modify
}
```

Modify新增添加来源模块

```swift
/// 设置来源模块标识符
/// - Parameter identifier: 模块标识符
/// - Returns: 修改器
public func from(_ identifier: String) -> Modify
```

