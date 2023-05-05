//
//  ViewController.swift
//  ESCodec
//
//  Created by niren on 2023/4/28.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let json: [String: Any] = ["id": 123, "name1": "jack", "age": 11.1, "gender": "yes", "remark": "nil", "person": ["name": "小汪汪"], "ff": true, "arr": ["1", "asd", "a a"], "act": "start1", "ptype": 0, "ptype1": "2"]
        
        if let data = try? JSONSerialization.data(withJSONObject: json) {
            let decoder = JSONDecoder()
            if let u = try? decoder.decode(User.self, from: data) {
                print(u.toMirrorDescription())
                

                
                let encoder = JSONEncoder()
                if let data = try? encoder.encode(u) {
                    let obj = try? JSONSerialization.jsonObject(with: data)
                    print(obj)
                }
                
            }
        }
    }
}

