//
//  SocketServer.swift
//  healthDevice
//
//  Created by Felipe Rubin on 03/12/18.
//  Copyright © 2018 Felipe Pfeifer Rubin. All rights reserved.
//

import Foundation

import SwiftSocket


class SocketServer  {
    
    
    private var hostIP: String!
    private var hostPort: Int32!
    
    private var client: TCPClient!
    
    init(hostIP: String!, hostPort: Int32!) {
        
        self.hostIP = hostIP
        
        self.hostPort = hostPort
        
        
    }
    
    public func sendMessage(message: String) {
        sendData(value: message)
    }
    
    
    public func getHostIP() -> String {
        return hostIP
    }
    
    public func setHostIP(hostIP: String) {
        self.hostIP = hostIP
    }
    
    public func getHostPort() -> Int32 {
        return hostPort
    }
    
    public func setHostPort(hostPort: Int32) {
        self.hostPort = hostPort
    }
    
    
    private func initClient(){
        
        self.client =  TCPClient(address: hostIP, port: hostPort)
    }
    
    
    public func closeClient() {
        client.close()
        client = nil
    }
    
    
    private func sendData(value: String!) {
        
        if client == nil {
            initClient()
        }
        
        switch client.connect(timeout: 1){
        case .success:
            switch client.send(string: value) {
            case .success:
                guard let data = client.read(1024*10) else {
                    return
                }
                
                if let response = String(bytes: data, encoding: .utf8) {
                    //print(response)
                }
            case .failure(let error):
                print(error)
            }
        case .failure(let error):
            print(error)
            
        }
//        if client != nil {
//            client.close()
//        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
