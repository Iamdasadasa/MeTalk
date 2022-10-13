import UIKit

struct UserListStruct{
    var UID:String
    var userNickName: String?
    var aboutMessage: String
    var Age:Int
    var From:String?
    var Sex:Int
    
    init(UID:String,userNickName:String?,aboutMessage:String,Age:Int,From:String,Sex:Int){
        self.UID = UID
        self.userNickName = userNickName
        self.aboutMessage = aboutMessage
        self.Age = Age
        self.From = From
        self.Sex = Sex
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
