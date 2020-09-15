![image-20200821184000857](https://gitee.com/joser_zhang/upic/raw/master/uPic/image-20200821184000857.png)

一个基于中心分发的模块化框架
[演示例子](https://github.com/josercc/Example)

> 这个框架核心在于`注册列表`和`分发中心`，在`App`内部完成所有模块的注册。
>
> 我们在`App`或者`模块内部`可以通过`分发中心`进行模块调用。

## 安装

```swift
.Package(url:"https://github.com/josercc/controllercenter.git", from:"2.0.0")
```

## 使用

### 注册模块

注册模块`A`/`B`/`C`

```swift
ControllerCenter.center.register(ModuleA.self)
ControllerCenter.center.register(ModuleB.self)
ControllerCenter.center.register(ModuleC.self)
```

### 模块转发和参数设置

#### Example1 

模态前往`模块A`并且设置`模块A`的`背景颜色`

```swift
ControllerCenter.make("ModuleA").parameter(key: "backgroundColor", block: {$0.parameter(value: UIColor.red)}).present(in: self, animated: true, completion: nil)
```

模块A的实现

```swift
/**
 标识符 ModuleA
 参数
    - parameter backgroundColor:背景颜色
 */
public class ModuleA: UIViewController, ModifyModule {
    public static func make(_ modify: Modify) -> ModifyModule? {
        let moduleA = ModuleA()
        if let backgroundColor:UIColor = modify.get(globaleOptionalParameter: "backgroundColor") {
            moduleA.backgroundColor = backgroundColor
        }
        return moduleA
    }
    
    public static var identifier: String = "ModuleA"
    private var backgroundColor:UIColor?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = self.backgroundColor
    }
}
```

#### Example2

`Push`前往`模块B`并且设置`模块B`的回掉，并且在`模块B`页面点击按钮前往`模块C`,设置`模块C`的`名称`

```swift
let modify = ControllerCenter.make("ModuleB").parameter(key: "didPushModuleCBlock", block: {$0.parameter(value: {
    print("didPushModuleCBlock")
})})
modify.push(in: self.navigationController, animated: true)
```

模块B的实现

```swift
/**
 标识符 ModuleB
 参数
    - parameter didPushModuleCBlock:(() -> Void) 点击前往ModuleC的回掉
 */
public class ModuleB: UIViewController, ModifyModule {
    public static func make(_ modify: Modify) -> ModifyModule? {
        let moduleB = ModuleB()
        moduleB.didPushModuleCBlock = modify.get(globaleOptionalParameter: "didPushModuleCBlock")
        return moduleB
    }
    
    private var didPushModuleCBlock:(() -> Void)?
    
    public static var identifier: String = "ModuleB"
    
    
    public override func viewDidLoad() {
        let pushButton = UIButton(type: .custom)
        pushButton.setTitle("前往ModuleC", for: .normal)
        pushButton.frame = CGRect(x: 0, y: 0, width: pushButton.intrinsicContentSize.width, height: pushButton.intrinsicContentSize.height)
        pushButton.addTarget(self, action: #selector(self.pushModuleC), for: .touchUpInside)
        pushButton.center = self.view.center
        self.view.addSubview(pushButton)
        self.view.backgroundColor = UIColor.green
    }
    
    @objc func pushModuleC() {
        didPushModuleCBlock?()
        let modify = ControllerCenter.make("ModuleC")
            .parameter(key: "name", block: {$0.parameter(value: "君赏")})
        modify.present(in: self, animated: true, completion: nil)
    }
    
}
```

模块C的实现

```swift
public class ModuleC: UIViewController, ModifyModule {
    public static func make(_ modify: Modify) -> ModifyModule? {
        let moduleC = ModuleC(name: modify.get(globaleOptionalParameter: "name"))
        return moduleC
    }
    
    public static var identifier: String = "ModuleC"
    private let name:String?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        let label = UILabel(frame: .zero)
        label.text = "我的名字叫做:\(self.name ?? "默认名称")"
        label.frame = CGRect(x: 0, y: 0, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
        label.center = self.view.center
        self.view.backgroundColor = UIColor.yellow
        self.view.addSubview(label)
    }
    
    init(name:String?) {
        self.name = name
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
```

### 新增模块

新增模块十分简单依赖这个库之后，实现`ModifyModule`协议

```swift
public protocol ModifyModule {
    /// 根据另外模块传递过来的参数修改器生成模块对象 可以允许创建为空
    /// - Parameter modify: 参数修改器
    static func make(_ modify:Modify) -> ModifyModule?
    /// 模块对应的标识符
    static var identifier:String { get }
}
```

⚠️记得模块给别人使用一定要在说明文档说明模块的标识符和对应参数键。标识符在同一个App中不能重复

### 全局变量

#### 设置

```swift
ControllerCenter.center.set(globaleParameter: {
    return $0.parameter(key: "userId", block: {$0.parameter(value: "123")})
})
```

#### 获取

```swift
let userId:String? = ControllerCenter.center.get(globaleParameter: "userId")
let userId:String = ControllerCenter.center.get(globaleParameter: "userId", default: "123")
```

对于全局变量获取一定要去设置，不然会断言报错，预防因为设置出现问题

#### 更新一个全局变量的值

```swift
ControllerCenter.center.update(globaleParameter: "userId", value: "456")
```

对于存在于App运行周期的全局变量，如果是能被其他模块修改的，比如在在登录模块设置`userId`。

```swift
class ViewController: UIViewController {

    /// 非可选值
    @Property(0)
    var userId:Int
    
    /// 可选值
    @PropertyOptional(nil)
    var userName:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ControllerCenter.center.set(globaleParameter: {
            return $0.parameter(key: "userId", block: {$0.parameter(modify: self._userId)})
        })        
    }
}
```

`Property`针对于非可选值声明，`PropertyOptional`针对可选值声明。可以自定义属性`get`和`set`方法。

```swift
var userID:Int = 0
var nikeName:String?

class ViewController: UIViewController {

    /// 非可选值
    @Property(0, get: {userID}, set: {userID = $0})
    var userId:Int
    

    /// 可选值
    @PropertyOptional(nil, get: {nikeName}, set: {nikeName = $0})
    var userName:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ControllerCenter.center.set(globaleParameter: {
            return $0.parameter(key: "userId", block: {$0.parameter(modify: self._userId)})
        })        
    }
}
```

### 获取对面模块传递的值

```swift
extension Modify {

    /// 获取全局函数返回可选值 key必须存在
    /// - Parameter key: 参数对应的key
    /// - Returns: 返回类型的可选值
    public func get<T>(globaleParameter key: String) -> T?

    /// 获取参数值 key可以不存在
    /// - Parameter key: 参数对应的key
    /// - Returns: 返回类型的可选值
    public func get<T>(globaleOptionalParameter key: String) -> T?

    /// 获取全局参数 允许可以不设置Key
    /// - Parameter key: 参数对应的key
    /// - Parameter default: 默认值
    /// - Returns: 对应类型的值
    public func get<T>(globaleOptionalParameter key: String, default: T) -> T

    /// 获取全局参数
    /// - Parameter key: 参数对应的key
    /// - Parameter default: 默认值
    /// - Returns: 对应类型的值
    public func get<T>(globaleParameter key: String, default: T) -> T

    /// 更新全局参数
    /// - Parameters:
    ///   - key: 全局参数的Key
    ///   - value: 更新的值
    public mutating func update(globaleParameter key: String, value: Any?)
}
```

### 模型和字典之间的转换

#### 模型转字典

```swift
extension Encodable {
    public func toMap() -> [String : Any]?
}
```

#### 字典转模型

```swift
extension Dictionary {
    public func toDecodable<T>() -> T? where T : Decodable
}
```

