//
//  ServerManger.swift
//  JKServer
//
//  Created by 王冲 on 2020/7/28.
//  Copyright © 2020 王冲. All rights reserved.
//

import UIKit
var serverport = 8181
class ServerManger: NSObject {
    
    /// 创建TCPServer
    var serverSocket: TCPServer = TCPServer(addr: "192.168.3.44", port: serverport)
    /// 服务器是否开启
    var isServerRunning: Bool = false
    lazy var clients: [ClientManger] = [ClientManger]()
    /// 开启服务器
    func startRunning() {
        // 1.开启监听
        _ = serverSocket.listen()
        isServerRunning = true
        // 2.开始接受客户端
        DispatchQueue.global().async {
            while self.isServerRunning {
                if let client = self.serverSocket.accept() {
                    print("接收到一个客户端的连接")
                    DispatchQueue.global().async {
                        // 接收多个客户端
                        self.handleClient(client: client)
                    }
                }
            }
        }
    }
    
    /// 关闭服务器
    func stopRunning() {
        isServerRunning = false
        
    }
}

extension ServerManger {
    func handleClient(client: TCPClient) {
        // 1.用一个ClientManger 管理TCPClient
        let clientManger = ClientManger(tcpClient: client)
        // 2.保存客户端
        clients.append(clientManger)
        // 3.用client开始接受消息
        clientManger.startReadMessage()
    }
}
