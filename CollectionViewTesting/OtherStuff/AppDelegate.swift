//
//  AppDelegate.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 2/9/21.
//
//  appID: ca-app-pub-6071058575504654~2118991485
//  adUnitID: ca-app-pub-6071058575504654/8848691990


import UIKit
import GoogleMobileAds
import FirebaseMessaging
import UserNotifications
import FirebaseAnalytics
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {
	override init() {
		super.init()
		
	}

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		GADMobileAds.sharedInstance().start(completionHandler: nil)
		
		Messaging.messaging().delegate = self
		
		if #available(iOS 10.0, *) {
			let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
			UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
			
			UNUserNotificationCenter.current().requestAuthorization(
				options: authOptions,
				completionHandler: { _, _ in}
			)
		} else {
			let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
			application.registerUserNotificationSettings(settings)
		}
		
		application.registerForRemoteNotifications()
		FirebaseApp.configure()

		Messaging.messaging().token { token, error in
			if let error = error {
				print("--Error fetching FCM registration token: \(error)--")
			} else if let token = token {
				print("--FCM registration token: \(token)--")
			}
		}

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
	
	func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
		print("--Firebase registration token: \(String(describing: fcmToken))--")
		
		let dataDict: [String: String] = ["token": fcmToken ?? ""]
		NotificationCenter.default.post(
			name: Notification.Name("FCMToken"),
			object: nil,
			userInfo: dataDict
		)
	}
}

extension AppDelegate : UNUserNotificationCenterDelegate {
	
	// Receive displayed notifications for iOS 10 devices.
	func userNotificationCenter(_ center: UNUserNotificationCenter,
								willPresent notification: UNNotification,
								withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		let userInfo = notification.request.content.userInfo
		
		// Print full message.
		print(userInfo)
		
		// Change this to your preferred presentation option
		completionHandler([[.alert, .sound]])
	}
	
	func userNotificationCenter(_ center: UNUserNotificationCenter,
								didReceive response: UNNotificationResponse,
								withCompletionHandler completionHandler: @escaping () -> Void) {
		let userInfo = response.notification.request.content.userInfo
		
		// Print full message.
		print(userInfo)
		
		completionHandler()
	}
}
