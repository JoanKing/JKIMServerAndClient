//
//  JKSocket.swift
//  JKClient
//
//  Created by 王冲 on 2020/7/28.
//  Copyright © 2020 王冲. All rights reserved.
//

import UIKit

protocol JKSocketDelegate: class {
    
    /// 加入房间
    /// - Parameters:
    ///   - socket: socket
    ///   - user: 个人信息
    func socket(_ socket: JKSocket, joinRoom user: UserInfo)
    
    /// 离开房间
    /// - Parameters:
    ///   - socket: socket
    ///   - user: 个人信息
    func socket(_ socket: JKSocket, leaveRoom user: UserInfo)
    
    /// 普通消息
    /// - Parameters:
    ///   - socket: socket
    ///   - chatMessage: 普通消息体
    func socket(_ socket: JKSocket, chatMessage: ChatMessage)
    
    /// 礼物消息
    /// - Parameters:
    ///   - socket: socket
    ///   - giftMessage: 礼物消息体
    func socket(_ socket: JKSocket, giftMessage: GiftMessage)
}

class JKSocket: NSObject {
    /// 消息代理
    weak var delegate: JKSocketDelegate?
    // 客户端对象
    fileprivate var tcpClient: TCPClient
    lazy var userInfo: UserInfo.Builder = {
        let userInfo = UserInfo.Builder()
        userInfo.name = "王冲\(arc4random_uniform(10))"
        userInfo.level = 30
        userInfo.iconUrl = "https://img.sumeme.com/43/3/1592927031659.png"
        return userInfo
    }()
    init(addr: String, port: Int) {
        tcpClient = TCPClient(addr: addr, port: port)
    }
}

// MARK:- 客户端连接服务器与消息的读取
extension JKSocket {
    
    // MARK:- 客户端 建立与服务器之间的连接
    /// 建立与服务器之间的连接
    /// - Returns: 返回是否连接成功
    func connectServer() -> Bool {
        
        let isSuccess = tcpClient.connect(timeout: 5).0
        if isSuccess {
            // 连接成功就开始接收消息
            receiveMessage()
        }
        return isSuccess
    }
    
    // MARK:- 客户端 接收消息
    /// 接收消息
    fileprivate func receiveMessage() {
        DispatchQueue.global().async {
            while true {
                guard let lMsg = self.tcpClient.read(4) else {
                    // 读取不到就进入下一个循环
                    // print("------与服务器断开了连接------")
                    // self.tcpClient.close()
                    continue
                }
                // 1.读取长度的data
                let headData = Data(bytes: lMsg, count: 4)
                var length: Int = 0
                (headData as NSData).getBytes(&length, length: 4)
                // 2.读取类型
                guard let typeMsg = self.tcpClient.read(2) else {
                    return
                }
                let typeData = Data(bytes: typeMsg, count: 2)
                var type: Int = 0
                (typeData as NSData).getBytes(&type, length: 2)
                // 3.根据长度读取真实的消息"
                guard let msg = self.tcpClient.read(length) else {
                    return
                }
                let data = Data(bytes: msg, count: length)
                // 4.处理消息
                DispatchQueue.main.async {
                    // 回到主线程
                    self.handleMessage(type: type, data: data)
                }
            }
        }
    }
    
    /// 处理消息
    /// - Parameters:
    ///   - type: 消息的类型
    ///   - data: 消息的数据
    fileprivate func handleMessage(type: Int, data: Data) {
        switch type {
        case 0:
            let userInfo = try! UserInfo.parseFrom(data: data)
            print("---------接收的内容------\n\n名字：\(userInfo.name ?? "") 等级=\(String(describing: userInfo.level))\n\n-----------------------")
            if self.delegate != nil {
                self.delegate?.socket(self, joinRoom: userInfo)
            }
        case 1:
            print("离开房间");
            let userInfo = try! UserInfo.parseFrom(data: data)
            print("---------接收的内容------\n\n名字：\(userInfo.name ?? "") 等级=\(String(describing: userInfo.level))\n\n-----------------------")
            if self.delegate != nil {
                self.delegate?.socket(self, leaveRoom: userInfo)
            }
        case 2:
            print("文本");
            let chatMessage = try! ChatMessage.parseFrom(data: data)
            print("---------接收的内容------\n\n文本内容：\(chatMessage.text ?? "")\n\n-----------------------")
            if self.delegate != nil {
                self.delegate?.socket(self, chatMessage: chatMessage)
            }
        case 3:
            print("礼物");
            let giftMessage = try! GiftMessage.parseFrom(data: data)
            print("---------接收的内容------\n\n礼物的名字：\(giftMessage.giftname ?? "")\n\n-----------------------")
            if self.delegate != nil {
                self.delegate?.socket(self, giftMessage: giftMessage)
            }
        default:
            print("无法识别的消息")
        }
    }
}

// MARK:- 客户端消息的接口
/**
   进入房间 0
   离开房间 1
   文本 2
   礼物 3
*/
extension JKSocket {
    // MARK: 加入房间
    /// 加入房间
    /// - Parameter userInfo: 加入房间的人
    func sendJoinRoom() {
        // 1.获取消息
        let msgData = (try! userInfo.build()).data()
        sendMessage(data: msgData, type: 0)
    }
    // MARK: 离开房间
    /// 离开房间
    func sendLeavelRoom() {
        // 1.获取消息
        let msgData = (try! userInfo.build()).data()
        sendMessage(data: msgData, type: 1)
    }
    // MARK: 发送普通消息
    /// 发送消息
    func sendTextMessage(message: String) {
        // 1.获取消息
        let textMessage = ChatMessage.Builder()
        // textMessage.user = userInfo
        textMessage.text = message
        textMessage.user = try! userInfo.build()
        // 2.获取我们响应的data
        let chatData = (try! textMessage.build()).data()
        // 3.发送消息到服务器
        sendMessage(data: chatData, type: 2)
    }
    // MARK: 发送礼物消息
    /// 发送礼物消息
    func sendGifMessage(giftName: String, giftURL: String, giftCount: Int) {
        // 1.创建GiftMessage
        let giftMessage = GiftMessage.Builder()
        // textMessage.user = userInfo
        giftMessage.giftname = giftName
        giftMessage.giftUrl = giftURL
        giftMessage.giftcount = Int32(giftCount)
        giftMessage.user = try! userInfo.build()
        // 2.获取我们礼物的data
        let giftData = (try! giftMessage.build()).data()
        // 3.发送消息到服务器
        sendMessage(data: giftData, type: 3)
    }
    
    // MARK:- 发送心跳包
    /// 发送心跳包
    func sendHeartBeat() {
        // 1.获取消息
        let hearBeatContent = "我是心跳包"
        let msgData = hearBeatContent.data(using: .utf8)!
        // 发送心跳包
        sendMessage(data: msgData, type: 100)
    }
    
    // MARK: 客户端 发送消息
    /// 发送消息
    /// - Parameter data: 消息数据
    fileprivate func sendMessage(data: Data, type: Int) {
        // 1、获取消息的长度
        var mesLength = data.count
        // 2、将消息长度，写入到
        let headerData = Data(bytes: &mesLength, count: 4)
        // 3、消息的类型
        var tempType = type
        let typeData = Data(bytes: &tempType, count: 2)
        // 4、发送消息
        let totalData = headerData + typeData + data
        
        let result = tcpClient.send(data: totalData)
        if result.0 {
            print("发送成功")
        }
    }
}
