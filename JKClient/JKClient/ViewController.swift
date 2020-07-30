//
//  ViewController.swift
//  JKClient
//
//  Created by 王冲 on 2020/7/28.
//  Copyright © 2020 王冲. All rights reserved.
//

import UIKit
import ProtocolBuffers
class ViewController: UIViewController {

    lazy var socket: JKSocket = JKSocket(addr: "192.168.3.44", port: 8181)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        view.addSubview(connectServer)
        view.addSubview(joinRoomBtn)
        view.addSubview(leaveRoomBtn)
        view.addSubview(sendMessageBtn)
        view.addSubview(sendGiftBtn)
        view.addSubview(tipLabel)
    }
    
    /// 发送消息
    /**
        进入房间 0
        离开房间 1
        文本 2
        礼物 3
     */
    func sendMessage() {
        // 1.获取消息长度
        let userInfo = UserInfo.Builder()
        userInfo.name = "王冲\(arc4random_uniform(10))"
        userInfo.level = 30
        userInfo.iconUrl = "https://img.sumeme.com/43/3/1592927031659.png"
        let msgData = (try! userInfo.build()).data()
    
        socket.sendMessage(data: msgData, type: 0)
        
        print("\n发送的内容：\(userInfo)\n长度：\(msgData.count)\n类型：\(0)")
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
     lazy var joinRoomBtn: UIButton = {
         let button = UIButton(frame: CGRect(x: self.view.center.x + 10, y: 100, width: 100, height: 40))
         button.backgroundColor = UIColor.red
         button.setTitleColor(.white, for: .normal)
         button.setTitle("进入房间", for: .normal)
         button.layer.cornerRadius = 8
         button.clipsToBounds = true
         button.tag = 102
         button.addTarget(self, action: #selector(click), for: .touchUpInside)
         return button
     }()
    lazy var leaveRoomBtn: UIButton = {
        let button = UIButton(frame: CGRect(x: self.view.center.x + 10, y: 160, width: 100, height: 40))
        button.backgroundColor = UIColor.red
        button.setTitleColor(.white, for: .normal)
        button.setTitle("离开房间", for: .normal)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.tag = 103
        button.addTarget(self, action: #selector(click), for: .touchUpInside)
        return button
    }()
    lazy var sendMessageBtn: UIButton = {
        let button = UIButton(frame: CGRect(x: self.view.center.x + 10, y: 220, width: 100, height: 40))
        button.backgroundColor = UIColor.red
        button.setTitleColor(.white, for: .normal)
        button.setTitle("发送消息", for: .normal)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.tag = 104
        button.addTarget(self, action: #selector(click), for: .touchUpInside)
        return button
    }()
    lazy var sendGiftBtn: UIButton = {
        let button = UIButton(frame: CGRect(x: self.view.center.x + 10, y: 280, width: 100, height: 40))
        button.backgroundColor = UIColor.red
        button.setTitleColor(.white, for: .normal)
        button.setTitle("赠送礼物", for: .normal)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.tag = 105
        button.addTarget(self, action: #selector(click), for: .touchUpInside)
        return button
    }()
     lazy var tipLabel: UILabel = {
         let label = UILabel(frame: CGRect(x: self.view.center.x - 100, y: 340, width: 200, height: 50))
         label.textAlignment = .center
         label.text = "没有连接服务器"
         label.layer.cornerRadius = 8
         label.clipsToBounds = true
         label.textColor = .red
         label.backgroundColor = .brown
         return label
     }()
}

