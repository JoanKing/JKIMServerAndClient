//
//  ViewController.swift
//  JKServer
//
//  Created by 王冲 on 2020/7/29.
//  Copyright © 2020 王冲. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    /// 服务器对象
    lazy var serverManger: ServerManger = ServerManger()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(startServer)
        view.addSubview(stopServer)
        view.addSubview(tipLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        present(ViewController1(), animated: true, completion: nil)
    }
    
    /// 点击事件
    /// - Parameter sender: button
    @objc func click(sender: UIButton) {
        switch sender.tag {
        case 101:
            guard !serverManger.isServerRunning else {
                return
            }
            print("开启")
            serverManger.startRunning()
            tipLabel.text = "服务器已经开启ing"
            tipLabel.textColor = .green
        case 102:
            guard serverManger.isServerRunning else {
                return
            }
            print("关闭")
            serverManger.stopRunning()
            tipLabel.text = "服务器已经关闭"
            tipLabel.textColor = .red
        default:
            print("不存在的事件")
        }
    }

    
    lazy var startServer: UIButton = {
        let button = UIButton(frame: CGRect(x: self.view.center.x - 110, y: 100, width: 60, height: 40))
        button.backgroundColor = UIColor.green
        button.setTitleColor(.white, for: .normal)
        button.setTitle("开启", for: .normal)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.tag = 101
        button.addTarget(self, action: #selector(click), for: .touchUpInside)
        return button
    }()
    lazy var stopServer: UIButton = {
        let button = UIButton(frame: CGRect(x: self.view.center.x + 50, y: 100, width: 60, height: 40))
        button.backgroundColor = UIColor.red
        button.setTitleColor(.white, for: .normal)
        button.setTitle("关闭", for: .normal)
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
        label.text = "没有开启服务器"
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textColor = .red
        label.backgroundColor = .brown
        return label
    }()

}

