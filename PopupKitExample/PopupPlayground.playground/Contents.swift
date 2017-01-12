//: Playground - noun: a place where people can play

import UIKit

//var str = "Hello, playground"

protocol ADel {
    func testDel(a: A)
}

class A {
    var aDel: ADel?

    func test(){
        print("Call test")
        do {
            [weak self] in
            print("Dispatch")
            self?.aDel?.testDel(a: self!)
        }
    }
}

class B: ADel {
    func testDel(a: A) {
        print("Call testDel")
    }
}

let b = B()

let a = A()
a.aDel = b

a.test()