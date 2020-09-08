import XCTest
@testable import ControllerCenter

final class ControllerCenterTests: XCTestCase {
    
    var age:Int? = 8
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        ControllerCenter.center.set(globaleParameter: { modify in
            return modify.parameter(key: "age", block: {$0.parameter(value: self.age)})
                .parameter(key: "age1", block: {$0.parameter(modifyOptional: &self.age)})
                .parameter(key: "completion", block: {$0.parameter(value: { (controller:UIViewController, com:(() -> Void)) in
                    com()
                })})
        })
        assert(ControllerCenter.center.get(globaleParameter: "age")! == 8)
        assert(ControllerCenter.center.get(globaleParameter: "age1")! == 8)
        ControllerCenter.center.update(globaleParameter: "age1", value: 4)
        assert(ControllerCenter.center.get(globaleParameter: "age1")! == 4)
        assert(self.age == 4)
        ControllerCenter.center.update(globaleParameter: "age1", value: nil)
        assert(self.age == nil)
        let completion:((UIViewController,() -> Void) -> Void)? = ControllerCenter.center.get(globaleParameter: "completion")
        completion?(UIViewController(),{})
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}

struct Model: Module {
    static func make(_ parameter: [String : Any]) -> Module {
        return Model()
    }
    
    static var identifier: String { "" }
    
    
}
