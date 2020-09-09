import XCTest
@testable import ControllerCenter

final class ControllerCenterTests: XCTestCase {
    
    @Property(2, get: {8}, set: {print("\($0)")})
    var age:Int
    
    @PropertyOptional(nil, get: {8}, set: {print("\($0)")})
    var age1:Int?
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        ControllerCenter.center.set(globaleParameter: { modify in
            return modify.parameter(key: "age", block: {$0.parameter(value: self.age)})
                .parameter(key: "age1", block: {$0.parameter(modifyOptional: self._age1)})
                .parameter(key: "completion", block: {$0.parameter(value: { (controller:UIViewController, com:(() -> Void)) in
                    com()
                })})
        })
        assert(ControllerCenter.center.get(globaleParameter: "age")! == 8)
        assert(ControllerCenter.center.get(globaleParameter: "age1")! == 8)
        ControllerCenter.center.update(globaleParameter: "age1", value: 4)
        assert(ControllerCenter.center.get(globaleParameter: "age1")! == 8)
        assert(self.age == 8)
        ControllerCenter.center.update(globaleParameter: "age1", value: nil)
    }
    

    static var allTests = [
        ("testExample", testExample),
    ]
}

