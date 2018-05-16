//
//  AppDelegate.swift
//  TestChat
//
//  Created by Руслан Казюка on 09.02.2018.
//  Copyright © 2018 Руслан Казюка. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import UserNotifications
import FirebaseMessaging
import FirebaseInstanceID
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    static let NOTIFICATION_URL = "https://fcm.googleapis.com/fcm/send"
    static var DEVICEID = String()
    static let SERVERCEY = "AAAAtA1rnxA:APA91bE3DLt8fiJSsVguz_yZn2LPKNXYndNEMlCmIoalRrF9r3r_zXmJjshrJRlMNVsTS_IRgrj6s2WBrOKa7WQLdHevFRtVKhxqs94LYjFmUF3tCp4mo0oKttipj3bCXva3xWawkyzH"
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        firebaseNotificationSetUp(application: application)
        UITabBar.appearance().tintColor = UIColor.white
        UITabBar.appearance().unselectedItemTintColor = UIColor.white
        UITabBar.appearance().backgroundImage = UIImage.colorForNavBar(color: #colorLiteral(red: 0.003921568627, green: 0.7450980392, blue: 0.9411764706, alpha: 1))
        UITabBar.appearance().shadowImage = UIImage.colorForNavBar(color: .white)
        
        let tabController = storyboard.instantiateViewController(withIdentifier: "TabController") as! TabController
        let loginController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        let uid = Auth.auth().currentUser?.uid
        
        if uid == nil {
            window?.rootViewController? = UINavigationController(rootViewController: loginController)
        } else {
            window?.rootViewController =  tabController
        }
        return true
    }

    func firebaseNotificationSetUp(application: UIApplication) {
        Messaging.messaging().delegate = self
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print(userInfo)

        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        guard let tocken = InstanceID.instanceID().token() else {
            return
        }
        AppDelegate.DEVICEID = tocken
        Messaging.messaging().shouldEstablishDirectChannel = true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
        
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }

    func applicationWillTerminate(_ application: UIApplication) {

    }
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
      
        
        let navigation = UINavigationController()
        let tabController = storyboard.instantiateViewController(withIdentifier: "TabController") as! TabController
        let chatGroup = storyboard.instantiateViewController(withIdentifier: "ChatGrupController") as! ChatGrupController
        let chatSingle =  self.storyboard.instantiateViewController(withIdentifier: "ChatSingleController") as! ChatSingleController
        
        let typeChat = userInfo["gcm.notification.isSingle"] as? String
        let idChat = userInfo["gcm.notification.idRoom"] as? String
        
        if typeChat == "1" {
            
            RoomChat.getChatRoombyId(id: idChat!, room: { (chat) in
                
                RoomChat.getCurrentUserFromSingleMessage(chatRoom: chat) { (us) in
                    chatSingle.user = us
                    chatSingle.unicKyeForChatRoom = chat.groupUID
                    chatSingle.isPushingNitification = true
                    navigation.setViewControllers([tabController,chatSingle], animated: true)
                    self.window?.rootViewController =  navigation
                }
            })
        } else {
            
            RoomChat.getChatRoombyId(id: idChat!, room: { (chat) in
                chatGroup.room = chat
                chatGroup.isPushingNitification = true
                navigation.setViewControllers([tabController, chatGroup], animated: true)
                self.window?.rootViewController =  navigation
            })
            
        }
        
        completionHandler()
    }
}

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        guard let newTocken = InstanceID.instanceID().token() else {
            return
        }
        AppDelegate.DEVICEID = newTocken
        Messaging.messaging().shouldEstablishDirectChannel = true
        func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
            print("Received data message: \(remoteMessage.appData)")
        }
    }
}

