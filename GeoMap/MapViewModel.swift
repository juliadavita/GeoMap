import Foundation
import CoreLocation
import MapKit

// MapViewModel contains all the data what the content view needs

// MapDefaults shows the map with the location of Hogeschool Rotterdam
struct MapDefaults {
    static let location = Location(
        name: "Hogeschool Rotterdam",
        coordinate: CLLocationCoordinate2D(
            latitude: 51.917220,
            longitude: 4.484050
        )
    )
    // Zoom
    static let span = MKCoordinateSpan(
        latitudeDelta: 0.01,
        longitudeDelta: 0.01
    )
}

// NotificationReason literally gives a reason to send a notification if one of the two cases is triggered
// enum is a way for you to define your own kind of value
enum NotificationReason {
    case userEnteredRegion
    case userLeftRegion
}

final class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region = MKCoordinateRegion(
        center: MapDefaults.location.coordinate,
        span: MapDefaults.span
    )

    var locationManager: CLLocationManager? // optional since you can turn off locations for your whole phone
    var locationServicesEnabled: Bool {
        return CLLocationManager.locationServicesEnabled()
    }

    var previousNotificationReason: NotificationReason?

    func checkForLocationPermissions() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
        } else {
            print("Location Services are disabled.")
        }
    }

    
    // Check if user gave the correct authorization to the app
    func checkLocationAuthorization() {
        // guard is a check of integrity preconditions used to avoid errors during execution
        guard let locationManager = locationManager else { return }
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .restricted:
            print("Location is restricted using parental controls.")
        case .denied:
            print("Location is denied.")
        case .authorizedAlways, .authorizedWhenInUse:
            updateRegion()
            print("Location is set to autherize when in use.")
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }

    private func updateRegion() {
        guard let locationManager = locationManager else { return }
        if let coordinates = locationManager.location?.coordinate {
            region = MKCoordinateRegion(
                center: coordinates,
                span: MapDefaults.span
            )
        }
    }

    func saveRegion() {
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else { return }
        guard let maxDistance = locationManager?.maximumRegionMonitoringDistance else { return }
        let monitorRegion = CLCircularRegion(
            center: region.center,
            radius: maxDistance,
            identifier: "currentLocation"
        )
        monitorRegion.notifyOnEntry = true
        monitorRegion.notifyOnExit = true
        locationManager?.startMonitoring(for: monitorRegion)
      print("Location Manager started monitoring")
    }

    func notificationRequest() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                print("UNUserNotificationCenter: User granted permission.")
            } else if let err = error {
                print("UNUserNotificationCenter: An error occured \(err)")
            }
        }
    }

    func clearNotifications() {
      UIApplication.shared.applicationIconBadgeNumber = 0
      UNUserNotificationCenter.current().removeAllDeliveredNotifications()
      UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    private func sendNotification(reason: NotificationReason) {
        guard reason != previousNotificationReason else { return }
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "GeoMap Region Notifier"
        notificationContent.body =
        reason == .userEnteredRegion ? "You entered the saved geofence region." : "You left the saved geofence region."
        notificationContent.sound = .default
        notificationContent.badge =  UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier:
                reason == .userEnteredRegion ? "user_entered_region" : "user_exit_region",
            content: notificationContent,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error)")
            }
        }
        previousNotificationReason = reason
        // Set User Default Key
        let defaults = UserDefaults.standard
        let isUserInRegion: Bool = reason == .userEnteredRegion
        defaults.set(isUserInRegion, forKey: "IsUserInRegion")
    }

    func isUserInRegion() -> Bool {
        let defaults = UserDefaults.standard
        let isUserInRegion = defaults.bool(forKey: "IsUserInRegion")
        return isUserInRegion
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("User enteres region")
        if UIApplication.shared.applicationState != .active {
            sendNotification(reason: .userEnteredRegion)
        }
    }
   
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("User left region")
        if UIApplication.shared.applicationState != .active {
            sendNotification(reason: .userLeftRegion)
        }
    }
}
