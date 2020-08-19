//
//  ViewController1.swift
//  JKServer
//
//  Created by 王冲 on 2020/7/31.
//  Copyright © 2020 王冲. All rights reserved.
//

import UIKit

class ViewController1: UIViewController {

    var thread: JKOCPermenantThread!
    override func viewDidLoad() {
        super.viewDidLoad()

        thread = JKOCPermenantThread()
        thread.executeTask { [weak self] in
            guard let weakSelf = self else {
                return
            }
            // 心跳包定时器
            let timer = Timer(fireAt: Date(), interval: 1, target: weakSelf, selector: #selector(weakSelf.checkHeartBeat), userInfo: nil, repeats: true)
            RunLoop.current.add(timer, forMode: .common)
            print("开火")
        }
    }
    
    /// 检查心跳包
    @objc func checkHeartBeat() {
        print("-----------")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        thread.stop()
        dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print("没有循环引用")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
