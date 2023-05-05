//
//  ESCodec.swift
//  ESCodec
//
//  Created by niren on 2023/4/28.
//

// Extended and Simplified

// [swift-codable](https://github.com/apple/swift/blob/56a1663c9859f1283904cb0be4774a4e79d60a22/stdlib/public/core/Codable.swift)
// [property-wrapper](https://www.swiftbysundell.com/articles/property-wrappers-in-swift/#decoding-and-overriding)

// [reading]
// 1. [codable源码解读]http://chuquan.me/2021/10/18/codable/
// 2. [类型擦除]http://chuquan.me/2021/10/10/swift-type-erase/
// 3. [swift范型](http://chuquan.me/2021/09/25/swift-generic-protocol/)
// 4. [ExCodable](https://github.com/iwill/ExCodable)

import Foundation

public typealias ESCodable = ESDecodable & ESEncodable

@propertyWrapper
class ESCodecProperty<T> {
    var wrappedValue: T
    
    /// 自定义键名
    let replaceKey: String?
    
    /// 自动在不同类型之间进行转换，比如Int->String; Int->Bool; Bool->Int
    let autoConvert: Bool
    
    public init(wrappedValue: T, replaceKey: String? = nil, autoConvert: Bool = true) {
        self.wrappedValue = wrappedValue
        self.replaceKey = replaceKey
        self.autoConvert = autoConvert
    }
}

private struct ESCodingKey: CodingKey {
    var stringValue: String
    
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    var intValue: Int?
    
    init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = String(intValue)
    }
    
    var description: String {
        let intValue = self.intValue?.description ?? "nil"
        return "\(type(of: self))(stringValue: \"\(stringValue)\", intValue: \(intValue))"
    }

    var debugDescription: String {
        return description
    }
}

// MARK: 为属性包装器添加解码支持
private protocol ESPropertyDecodable {
    func decodeValue(from decoder: Decoder, label: String) throws
}

extension ESCodecProperty: ESPropertyDecodable where T: Decodable {
    func decodeValue(from decoder: Decoder, label: String) throws {
        let container = try decoder.container(keyedBy: ESCodingKey.self)
        var keyName: String
        if let replaceKey = replaceKey {
            keyName = replaceKey
        } else {
            keyName = label.hasPrefix("_") ? String(label.dropFirst()) : label
        }
        if let key = ESCodingKey(stringValue: keyName) {
            if autoConvert {
                try decodeForTypeConvert(container: container, key: key)
            } else {
                try decodeForValue(container: container, key: key)
            }
        }
    }
    
