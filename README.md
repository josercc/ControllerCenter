![image-20200821184000857](https://gitee.com/joser_zhang/upic/raw/master/uPic/image-20200821184000857.png)

一个基于中心分发的模块化框架
[演示例子](https://github.com/josercc/Example)

> 这个框架核心在于`注册列表`和`分发中心`，在`App`内部完成所有模块的注册。
>
> 我们在`App`或者`模块内部`可以通过`分发中心`进行模块调用。

## 安装

```swift
.Package(url:"https://github.com/josercc/controllercenter.git", from:"1.0.0")
```

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
ControllerCenter.make("ModuleA").parameter("backgroundColor", value: UIColor.red).present(in: self, animated: true, completion: nil)
```

模块A的实现

```swift
/**
 标识符 ModuleA
 参数
    - parameter backgroundColor:背景颜色
 */
public class ModuleA: UIViewController, Module {
    public static func make(_ parameter: [String : Any]) -> Module {
        let moduleA = ModuleA()
        moduleA.backgroundColor = parameter["backgroundColor"] as? UIColor
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
let modify = ControllerCenter.make("ModuleB").parameter("didPushModuleCBlock", value: {
    print("didPushModuleCBlock")
})
modify.push(in: self.navigationController, animated: true)
```

模块B的实现

```swift
/**
 标识符 ModuleB
 参数
    - parameter didPushModuleCBlock:(() -> Void) 点击前往ModuleC的回掉
 */
public class ModuleB: UIViewController, Module {
    public static func make(_ parameter: [String : Any]) -> Module {
        let moduleB = ModuleB()
        moduleB.didPushModuleCBlock = parameter["didPushModuleCBlock"] as? (() -> Void)
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
                                     .parameter("name", value: "君赏")
        modify.present(in: self, animated: true, completion: nil)
    }
    
}
```

模块C的实现

```swift
public class ModuleC: UIViewController,Module {
    public static func make(_ parameter: [String : Any]) -> Module {
        let moduleC = ModuleC(name: parameter["name"] as? String)
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

新增模块十分简单依赖这个库之后，实现`Module`协议

```swift
public protocol Module {
    /// 根据另外的模块传递的参数生成此模块的对象
    /// - Parameter parameter: 其他模块传递过来的参数
    /// - Returns: 此模块的实例
    static func make(_ parameter:[String:Any]) -> Module
    /// 模块对应的标识符
    static var identifier:String { get }
}
```

⚠️记得模块给别人使用一定要在说明文档说明模块的标识符和对应参数键。标识符在同一个App中不能重复
