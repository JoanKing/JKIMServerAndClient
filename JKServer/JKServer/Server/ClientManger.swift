//
//  ClientManger.swift
//  JKServer
//
//  Created by 王冲 on 2020/7/28.
//  Copyright © 2020 王冲. All rights reserved.
//

import UIKit

protocol ClientMangerDelegate: class {
    /// 发送消息到其他的客户端
    /// - Parameter data: 消息数据
    func sendMsgToClient(_ data: Data)
    /// 移除客户端（已经断开连接）
    /// - Parameter client: 断开的客户端
    func removeClient(_ client: ClientManger)
}

class ClientManger: NSObject {
    /// 消息的代理
    weak var delegate: ClientMangerDelegate?
    var tcpClient: TCPClient
    /// 客户端是否已经连接
    var isClientConnected: Bool = false
    /// 是否收到心跳包，默认是没有收到
    fileprivate var receiveHeartBeat: Bool = true
    fileprivate var timer: Timer!
    var thread: JKOCPermenantThread!
    init(tcpClient: TCPClient) {
        self.tcpClient = tcpClient
    }
}

extension ClientManger {
    
    /// 开始读取消息
    func startReadMessage() {
        isClientConnected = true
        
        thread = JKOCPermenantThread()
        thread.executeTask { [weak self] in
            guard let weakSelf = self else {
                return
            }
            // 心跳包定时器
            weakSelf.timer = Timer(fireAt: Date(), interval: 10, target: weakSelf, selector: #selector(weakSelf.checkHeartBeat), userInfo: nil, repeats: true)
            RunLoop.current.add(weakSelf.timer, forMode: .common)
        }
        
        while true {
            if let lMsg = tcpClient.read(4) {
                // 1.读取长度的data
                let headData = Data(bytes: lMsg, count: 4)
                var length: Int = 0
                (headData as NSData).getBytes(&length, length: 4)
                
                // 2.读取类型
                guard let typeMsg = tcpClient.read(2) else {
                    return
                }
                let typeData = Data(bytes: typeMsg, count: 2)
                var type: Int = 0
                (typeData as NSData).getBytes(&type, length: 2)
                
                // 3.根据长度读取真实的消息"
                guard let msg = tcpClient.read(length) else {
                    return
                }
                let data = Data(bytes: msg, count: length)
                switch type {
                case 0:
                    print("进入房间");
                    let user = try! UserInfo.parseFrom(data: data)
                    print("名字：\(user.name ?? "") 等级=\(String(describing: user.level))")
                case 1:
                    print("离开房间");
                    _ = tcpClient.close()
                    if self.delegate != nil {
                        self.delegate?.removeClient(self)
                    }
                case 2:
                    print("文本");
                case 3:
                    print("礼物");
                case 100:
                    guard let heartMessage = String(data: data, encoding: .utf8) else {
                        return
                    }
                    print("\(heartMessage)")
                    // 收到了心跳包
                    receiveHeartBeat = true
                    // 不需要告诉其他的客户端，所以进行下次的循环
                    continue
                default:
                    print("无法识别的消息")
                }
                
                let totalData = headData + typeData + data
                if delegate != nil {
                    // 把消息转发给其他的客户端
                    delegate?.sendMsgToClient(totalData)
                }
            } else {
                // print("客户端断开了链接")
                removeClient()
            }
        }
    }
    
    /// 检查心跳包
    @objc func checkHeartBeat() {
        print("-----检查心跳包------")
        if !receiveHeartBeat {
            removeClient()
        } else {
            // 再次去检查心跳包
            receiveHeartBeat = false
        }
    }
    
    private func removeClient() {
        thread.stop()
        isClientConnected = false
        if self.delegate != nil {
            self.delegate?.removeClient(self)
        }
        _ = tcpClient.close()
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }
}