    /// 将不同类型的数据进行隐式转换
    /// - Parameters:
    ///   - container: 解码存储器
    ///   - key: 键
    private func decodeForTypeConvert(container: KeyedDecodingContainer<ESCodingKey>, key: ESCodingKey) throws {
        if T.self is Bool.Type || T.self is Bool?.Type {
            if let intValue = try? container.decode(Int.self, forKey: key) {
                wrappedValue = (intValue != 0) as! T
                return
            } else if let stringValue = try? container.decode(String.self, forKey: key) {
                switch stringValue.lowercased() {
                case "true", "yes":
                    wrappedValue = true as! T
                case "false", "no":
                    wrappedValue = false as! T
                default:
                    if let intValue = Int(stringValue) {
                        wrappedValue = (intValue != 0) as! T
                    } else if let doubleValue = Double(stringValue) {
                        wrappedValue = (doubleValue != 0) as! T
                    }
                }
                return
            }
        }
        else if T.self is Int.Type || T.self is Int?.Type {
            if let boolValue = try? container.decode(Bool.self, forKey: key) {
                wrappedValue = (boolValue ? 1 : 0) as! T
                return
            } else if let doubleValue = try? container.decode(Double.self, forKey: key) {
                wrappedValue = Int(doubleValue) as! T
                return
            } else if let stringValue = try? container.decode(String.self, forKey: key), let v = Int(stringValue) {
                wrappedValue = v as! T
                return
            }
        }
        else if T.self is Int8.Type || T.self is Int8?.Type {
            if let boolValue = try? container.decode(Bool.self, forKey: key) {
                wrappedValue = (boolValue ? 1 : 0) as! T
                return
            } else if let doubleValue = try? container.decode(Double.self, forKey: key) {
                wrappedValue = Int8(doubleValue) as! T
                return
            } else if let stringValue = try? container.decode(String.self, forKey: key), let v = Int8(stringValue) {
                wrappedValue = v as! T
                return
            }
        }
        else if T.self is Int16.Type || T.self is Int16?.Type {
            if let boolValue = try? container.decode(Bool.self, forKey: key) {
                wrappedValue = (boolValue ? 1 : 0) as! T
                return
            } else if let doubleValue = try? container.decode(Double.self, forKey: key) {
                wrappedValue = Int16(doubleValue) as! T
                return
            } else if let stringValue = try? container.decode(String.self, forKey: key), let v = Int16(stringValue) {
                wrappedValue = v as! T
                return
            }
        }
        else if T.self is Int32.Type || T.self is Int32?.Type {
            if let boolValue = try? container.decode(Bool.self, forKey: key) {
                wrappedValue = (boolValue ? 1 : 0) as! T
                return
            } else if let doubleValue = try? container.decode(Double.self, forKey: key) {
                wrappedValue = Int32(doubleValue) as! T
                return
            } else if let stringValue = try? container.decode(String.self, forKey: key), let v = Int32(stringValue) {
                wrappedValue = v as! T
                return
            }
        }
        else if T.self is Int64.Type || T.self is Int64?.Type {
            if let boolValue = try? container.decode(Bool.self, forKey: key) {
                wrappedValue = (boolValue ? 1 : 0) as! T
                return
            } else if let doubleValue = try? container.decode(Double.self, forKey: key) {
                wrappedValue = Int64(doubleValue) as! T
                return
            } else if let stringValue = try? container.decode(String.self, forKey: key), let v = Int64(stringValue) {
                wrappedValue = v as! T
                return
            }
        }
        else if T.self is UInt.Type || T.self is UInt?.Type {
            if let boolValue = try? container.decode(Bool.self, forKey: key) {
                wrappedValue = (boolValue ? 1 : 0) as! T
                return
            } else if let doubleValue = try? container.decode(Double.self, forKey: key) {
                wrappedValue = UInt(doubleValue) as! T
                return
            } else if let stringValue = try? container.decode(String.self, forKey: key), let v = UInt(stringValue) {
                wrappedValue = v as! T
                return
            }
        }
        else if T.self is UInt8.Type || T.self is UInt8?.Type {
            if let boolValue = try? container.decode(Bool.self, forKey: key) {
                wrappedValue = (boolValue ? 1 : 0) as! T
                return
            } else if let doubleValue = try? container.decode(Double.self, forKey: key) {
                wrappedValue = UInt8(doubleValue) as! T
                return
            } else if let stringValue = try? container.decode(String.self, forKey: key), let v = UInt8(stringValue) {
                wrappedValue = v as! T
                return
            }
        }
        else if T.self is UInt16.Type || T.self is UInt16?.Type {
            if let boolValue = try? container.decode(Bool.self, forKey: key) {
                wrappedValue = (boolValue ? 1 : 0) as! T
                return
            } else if let doubleValue = try? container.decode(Double.self, forKey: key) {
                wrappedValue = UInt16(doubleValue) as! T
                return
            } else if let stringValue = try? container.decode(String.self, forKey: key), let v = UInt16(stringValue) {
                wrappedValue = v as! T
                return
            }
        }
        else if T.self is UInt32.Type || T.self is UInt32?.Type {
            if let boolValue = try? container.decode(Bool.self, forKey: key) {
                wrappedValue = (boolValue ? 1 : 0) as! T
                return
            } else if let doubleValue = try? container.decode(Double.self, forKey: key) {
                wrappedValue = UInt32(doubleValue) as! T
                return
            } else if let stringValue = try? container.decode(String.self, forKey: key), let v = UInt32(stringValue) {
                wrappedValue = v as! T
                return
            }
        }
        else if T.self is UInt64.Type || T.self is UInt64?.Type {
            if let boolValue = try? container.decode(Bool.self, forKey: key) {
                wrappedValue = (boolValue ? 1 : 0) as! T
                return
            } else if let doubleValue = try? container.decode(Double.self, forKey: key) {
                wrappedValue = UInt64(doubleValue) as! T
                return
            } else if let stringValue = try? container.decode(String.self, forKey: key), let v = UInt64(stringValue) {
                wrappedValue = v as! T
                return
            }
        }
        else if T.self is Float.Type || T.self is Float?.Type {
            if let boolValue = try? container.decode(Bool.self, forKey: key) {
                wrappedValue = Float(boolValue ? 1 : 0) as! T
                return
            } else if let stringValue = try? container.decode(String.self, forKey: key), let v = Float(stringValue) {
                wrappedValue = v as! T
                return
            }
        }
        else if T.self is Double.Type || T.self is Double?.Type {
            if let boolValue = try? container.decode(Bool.self, forKey: key) {
                wrappedValue = Double(boolValue ? 1 : 0) as! T
                return
            } else if let stringValue = try? container.decode(String.self, forKey: key), let v = Double(stringValue) {
                wrappedValue = v as! T
                return
            }
        }
        else if T.self is CGFloat.Type || T.self is CGFloat?.Type {
            if let boolValue = try? container.decode(Bool.self, forKey: key) {
                wrappedValue = CGFloat(boolValue ? 1 : 0) as! T
                return
            } else if let stringValue = try? container.decode(String.self, forKey: key), let v = Double(stringValue) {
                wrappedValue = CGFloat(v) as! T
                return
            }
        }
        else if T.self is String.Type || T.self is String?.Type {
            if let boolValue = try? container.decode(Bool.self, forKey: key) {
                wrappedValue = String(boolValue) as! T
                return
            } else if let intValue = try? container.decode(Int.self, forKey: key) {
                wrappedValue = String(intValue) as! T
                return
            } else if let doubleValue = try? container.decode(Double.self, forKey: key) {
                wrappedValue = String(doubleValue) as! T
                return
            } else if let stringValue = try? container.decode(String.self, forKey: key) {
                let optional = T.self is String?.Type
                switch stringValue.lowercased() {
                case "null", "nil", "<nil>", "<null>":
                    wrappedValue = (optional ? nil : "") as! T
                default:
                    wrappedValue = String(stringValue) as! T
                }
                return
            }
        }
        // TODO: 可选枚举无法命中
        else if T.self is any RawRepresentable.Type || T.self is (any RawRepresentable)?.Type {
            if let stringValue = try? container.decode(String.self, forKey: key) {
                if let rawType = T.self as? (any RawRepresentable<String>.Type), let v = rawType.init(rawValue: stringValue) as? T {
                    wrappedValue = v
                } else if let rawType = T.self as? (any RawRepresentable<Int>.Type), let v = rawType.init(rawValue: Int(stringValue) ?? 0) as? T {
                    wrappedValue = v
                } else if let rawType = T.self as? (any RawRepresentable<Int8>.Type), let v = rawType.init(rawValue: Int8(stringValue) ?? 0) as? T {
                    wrappedValue = v
                } else if let rawType = T.self as? (any RawRepresentable<Int16>.Type), let v = rawType.init(rawValue: Int16(stringValue) ?? 0) as? T {
                    wrappedValue = v
                } else if let rawType = T.self as? (any RawRepresentable<Int32>.Type), let v = rawType.init(rawValue: Int32(stringValue) ?? 0) as? T {
                    wrappedValue = v
                } else if let rawType = T.self as? (any RawRepresentable<Int64>.Type), let v = rawType.init(rawValue: Int64(stringValue) ?? 0) as? T {
                    wrappedValue = v
                } else if let rawType = T.self as? (any RawRepresentable<UInt>.Type), let v = rawType.init(rawValue: UInt(stringValue) ?? 0) as? T {
                    wrappedValue = v
                } else if let rawType = T.self as? (any RawRepresentable<UInt8>.Type), let v = rawType.init(rawValue: UInt8(stringValue) ?? 0) as? T {
                    wrappedValue = v
                } else if let rawType = T.self as? (any RawRepresentable<UInt16>.Type), let v = rawType.init(rawValue: UInt16(stringValue) ?? 0) as? T {
                    wrappedValue = v
                } else if let rawType = T.self as? (any RawRepresentable<UInt32>.Type), let v = rawType.init(rawValue: UInt32(stringValue) ?? 0) as? T {
                    wrappedValue = v
                } else if let rawType = T.self as? (any RawRepresentable<UInt64>.Type), let v = rawType.init(rawValue: UInt64(stringValue) ?? 0) as? T {
                    wrappedValue = v
                }
                return
            } else if let intValue = try? container.decode(Int.self, forKey: key) {
                if let rawType = T.self as? (any RawRepresentable<Int>.Type), let v = rawType.init(rawValue: intValue) as? T {
                    wrappedValue = v
                } else if let rawType = T.self as? (any RawRepresentable<Int8>.Type), let v = rawType.init(rawValue: Int8(intValue)) as? T {
                    wrappedValue = v
                } else if let rawType = T.self as? (any RawRepresentable<Int16>.Type), let v = rawType.init(rawValue: Int16(intValue)) as? T {
                    wrappedValue = v
                } else if let rawType = T.self as? (any RawRepresentable<Int32>.Type), let v = rawType.init(rawValue: Int32(intValue)) as? T {
                    wrappedValue = v
                } else if let rawType = T.self as? (any RawRepresentable<Int64>.Type), let v = rawType.init(rawValue: Int64(intValue)) as? T {
                    wrappedValue = v
                } else if let rawType = T.self as? (any RawRepresentable<String>.Type), let v = rawType.init(rawValue: String(intValue)) as? T {
                    wrappedValue = v
                } else if let rawType = T.self as? (any RawRepresentable<UInt>.Type), let v = rawType.init(rawValue: UInt(intValue)) as? T {
                    wrappedValue = v
                } else if let rawType = T.self as? (any RawRepresentable<UInt8>.Type), let v = rawType.init(rawValue: UInt8(intValue)) as? T {
                    wrappedValue = v
                } else if let rawType = T.self as? (any RawRepresentable<UInt16>.Type), let v = rawType.init(rawValue: UInt16(intValue)) as? T {
                    wrappedValue = v
                } else if let rawType = T.self as? (any RawRepresentable<UInt32>.Type), let v = rawType.init(rawValue: UInt32(intValue)) as? T {
                    wrappedValue = v
                } else if let rawType = T.self as? (any RawRepresentable<UInt64>.Type), let v = rawType.init(rawValue: UInt64(intValue)) as? T {
                    wrappedValue = v
                }
                return
            }
        }
        try decodeForValue(container: container, key: key)
    }
    
