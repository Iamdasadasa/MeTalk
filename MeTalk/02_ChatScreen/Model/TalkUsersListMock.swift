import UIKit

struct talkListUserStruct{

    ///最初のメッセージを取得する部分を実装したら解放
//    var firstMessage: String
    var UID:String
    var userNickName: String?
    var profileImage: UIImage?
    var NewMessage: String
    var upDateDate:Date
    var listend:Bool
    var sendUID:String

    
    init(UID:String,userNickName:String?,profileImage:UIImage?,UpdateDate:Date,NewMessage:String,listend:Bool,sendUID:String){
        self.UID = UID
        self.userNickName = userNickName
        self.profileImage = profileImage
        self.upDateDate = UpdateDate
        self.NewMessage = NewMessage
        self.listend = listend
        self.sendUID = sendUID
    }
}

struct listUserImageStruct{

    ///最初のメッセージを取得する部分を実装したら解放
//    var firstMessage: String
    var UID:String
    var upDateDate:Date
    var image:UIImage?
    
    init(UID:String,UpdateDate:Date,UIimage:UIImage?){
        self.UID = UID
        self.upDateDate = UpdateDate
        self.image = UIimage

    }
}
