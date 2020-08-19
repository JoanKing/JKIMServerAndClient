//
//  ViewController.swift
//  JKClient
//
//  Created by 王冲 on 2020/7/28.
//  Copyright © 2020 王冲. All rights reserved.
//

import UIKit
import ProtocolBuffers
/*
  1> 获取到服务器对应的IP/端口号
  2> 使用Socket, 通过IP/端口号和服务器建立连接
  3> 开启定时器, 实时让服务器发送心跳包
  4> 通过sendMsg, 给服务器发送消息: 字节流 --> headerData(消息的长度) + typeData(消息的类型) + MsgData(真正的消息)
  5> 读取从服务器传送过来的消息(开启子线程)
*/
class ViewController: UIViewController {

    fileprivate var timer: Timer!
    lazy var socket: JKSocket = JKSocket(addr: "192.168.3.44", port: 8181)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        view.addSubview(connectServer)
        view.addSubview(joinRoomBtn)
        view.addSubview(leaveRoomBtn)
        view.addSubview(sendMessageBtn)
        view.addSubview(sendGiftBtn)
        view.addSubview(sendHeartBeatBtn)
        view.addSubview(tipLabel)
    }

    /// 给服务器发送心跳包
    /// - Returns: 返回
    @objc func sendHeartBeat() {
        socket.sendHeartBeat()
    }
    
    /// 发送消息
    /**
        进入房间 0
        离开房间 1
        文本 2
        礼物 3
     */
    /// 处理点击事件
    /// - Parameter sender: button
    @objc func click(sender: UIButton) {
        switch sender.tag {
        case 101:
            if socket.connectServer() {
                tipLabel.text = "已经连接上服务器"
                tipLabel.textColor = .green
                // 连接上服务器后，发送心跳包
                timer = Timer(fireAt: Date(), interval: 10, target: self, selector: #selector(sendHeartBeat), userInfo: nil, repeats: true)
                RunLoop.current.add(timer, forMode: .common)
            } else {
                print("连接失败")
                tipLabel.text = "连接失败"
                tipLabel.textColor = .red
            }
        case 102:
            socket.sendJoinRoom()
        case 103:
            socket.sendLeavelRoom()
        case 104:
            socket.sendTextMessage(message: "你好啊")
        case 105:
            socket.sendGifMessage(giftName: "海洋之心", giftURL: "https://url", giftCount: 2)
        case 106:
            // socket.sendHeartBeat()
            print("")
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
    lazy var sendHeartBeatBtn: UIButton = {
        let button = UIButton(frame: CGRect(x: self.view.center.x + 10, y: 340, width: 100, height: 40))
        button.backgroundColor = UIColor.red
        button.setTitleColor(.white, for: .normal)
        button.setTitle("发送心跳包", for: .normal)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.tag = 106
        button.addTarget(self, action: #selector(click), for: .touchUpInside)
        return button
    }()
     lazy var tipLabel: UILabel = {
         let label = UILabel(frame: CGRect(x: self.view.center.x - 100, y: 400, width: 200, height: 50))
         label.textAlignment = .center
         label.text = "没有连接服务器"
         label.layer.cornerRadius = 8
         label.clipsToBounds = true
         label.textColor = .red
         label.backgroundColor = .brown
         return label
     }()
    
    deinit {
        // 定时器销毁
        timer.invalidate()
        timer = nil
    }
}

