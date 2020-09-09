//
//  ModifyValue.swift
//  
//
//  Created by 张行 on 2020/9/8.
//

import UIKit

@propertyWrapper
public class Property<T> {
    var value:T
    let get:(() -> T)?
    let set:((T) -> Void)?
    public init(_ value:T, get:(() -> T)? = nil, set:((T) -> Void)? = nil) {
        self.value = value
        self.get = get
        self.set = set
    }
    public var wrappedValue:T {
        get {
            if let get = self.get {
                return get()
            } else {
                return self.value
            }
        }
        set {
            self.value = newValue
        }
    }
    
    public func update<V:Any>(_ value:V) {
        guard let value = value as? T else {
            return
        }
        self.value = value
        self.set?(value)
    }
}

@propertyWrapper
public class PropertyOptional<T> {
    var value:T?
    let get:(() -> T?)?
    let set:((T?) -> Void)?
    public init(_ value:T?, get:(() -> T?)? = nil, set:((T?) -> Void)? = nil) {
        self.value = value
        self.get = get
        self.set = set
    }
    public var wrappedValue:T? {
        get {
            if let get = self.get {
                return get()
            } else {
                return self.value
            }
        }
        set {
            self.value = newValue
        }
    }
    
    public func update<V:Any>(_ value:V?) {
        let value = value as? T
        self.value = value
        self.set?(value)
    }
}
