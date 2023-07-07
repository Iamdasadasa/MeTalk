//
//  FireBaseDataController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/12/19.
//

enum HostingResult {
    case Success(String)
    case failure(Error)
}

enum ERROR:Error{
    case err
}

enum setterKind{
    case block
    case MyNew
    case MyExtra
    case YouNew
    case YouExtra
}
