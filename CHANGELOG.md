# 版本说明

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

