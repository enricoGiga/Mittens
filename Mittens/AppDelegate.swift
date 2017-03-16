import UIKit
import CoreData
import Firebase
import FirebaseMessaging
import GoogleSignIn
import UserNotifications
import UserNotificationsUI
import CoreLocation
import FBSDKCoreKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate,CLLocationManagerDelegate{

    var window: UIWindow?
    let locationManager = CLLocationManager()
    
    static var myLocation: String?
   // var locationManager: CLLocationManager!
    let userDefault = UserDef()
    var locationStatus : NSString = "Not Started"
    
    override init() {
        FIRApp.configure()
    }
    
//    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
//        return true
//    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool{
        
        GADMobileAds.configure(withApplicationID: "ca-app-pub-8838198300709607~4073561372");
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        if #available(iOS 10.0, *) {
            let authOptions : UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_,_ in })
            
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            // For iOS 10 data message (sent via FCM)
            FIRMessaging.messaging().remoteMessageDelegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        // Print device token:
        //let token = FIRInstanceID.instanceID().token()!
        //print("••• My token: \(token.characters.count) •••")
        
        let pathChats = AllFirebasePaths.firebase(pathName: "pathChats")!
        Observers.observer.observeChats(chatRef: pathChats, inContext: persistentContainer.viewContext)
        
        if userDefault.returnDistance() == nil {
            userDefault.storeDistance(forDistance: 100)
        }
        
        initLocationManager()
        
        return true
    }
    
    func tokenRefreshNotification(notification: NSNotification) {
        if let ref = FIRInstanceID.instanceID().token() {
             print("InstanceID token: \(ref)")
        }

        
        // Connect to FCM since connection may have failed when attempted before having a token.
        //connectToFcm()
    }
    

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
                
        // Handle Notification:
        let notificationInfo = userInfo["aps"] as? [String:Any] ?? ["not dictionary":"error"]
       
        let hashtag = notificationInfo["chat"] as? String ?? "errore"
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // from main storyboard instatiate a tab bar controller
        let tabVC = storyboard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
        // select allChats's tab
        tabVC.selectedIndex = 1
        let allChatVC = (tabVC.selectedViewController as? UINavigationController)?.topViewController as? AllChatTableViewController
        allChatVC?.chatID = hashtag
        
        window?.rootViewController?.present(tabVC, animated: true, completion: nil)
    }
    
    // Location Manager helper stuff
    func initLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        locationManager.requestAlwaysAuthorization()
    }
    // Location Manager Delegate stuff
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print(error.localizedDescription)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        let locationObj = locations.last!
        let myCoord = locationObj.coordinate
        
        print(myCoord.latitude)
        MyLocationInfo.myLocation.latitude = myCoord.latitude
        print(myCoord.longitude)
        MyLocationInfo.myLocation.longitude = myCoord.longitude
        let geoCoder = CLGeocoder()
        userDefault.storeCenter(latitude: myCoord.latitude, longitude: myCoord.longitude)

        geoCoder.reverseGeocodeLocation(locationObj) { (placemarks, error) in
           // print(placemarks?[0].addressDictionary)
            let city = placemarks?[0].addressDictionary?["City"] as! String?
            let thoroughfare = placemarks?[0].addressDictionary?["Thoroughfare"] as! String?
            let state = placemarks?[0].addressDictionary?["State"] as! String?
            //            AppDelegate.myLocation = city
            MyLocationInfo.myLocation.city = city
            MyLocationInfo.myLocation.thoroughfare = thoroughfare
            MyLocationInfo.myLocation.state = state
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        var shouldIAllow = false
        
        switch status {
        case CLAuthorizationStatus.restricted:
            locationStatus = "Restricted Access to location"
        case CLAuthorizationStatus.denied:
            locationStatus = "User denied access to location"
        case CLAuthorizationStatus.notDetermined:
            locationStatus = "Status not determined"
        default:
            locationStatus = "Allowed to location Access"
            shouldIAllow = true
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LabelHasbeenUpdated"), object: nil)
        if (shouldIAllow == true) {
            NSLog("Location to Allowed")
            // Start location services
            locationManager.startUpdatingLocation()
        } else {
            NSLog("Denied access: \(locationStatus)")
        }
    }
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
//        userDefault.storeCenter(latitude: locValue.latitude, longitude: locValue.longitude)
//        print("locations = \(locValue.latitude) \(locValue.longitude)")
//    }
    //MARK: UNUserNotificationCenterDelegate
    // for use in forground...
    // responde hendling
    private func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {
        //
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {

        let facebook = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.sourceApplication])
        
        let google = GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.sourceApplication])
        
        return facebook || google
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        FIRMessaging.messaging().disconnect()
        print("Disconnected from FCM.")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        FBSDKAppEvents.activateApp()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Mittens")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
 
    // MARK: - Token Generation Updater
    func tokenRefreshNotification(_ notification: Notification) {
        if let ref  = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(ref)")

        }

        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.sandbox)
        // Convert token to string
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        
        // Print it to console
        print("APNs device token: \(deviceTokenString)")
        userDefault.storeMyToken(token: deviceTokenString)
        // Persist it in your backend in case it's new

    }
    
    func connectToFcm() {
        FIRMessaging.messaging().connect { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
}

extension AppDelegate : FIRMessagingDelegate {
    // Receive data message on iOS 10 devices.
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print("%@", remoteMessage.appData)
    }
}
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
       completionHandler([.alert, .badge])
        
        
    }
}