    private func decodeForValue(container: KeyedDecodingContainer<ESCodingKey>, key: ESCodingKey) throws {
        do {
            if let value = try container.decodeIfPresent(T.self, forKey: key) {
                wrappedValue = value
            }
        } catch {
            debugPrint("Can not decode property named: \(key), type: \(T.self)")
            throw error
        }
    }
}

extension RawRepresentable where Self: ESCodable, Self.RawValue == String {
    init() {
        self.init(rawValue: "")!
    }
}
extension RawRepresentable where Self: ESCodable, Self.RawValue == Int {
    init() {
        self.init(rawValue: 0)!
    }
}
extension RawRepresentable where Self: ESCodable, Self.RawValue == Int8 {
    init() {
        self.init(rawValue: 0)!
    }
}
extension RawRepresentable where Self: ESCodable, Self.RawValue == Int16 {
    init() {
        self.init(rawValue: 0)!
    }
}
extension RawRepresentable where Self: ESCodable, Self.RawValue == Int32 {
    init() {
        self.init(rawValue: 0)!
    }
}
extension RawRepresentable where Self: ESCodable, Self.RawValue == Int64 {
    init() {
        self.init(rawValue: 0)!
    }
}
extension RawRepresentable where Self: ESCodable, Self.RawValue == UInt {
    init() {
        self.init(rawValue: 0)!
    }
}
extension RawRepresentable where Self: ESCodable, Self.RawValue == UInt8 {
    init() {
        self.init(rawValue: 0)!
    }
}
extension RawRepresentable where Self: ESCodable, Self.RawValue == UInt16 {
    init() {
        self.init(rawValue: 0)!
    }
}
extension RawRepresentable where Self: ESCodable, Self.RawValue == UInt32 {
    init() {
        self.init(rawValue: 0)!
    }
}
extension RawRepresentable where Self: ESCodable, Self.RawValue == UInt64 {
    init() {
        self.init(rawValue: 0)!
    }
}


