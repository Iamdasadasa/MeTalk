import UIKit

struct UserInfo{

    ///最初のメッセージを取得する部分を実装したら解放
//    var firstMessage: String
    var userNickName: String
    var profileImage: UIImage
    
    init(userNickName: String, profileImage: UIImage) {
        self.userNickName = userNickName
        self.profileImage = profileImage
    }

//    static func loadMessage(text: String, user: userType,data:Date,messageID:String) -> MockMessage {
    //        }
    
}
