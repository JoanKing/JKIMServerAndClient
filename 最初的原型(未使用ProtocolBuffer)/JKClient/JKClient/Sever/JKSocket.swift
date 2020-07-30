//
//  JKSocket.swift
//  JKClient
//
//  Created by 王冲 on 2020/7/28.
//  Copyright © 2020 王冲. All rights reserved.
//

import UIKit

class JKSocket: NSObject {

    fileprivate var tcpClient: TCPClient
    init(addr: String, port: Int) {
        tcpClient = TCPClient(addr: addr, port: port)
    }
}

extension JKSocket {
    
    /// 建立与服务器之间的连接
    /// - Returns: 返回是否连接成功
    func connectServer() -> Bool {
        
        let isSuccess = tcpClient.connect(timeout: 5).0
        return isSuccess
    }
    
    func sendMessage(data: Data) {
        let result = tcpClient.send(data: data)
        if result.0 {
            print("发送成功")
        }
    }
}
