//
//  ViewController.swift
//  JKClient
//
//  Created by 王冲 on 2020/7/28.
//  Copyright © 2020 王冲. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    lazy var socket: JKSocket = JKSocket(addr: "192.168.3.44", port: 8181)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        view.addSubview(connectServer)
        view.addSubview(sendMessageBtn)
        view.addSubview(tipLabel)
        
        
    }
    
    /// 发送消息
    func sendMessage() {
        // 1.获取消息长度
        let msgStr = "您好，兄弟！"
        let data = msgStr.data(using: .utf8)!
        var mesLength = data.count
        // 2.将消息长度，写入到datashushu
        let headerData = Data(bytes: &mesLength, count: 4)
        // 3.消息的类型
        var type = 0
        let typeData = Data(bytes: &type, count: 2)
        // 4.发送消息
        let totalData = headerData + typeData + data
        socket.sendMessage(data: totalData)
        
        print("\n发送的内容：\(msgStr)\n长度：\(mesLength)\n类型：\(type)")
    }
    
    /// 处理点击事件
    /// - Parameter sender: button
    @objc func click(sender: UIButton) {
        switch sender.tag {
        case 101:
            if socket.connectServer() {
                tipLabel.text = "已经连接上服务器"
                tipLabel.textColor = .green
            } else {
                print("连接失败")
                tipLabel.text = "连接失败"
                tipLabel.textColor = .red
            }
        case 102:
            sendMessage()
        default:
            print("无效事件")
        }
    }

    lazy var connectServer: UIButton = {
         let button = UIButton(frame: CGRect(x: self.view.center.x - 150, y: 100, width: 120, height: 40))
         button.backgroundColor = UIColor.green
         button.setTitleColor(.brown, for: .normal)
         button.setTitle("连接服务器", for: .normal)
         button.layer.cornerRadius = 8
         button.clipsToBounds = true
         button.tag = 101
         button.addTarget(self, action: #selector(click), for: .touchUpInside)
         return button
     }()
     lazy var sendMessageBtn: UIButton = {
         let button = UIButton(frame: CGRect(x: self.view.center.x + 50, y: 100, width: 60, height: 40))
         button.backgroundColor = UIColor.red
         button.setTitleColor(.white, for: .normal)
         button.setTitle("发送", for: .normal)
         button.layer.cornerRadius = 8
         button.clipsToBounds = true
         button.tag = 102
         button.addTarget(self, action: #selector(click), for: .touchUpInside)
         return button
     }()
     lazy var tipLabel: UILabel = {
         let label = UILabel(frame: CGRect(x: self.view.center.x - 100, y: 230, width: 200, height: 50))
         label.center = self.view.center
         label.textAlignment = .center
         label.text = "没有连接服务器"
         label.layer.cornerRadius = 8
         label.clipsToBounds = true
         label.textColor = .red
         label.backgroundColor = .brown
         return label
     }()
}

