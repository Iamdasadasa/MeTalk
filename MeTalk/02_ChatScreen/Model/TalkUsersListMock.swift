import UIKit

struct talkListUserStruct{

    ///最初のメッセージを取得する部分を実装したら解放
//    var firstMessage: String
    var UID:String
    var userNickName: String?
    var profileImage: UIImage?
    var NewMessage: String
    var upDateDate:Date

    init(UID:String,userNickName:String?,profileImage:UIImage?,UpdateDate:Date,NewMessage:String){
        self.UID = UID
        self.userNickName = userNickName
        self.profileImage = profileImage
        self.upDateDate = UpdateDate
        self.NewMessage = NewMessage
    }
}
