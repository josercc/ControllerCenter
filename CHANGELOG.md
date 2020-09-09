# 版本说明

## 2.0.0版本

去掉`1.0.0～2.0.0`版本之间废弃方法

新增`@Property`和`@propertyOptional`来声明可以被修改变量

## 1.8.4版本

🔴 修复了`func toDecodable<T:Decodable>() -> T?`没有放开的问题

⚠️ 如果通过参数设置回掉 如果设置和获取不是同一个类型则会报错

比如设置一个`@escaping`闭包，一个获取不是`@escaping`闭包则会报错

```swift
//🔴 错误
//设置
{ (completion:@escaping() -> Void)}
//获取
((() -> Void) -> Void)

//🟢 正确
//设置
{ (completion:@escaping() -> Void)}
//获取
((@escaping() -> Void) -> Void)
```

⚠️ 如果模块之间回掉互传模型参数会报错 请使用字典进行传递

```swift
//🔴 错误
//设置
.parameter(key: "deleteNoteBlock", block: {$0.parameter(value: {[weak self] (map:API.Optional.NoteDetail.Info.Model?) in
    guard let model = map else {
        return
    }
    self?.deleteNote(noteId: model.id)
})})
//获取
let deleteNoteBlock:((API.Optional.NoteDetail.Info.Model?) -> Void)? = modify.get(globaleOptionalParameter: "deleteNoteBlock")

//🟢 正确
//设置
.parameter(key: "deleteNoteBlock", block: {$0.parameter(value: {[weak self] (map:[String:Any]?) in
    guard let model:API.Optional.NoteDetail.Info.Model = map?.toDecodable() else {
        return
    }
    self?.deleteNote(noteId: model.id)
})})

// 获取
let deleteNoteBlock:((API.Optional.NoteDetail.Info.Model?) -> Void)? = { (model) in
    let block:(([String:Any]?) -> Void)? = modify.get(globaleOptionalParameter: "deleteNoteBlock")
    block?(model？.toMap())
}

```



## 1.8.3版本

🔴 修复了设置全局和获取全局参数错误

## 1.8.2版本

🔴 修复了设置`Modify`属性内部逻辑错误导致一直无法设置全局属性

## 1.8.1版本

🔴 修复之前版本代码对于最新`Module`协议报错

## 1.8.0版本

🟢 新增`Modify`可以获取不存在Key的方法

## 1.7.0版本

🟢新增协议`ModifyModule`替换掉`Module` `Module`从`1.7.0-2.0.0`之间废弃状态

## 1.6.1版本

🟡 修改设置值类型不对则断言报错
🔴 修复了获取模型时候没有优先用新方法的BUG

## 1.6.0版本

🟢 新增 Dictionary -> Decodable  `func toDecodable<T:Decodable>() -> T?`

🟢 新增 Encodable ->  Dictionary `func toMap() -> [String:Any]? `

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