// MARK: Decode
public protocol ESDecodable: Decodable {
    init()
}
public extension ESDecodable {
    init(from decoder: Decoder) throws {
        self.init()
        try _decode(from: decoder)
    }
    
    private func _decode(from decoder: Decoder) throws {
        var mirror: Mirror? = Mirror(reflecting: self)
        while mirror != nil {
            for child in mirror!.children where child.label != nil {
                guard let value = child.value as? ESPropertyDecodable else {
                    // TODO: 无法转成自定义属性包装器的变量如何转换
                    continue
                }
                try value.decodeValue(from: decoder, label: child.label!)
            }
            mirror = mirror?.superclassMirror
        }
    }
    
}


// MARK: 为属性包装器添加编码支持
private protocol ESPropertyEncodable {
    func encodeValue(from encoder: Encoder, label: String) throws
    func propertyValue() -> Any
}

extension ESCodecProperty: ESPropertyEncodable where T: Encodable {
    func encodeValue(from encoder: Encoder, label: String) throws {
        var container = encoder.container(keyedBy: ESCodingKey.self)
        var keyName: String
        if let replaceKey = replaceKey {
            keyName = replaceKey
        } else {
            keyName = label.hasPrefix("_") ? String(label.dropFirst()) : label
        }
        do {
            if let key = ESCodingKey(stringValue: keyName) {
               try container.encodeIfPresent(wrappedValue, forKey: key)
            }
        } catch {
            debugPrint("Can not encode property named: \(label), value: \(wrappedValue)")
            throw error
        }
    }
    
