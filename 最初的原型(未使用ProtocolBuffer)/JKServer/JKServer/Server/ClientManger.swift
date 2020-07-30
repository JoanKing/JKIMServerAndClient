//
//  ClientManger.swift
//  JKServer
//
//  Created by 王冲 on 2020/7/28.
//  Copyright © 2020 王冲. All rights reserved.
//

import UIKit

class ClientManger: NSObject {

    var tcpClient: TCPClient
    /// 客户端是否已经连接
    var isClientConnected: Bool = false
    
    init(tcpClient: TCPClient) {
        self.tcpClient = tcpClient
    }
    
}

extension ClientManger {
    
    /// 开始读取消息
    func startReadMessage() {
        isClientConnected = true
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
                
                // 3.根据长度读取真实的消息
                guard let msg = tcpClient.read(length) else {
                    return
                }
                let data = Data(bytes: msg, count: length)
                let msgString = String(data: data, encoding: .utf8) ?? "无法读取消息"
                print("\n发送的内容：\(msgString)\n类型：\(type)")
            } else {
                print("客户端断开了链接")
                isClientConnected = false
                _ = tcpClient.close()
            }
        }
    }
}
