//
//  User.swift
//  ESCodec
//
//  Created by niren on 2023/4/28.
//

import Foundation


//struct User: ESDecodable {
//    @ESCodecProperty(replaceKey: "name")
//    var name: String = "jinfeng"
//    @ESCodecProperty
//    var age: Int = 1
//    var gender: Bool = false
//    var remark: String?
//    var count: Int = 10
//}
//

class Single: ESClassCodable {
//    required init() {
//
//    }

    @ESCodecProperty
    var id: Int32? = 0
    
}

//class User: Single {
//    @ESCodecProperty(replaceKey: "name1")
//    var name: String? = "jinfeng"
//
//    @ESCodecProperty
//    var age: Int = 1
//
//    @ESCodecProperty
//    var gender: Bool = false
//
//    @ESCodecProperty
//    var remark: String?
//
//    @ESCodecProperty
//    var count: Int = 10
//
//    @ESCodecProperty
//    var person: Person?
//
//    @ESCodecProperty
//    var ff: CGFloat = 0.0
//}

class User: ESClassCodable, ESConvenience {
    @ESCodecProperty(replaceKey: "name1")
    var name: String? = "jinfeng"

//    @ESCodecProperty
//    var age: String = ""
//
//    @ESCodecProperty
//    var gender: String = ""
//
//    @ESCodecProperty
//    var remark: String?
//
//    @ESCodecProperty
//    var count: String = "10"
    
    @ESCodecProperty
    var person: Person?
//
//    @ESCodecProperty
//    var ff: CGFloat = 0.0
//
    @ESCodecProperty
    var arr: [String]?

    @ESCodecProperty
    var act: Activity = Activity.none
//
//    @ESCodecProperty
//    var ptype: PeronType = .young
//
//    @ESCodecProperty
//    var ptype1: PeronType = .child
}

struct Person: ESDecodable, ESEncodable, ESConvenience {
    
    @ESCodecProperty
    var name: String = ""
}

 enum Activity: String, ESCodable {
    case none
    case start
    case end
}

enum PeronType: Int, ESCodable {
    case child
    case young
    case woman
}