    func propertyValue() -> Any {
        wrappedValue
    }
}

// MARK: Encode
public protocol ESEncodable: Encodable {}
public extension ESEncodable {
    func encode(to encoder: Encoder) throws {
        try _encode(to: encoder)
    }
    
    private func _encode(to encoder: Encoder) throws {
        var mirror: Mirror? = Mirror(reflecting: self)
        while mirror != nil {
            for child in mirror!.children where child.label != nil {
                guard let value = child.value as? ESPropertyEncodable else {
                    // TODO: 无法转成自定义属性包装器的变量如何转换
                    continue
                }
                try value.encodeValue(from: encoder, label: child.label!)
            }
            mirror = mirror?.superclassMirror
        }
    }
}


// MARK: 便利方法
public protocol ESConvenience {
    
    /// 输出一个对象的属性名和值
    /// - Returns: 键值对的一组字符串
    func toMirrorDescription() -> String
}
extension ESConvenience {
    public func toMirrorDescription() -> String {
        var output = ""
        var mirror: Mirror? = Mirror(reflecting: self)
        
        func printMirror(_ mirror: Mirror, deep: Int = 1) -> String {
            var output = ""
            output += "- [\(mirror.subjectType)]\n"
            for child in mirror.children {
                if let label = child.label {
                    let  keyName = label.hasPrefix("_") ? String(label.dropFirst()) : label
                    if let value = child.value as? ESPropertyEncodable {
                        if let convenice = value.propertyValue() as? ESConvenience {
                            output += "+\(keyName): \(convenice.toMirrorDescription())\n"
                        } else {
                            output += "\t\(keyName): \(value.propertyValue())\n"
                        }
                    } else {
                        output += "\t\(keyName): \(child.value)\n"
                    }
                }
            }
            return output
        }
        
        while mirror != nil {
            output += printMirror(mirror!)
            mirror = mirror?.superclassMirror
        }
        return output
    }
}

// MARK: 针对Class类定义一个遵循ESCodable协议的基类
public class ESClassCodable: ESCodable {
    required public init() {}
}
