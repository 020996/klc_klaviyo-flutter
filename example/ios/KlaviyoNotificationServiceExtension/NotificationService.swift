import KlaviyoSwiftExtension
import UserNotifications
import os.log

/// Klaviyo Notification Service Extension
/// Uses official KlaviyoSwiftExtension SDK to handle rich push (images, videos) and badge counts.
class NotificationService: UNNotificationServiceExtension {
    
    private let logger = OSLog(subsystem: "com.abcsoft.sid96604127520.KlaviyoNotificationServiceExtension", category: "RichPush")
    
    var request: UNNotificationRequest!
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.request = request
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        let userInfo = request.content.userInfo
        
        if let bestAttemptContent = bestAttemptContent {
            KlaviyoExtensionSDK.handleNotificationServiceDidReceivedRequest(
                request: self.request,
                bestAttemptContent: bestAttemptContent,
                contentHandler: contentHandler
            )
        } else {
            contentHandler(request.content)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler,
           let bestAttemptContent = bestAttemptContent {
            KlaviyoExtensionSDK.handleNotificationServiceExtensionTimeWillExpireRequest(
                request: request,
                bestAttemptContent: bestAttemptContent,
                contentHandler: contentHandler
            )
        }
    }
}