//
//  HostingMock.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/02/08.
//

import Foundation
enum result: Error {
    case error
    case success
}
extension result: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .error: return "これはテスト的に発生させている故意エラーです。"
        case .success: return "成功しました"
        }
    }
}

struct MockTestHosting:firebaseHostingProtocol{

    
    func FireStoreSignUpAuthRegister(callback: @escaping (FireBaseResult) -> Void) {
        let error = result.success
        callback(.Success("テスト的に発生させています"))
    }
    
    func FireStoreUserInfoRegister(callback: @escaping (FireBaseResult) -> Void, USER: profileInfoLocal, uid: String) {
        let error = result.error
        callback(.failure(error))
    }
    
    
    
}
