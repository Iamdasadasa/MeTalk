//
//  AppDelegate.swift
//  Me2
//
//  Created by KOJIRO MARUYAMA on 2022/01/29.
//

import UIKit
import Firebase
import FirebaseCore
import GoogleMobileAds
import FirebaseMessaging
import AudioToolbox
@main

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        ///プッシュ通知設定
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self

        // 初回起動時、プッシュ通知の許可ダイアログを表示させる
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { _, _ in }
        )
    
        application.registerForRemoteNotifications()
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)

        var rootViewController:UIViewController?
        // 1. 初期化
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()

        // 2. 最初に表示する画面を設定
        if let uid = Auth.auth().currentUser?.uid {
            rootViewController = profileSetting()
        } else {
            rootViewController = initialSettingWelcomeViewController()
        }
        
        window?.rootViewController = rootViewController
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

extension AppDelegate: MessagingDelegate {}

extension AppDelegate: UNUserNotificationCenterDelegate {
//    // アプリがフォアグラウンドでプッシュ通知を受信した場合に呼ばれる
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                willPresent notification: UNNotification,
//                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        ///フォアグラウンドでは通知を表示しない
//        return
////        completionHandler([.banner, .badge, .sound])
//    }
//    // アプリがバックグラウンドでプッシュ通知を受信した場合に呼ばれる
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                didReceive response: UNNotificationResponse,
//                                withCompletionHandler completionHandler: @escaping () -> Void) {
//        let userInfo = response.notification.request.content.userInfo
//        completionHandler()
//    }
    
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        // バッジの処理
//        if let badgeCount = userInfo["badge"] as? Int {
//            application.applicationIconBadgeNumber = badgeCount
//        }
//
//        // サウンドの処理
//        if let soundName = userInfo["sound"] as? String {
//            // バイブレーションをトリガーするコード
//            let generator = UINotificationFeedbackGenerator()
//            generator.prepare()
//            generator.notificationOccurred(.success)
//
//        }
//
//        // その他の処理...
//        
//        completionHandler(UIBackgroundFetchResult.newData)
//    }
    
}
