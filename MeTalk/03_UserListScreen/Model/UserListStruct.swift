import UIKit

struct UserListStruct{
    var UID:String
    var userNickName: String?
    var aboutMessage: String
    var Age:Int
    var From:String?
    var Sex:Int
    var createdAt:Date
    var updatedAt:Date
    var LikeButtonPushedDate:Date?
    var LikeButtonPushedFLAG:Bool = false
    
    init(UID:String,userNickName:String?,aboutMessage:String,Age:Int,From:String,Sex:Int,createdAt:Date,updatedAt:Date){
        self.UID = UID
        self.userNickName = userNickName
        self.aboutMessage = aboutMessage
        self.Age = Age
        self.From = From
        self.Sex = Sex
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct UserListImageStruct{

    var UID:String
    var upDateDate:Date
    var image:UIImage?
    
    init(UID:String,UpdateDate:Date,UIimage:UIImage?){
        self.UID = UID
        self.upDateDate = UpdateDate
        self.image = UIimage

    }
}
