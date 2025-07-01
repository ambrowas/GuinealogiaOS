import UIKit
import UserNotifications
import Firebase
import FirebaseInAppMessaging
import FirebaseDatabase
import FirebaseAuth
import FirebaseAnalytics
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, InAppMessagingDisplayDelegate, MessagingDelegate {
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize Firebase
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        // Set Messaging delegate for FCM token retrieval
        Messaging.messaging().delegate = self

        // Set UNUserNotificationCenter delegate
        UNUserNotificationCenter.current().delegate = self

        // Request notification permissions
        requestNotificationPermission()

        // Fetch Firebase Installation ID
        fetchAndStoreFirebaseInstallationID()
        
        // In-App Messaging delegate
        InAppMessaging.inAppMessaging().delegate = self
        
        // Analytics
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: "MainScreen"
        ])
        
        if Auth.auth().currentUser != nil {
            uploadStoredFCMTokenIfNeeded()
        }

        return true
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else {
            print("Failed to fetch FCM token")
            return
        }
        print("✅ FCM Token: \(fcmToken)")

        UserDefaults.standard.set(fcmToken, forKey: "fcmTokenForDebug")

        if let userID = Auth.auth().currentUser?.uid {
            let ref = Database.database().reference()
            ref.child("user").child(userID).updateChildValues(["FCMToken": fcmToken]) { error, _ in
                if let error = error {
                    print("Error saving FCM token to database: \(error.localizedDescription)")
                } else {
                    print("✅ FCM token successfully saved to database for user ID: \(userID)")
                }
            }
        } else {
            print("User not logged in, deferring FCM token upload")
        }
    }

    func requestNotificationPermission() {
        print("Requesting notification permission")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            guard let strongSelf = self else { return }
            print("Notification permission response received")

            if let error = error {
                print("Error requesting notification permissions: \(error.localizedDescription)")
                return
            }

            if granted {
                print("Notification permission granted")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("Notification permission not granted, scheduling alert presentation")
                // Schedule the alert presentation after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    strongSelf.showNotificationPermissionAlert()
                }
            }
        }
    }


    func showNotificationPermissionAlert() {
        print("Presenting notification permission alert")
        let alertController = UIAlertController(
            title: "Atención",
            message: "Activa las notificaciones para recibir códigos de juego y otros mensajes importantes. ¿Quieres activarlo?",
            preferredStyle: .alert
        )

        let settingsAction = UIAlertAction(title: "Si", style: .default) { (_) in
            // Open app settings
            if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                UIApplication.shared.open(appSettings)
            }
        }

        let cancelAction = UIAlertAction(title: "No", style: .cancel)

        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)

        // Find the topmost view controller to present the alert
        if let topController = getTopViewController() {
            topController.present(alertController, animated: true)
            print("Notification permission alert presented")
        } else {
                    print("Unable to find top view controller to present alert")
        }
    }

    func getTopViewController() -> UIViewController? {
        // Access the current window scene
        guard let windowScene = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .first(where: { $0 is UIWindowScene }) as? UIWindowScene else {
            return nil
        }

        // Find the key window within the window scene
        guard let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }

        // Traverse the view controller hierarchy to find the topmost view controller
        var topController = keyWindow.rootViewController
        while let presentedViewController = topController?.presentedViewController {
            topController = presentedViewController
        }

        return topController
    }

    
    func fetchAndStoreFirebaseInstallationID() {
        Installations.installations().installationID { (installationID, error) in
            if let error = error {
                print("Error fetching installation ID: \(error)")
                return
            }
            if let installationID = installationID {
                // Save the FID in UserDefaults
                UserDefaults.standard.set(installationID, forKey: "firebaseInstallationID")
                // Update in database if user is logged in
                self.updateFirebaseInstallationIDInDatabaseIfNeeded(installationID)
            }
        }
    }
    
    
    func updateFirebaseInstallationIDInDatabaseIfNeeded(_ installationID: String) {
        if let userID = Auth.auth().currentUser?.uid {
            // Reference to your database
            let ref = Database.database().reference()

            // Update the installation ID in the database
            ref.child("user").child(userID).updateChildValues(["InstallationID": installationID]) { error, _ in
                if let error = error {
                    print("Error saving installation ID to database: \(error.localizedDescription)")
                } else {
                    print("Installation ID successfully saved to database")
                }
            }
        }
    }
    
    func uploadStoredFCMTokenIfNeeded() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("⚠️ User not logged in, skipping FCM token upload")
            return
        }

        if let fcmToken = UserDefaults.standard.string(forKey: "fcmTokenForDebug") {
            let ref = Database.database().reference()
            ref.child("user").child(userID).updateChildValues(["FCMToken": fcmToken]) { error, _ in
                if let error = error {
                    print("❌ Error saving FCM token to database: \(error.localizedDescription)")
                } else {
                    print("✅ Stored FCM token successfully saved to database for user ID: \(userID)")
                    UserDefaults.standard.removeObject(forKey: "fcmTokenForDebug")
                }
            }
        } else {
            print("⚠️ No stored FCM token found to upload")
        }
    }


    func updateUserDeviceTokenInDatabase(token: String) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user logged in, cannot update device token")
            return
        }

        // Reference to your Firebase database
        let ref = Database.database().reference()

        // Update the token in the database
        ref.child("user").child(userID).updateChildValues(["Token": token]) { error, _ in
            if let error = error {
                print("Error saving token to database: \(error.localizedDescription)")
            } else {
                print("Device token successfully saved to database for user ID: \(userID)")
                // Optionally, clear the token from UserDefaults after successful upload
                UserDefaults.standard.removeObject(forKey: "deviceToken")
            }
        }
    }


    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        UserDefaults.standard.set(token, forKey: "deviceToken")

        // Link APNs token to FCM
        Messaging.messaging().apnsToken = deviceToken

        if Auth.auth().currentUser != nil {
            updateUserDeviceTokenInDatabase(token: token)
        }
    }


    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }


    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            print("Will present notification: \(notification)")
            completionHandler([.banner, .sound])
        }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
          print("Did receive response to notification: \(response)")
          let notification = response.notification
          logNotificationReceived(notification: notification)
          completionHandler()
      }
    
    private func logNotificationReceived(notification: UNNotification) {
        print("Logging received notification: \(notification)")
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not logged in, deferring notification logging.")
            return  // Exit early if the user is not logged in
        }

        // Extract the message ID from the notification
        let userInfo = notification.request.content.userInfo
        guard let messageID = userInfo["gcm.message_id"] as? String else {
            print("Message ID not found")
            return
        }

        // Get the current date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateReceived = dateFormatter.string(from: Date())

        // Reference to your Firebase database
        let ref = Database.database().reference()

        // Prepare the data to be saved
        let notificationData: [String: Any] = ["messageID": messageID, "dateReceived": dateReceived]

        // Update the latest notification data under the user's node
        ref.child("user").child(userID).child("latestNotification").setValue(notificationData) { error, _ in
            if let error = error {
                print("Error updating latest notification data in database: \(error.localizedDescription)")
            } else {
                print("Latest notification data successfully updated in database")
            }
        }
    }
    
    func attemptToUpdateDeviceTokenInDatabase() {
        if let token = UserDefaults.standard.string(forKey: "deviceToken") {
            updateUserDeviceTokenInDatabase(token: token)
        }
    }
    
    // MARK: - InAppMessagingDisplayDelegate

    func messageClicked(_ inAppMessage: InAppMessagingDisplayMessage) {
        print("In-app message clicked: \(inAppMessage)")
        // Handle in-app message click
    }

    func messageDismissed(_ inAppMessage: InAppMessagingDisplayMessage, dismissType: InAppMessagingDismissType) {
        print("In-app message dismissed: \(inAppMessage)")
        // Handle in-app message dismissal
    }

    func impressionDetected(for inAppMessage: InAppMessagingDisplayMessage) {
        print("Impression for in-app message detected: \(inAppMessage)")
        // Handle in-app message impression
    }

    func displayError(for inAppMessage: InAppMessagingDisplayMessage, error: Error) {
        print("Error displaying in-app message: \(inAppMessage), error: \(error)")
        // Handle errors in displaying in-app message
    }

  }

