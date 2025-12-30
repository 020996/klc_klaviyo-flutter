package com.abc.klc_klaviyo_flutter

import android.util.Log
import com.google.firebase.messaging.RemoteMessage
import com.klaviyo.pushFcm.KlaviyoPushService

/**
 * Service xử lý Klaviyo push notifications bằng cách kế thừa KlaviyoPushService.
 * Klaviyo SDK sẽ tự động xử lý việc hiển thị notifications.
 * 
 * User cần add service này vào AndroidManifest.xml của app:
 * 
 * <service
 *     android:name="com.example.klc_klaviyo_flutter.KlaviyoMessagingService"
 *     android:exported="false">
 *     <intent-filter>
 *         <action android:name="com.google.firebase.MESSAGING_EVENT" />
 *     </intent-filter>
 * </service>
 */
class KlaviyoMessagingService : KlaviyoPushService() {

    companion object {
        private const val TAG = "KlaviyoMessaging"
    }

    /**
     * Được gọi khi có FCM token mới.
     * KlaviyoPushService sẽ tự động gửi token lên Klaviyo.
     */
    override fun onNewToken(newToken: String) {
        super.onNewToken(newToken)
        Log.d(TAG, "New FCM token received: ${newToken.substring(0, 20)}...")
    }

    /**
     * Được gọi khi nhận được message từ FCM.
     * KlaviyoPushService sẽ tự động hiển thị notification.
     */
    override fun onMessageReceived(message: RemoteMessage) {
        super.onMessageReceived(message)
        Log.d(TAG, "Message received from: ${message.from}")
        Log.d(TAG, "Notification: ${message.notification?.title}")
    }

    /**
     * Được gọi khi nhận Klaviyo notification message.
     * Override để custom hành vi nếu cần.
     */
    override fun onKlaviyoNotificationMessageReceived(message: RemoteMessage) {
        super.onKlaviyoNotificationMessageReceived(message)
        Log.d(TAG, "Klaviyo notification received: ${message.notification?.title}")
    }

    /**
     * Được gọi khi nhận Klaviyo custom data message.
     * Override để xử lý custom data nếu cần.
     */
    override fun onKlaviyoCustomDataMessageReceived(customData: Map<String, String>, message: RemoteMessage) {
        super.onKlaviyoCustomDataMessageReceived(customData, message)
        Log.d(TAG, "Klaviyo custom data received: $customData")
    }
}