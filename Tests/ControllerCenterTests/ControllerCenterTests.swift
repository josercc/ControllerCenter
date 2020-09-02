import XCTest
@testable import ControllerCenter

final class ControllerCenterTests: XCTestCase {
    
    var age:Int? = 8
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        ControllerCenter.center.set(globaleParameter: { modify in
            return modify.parameter("age", value: self.age).parameter(key: "age1", block: {$0.parameter(modifyOptional: &self.age)})
        })
        assert(ControllerCenter.center.get(globaleParameter: "age")! == 8)
        assert(ControllerCenter.center.get(globaleParameter: "age1")! == 8)
        ControllerCenter.center.update(globaleParameter: "age1", value: 4)
        assert(ControllerCenter.center.get(globaleParameter: "age1")! == 4)
        assert(self.age == 4)
        ControllerCenter.center.update(globaleParameter: "age1", value: nil)
        assert(self.age == nil)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
