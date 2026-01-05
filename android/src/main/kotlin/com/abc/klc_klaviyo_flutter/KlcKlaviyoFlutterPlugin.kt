package com.abc.klc_klaviyo_flutter

import android.app.Activity
import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.core.app.NotificationManagerCompat
import com.google.firebase.messaging.FirebaseMessaging
import com.klaviyo.analytics.Klaviyo
import com.klaviyo.analytics.model.Event
import com.klaviyo.analytics.model.EventMetric
import com.klaviyo.forms.registerForInAppForms
import com.klaviyo.forms.unregisterFromInAppForms
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class KlcKlaviyoFlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
    
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: Activity? = null

    companion object {
        private const val TAG = "KlaviyoFlutterPlugin"
        private const val CHANNEL_NAME = "com.klaviyo.flutter/klaviyo_sdk"
        private var instance: KlcKlaviyoFlutterPlugin? = null
        
        // Để KlaviyoPushService gọi được
        fun sendPushTokenToFlutter(token: String) {
            instance?.let { plugin ->
                Handler(Looper.getMainLooper()).post {
                    plugin.channel.invokeMethod("onPushTokenReceived", mapOf("token" to token))
                }
            }
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "🔌 Plugin attached to engine")
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
        instance = this
        Log.d(TAG, "✅ Plugin initialized successfully")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        instance = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        Log.d(TAG, "📞 Method called: ${call.method}")
        when (call.method) {
            "initialize" -> handleInitialize(call, result)
            "setEmail" -> handleSetEmail(call, result)
            "setPhoneNumber" -> handleSetPhoneNumber(call, result)
            "setExternalId" -> handleSetExternalId(call, result)
            "setProfile" -> handleSetProfile(call, result)
            "resetProfile" -> handleResetProfile(result)
            "createEvent" -> handleCreateEvent(call, result)
            "setPushToken" -> handleSetPushToken(call, result)
            "getPushToken" -> handleGetPushToken(result)
            "getEmail" -> result.success(Klaviyo.getEmail())
            "getPhoneNumber" -> result.success(Klaviyo.getPhoneNumber())
            "getExternalId" -> result.success(Klaviyo.getExternalId())
            "requestPushPermission" -> handleRequestPushPermission(result)
            "getPushPermissionStatus" -> handleGetPushPermissionStatus(result)
            "registerForInAppForms" -> handleRegisterForInAppForms(result)
            "unregisterFromInAppForms" -> handleUnregisterFromInAppForms(result)
            else -> {
                Log.w(TAG, "⚠️ Method not implemented: ${call.method}")
                result.notImplemented()
            }
        }
    }

    private fun handleInitialize(call: MethodCall, result: Result) {
        Log.d(TAG, "🚀 Initializing Klaviyo...")
        val apiKey = call.argument<String>("apiKey")
        if (apiKey.isNullOrEmpty()) {
            result.error("INVALID_ARGS", "API key required", null)
            return
        }
        try {
            Klaviyo.initialize(apiKey, context)
            Log.d(TAG, "✅ Klaviyo initialized with API key: ${apiKey.take(6)}...")
            result.success(null)
        } catch (e: Exception) {
            result.error("INIT_ERROR", e.message, null)
        }
    }

    private fun handleSetEmail(call: MethodCall, result: Result) {
        val email = call.argument<String>("email")
        if (email.isNullOrEmpty()) {
            result.error("INVALID_ARGS", "Email required", null)
            return
        }
        Klaviyo.setEmail(email)
        result.success(null)
    }

    private fun handleSetPhoneNumber(call: MethodCall, result: Result) {
        val phone = call.argument<String>("phoneNumber")
        if (phone.isNullOrEmpty()) {
            result.error("INVALID_ARGS", "Phone required", null)
            return
        }
        Klaviyo.setPhoneNumber(phone)
        result.success(null)
    }

    private fun handleSetExternalId(call: MethodCall, result: Result) {
        val id = call.argument<String>("externalId")
        if (id.isNullOrEmpty()) {
            result.error("INVALID_ARGS", "External ID required", null)
            return
        }
        Klaviyo.setExternalId(id)
        result.success(null)
    }

    private fun handleSetProfile(call: MethodCall, result: Result) {
        Log.d(TAG, "👤 Setting profile...")
        try {
            call.argument<String>("email")?.let {
                Log.d(TAG, "  ✉️ Email: $it")
                Klaviyo.setEmail(it)
            }
            call.argument<String>("phoneNumber")?.let {
                Log.d(TAG, "  📱 Phone: $it")
                Klaviyo.setPhoneNumber(it)
            }
            call.argument<String>("externalId")?.let {
                Log.d(TAG, "  🆔 External ID: $it")
                Klaviyo.setExternalId(it)
            }
            Log.d(TAG, "✅ Profile set successfully")
            result.success(null)
        } catch (e: Exception) {
            result.error("SET_PROFILE_ERROR", e.message, null)
        }
    }

    private fun handleResetProfile(result: Result) {
        Klaviyo.resetProfile()
        result.success(null)
    }

    private fun handleCreateEvent(call: MethodCall, result: Result) {
        val name = call.argument<String>("name")
        Log.d(TAG, "📊 Creating event: $name")
        if (name.isNullOrEmpty()) {
            Log.e(TAG, "❌ Event name is empty")
            result.error("INVALID_ARGS", "Event name required", null)
            return
        }

        try {
            val event = Event(EventMetric.CUSTOM(name))
            Klaviyo.createEvent(event)
            Log.d(TAG, "✅ Event created: $name")
            result.success(null)
        } catch (e: Exception) {
            result.error("CREATE_EVENT_ERROR", e.message, null)
        }
    }

    private fun handleSetPushToken(call: MethodCall, result: Result) {
        val token = call.argument<String>("token")
        if (token.isNullOrEmpty()) {
            result.error("INVALID_ARGS", "Token required", null)
            return
        }
        Klaviyo.setPushToken(token)
        result.success(null)
    }

    private fun handleGetPushToken(result: Result) {
        FirebaseMessaging.getInstance().token.addOnCompleteListener { task ->
            if (task.isSuccessful) {
                result.success(task.result)
            } else {
                result.success(null)
            }
        }
    }

    private fun handleRequestPushPermission(result: Result) {
        Log.d(TAG, "🔔 Requesting push permission...")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            activity?.let { act ->
                Log.d(TAG, "  Requesting POST_NOTIFICATIONS permission")
                act.requestPermissions(
                    arrayOf(android.Manifest.permission.POST_NOTIFICATIONS),
                    1001
                )
            }
        }

        FirebaseMessaging.getInstance().token.addOnCompleteListener { task ->
            if (task.isSuccessful) {
                val token = task.result
                Klaviyo.setPushToken(token)
                channel.invokeMethod("onPushTokenReceived", mapOf("token" to token))
            } else {
                Log.e(TAG, "❌ Failed to get FCM token: ${task.exception?.message}")
            }
        }

        result.success(null)
    }

    private fun handleGetPushPermissionStatus(result: Result) {
        val enabled = NotificationManagerCompat.from(context).areNotificationsEnabled()
        result.success(if (enabled) "authorized" else "denied")
    }

    // MARK: - In-App Forms

    /// Registers for in-app forms to display when conditions are met
    private fun handleRegisterForInAppForms(result: Result) {
        Log.d(TAG, "📝 Registering for in-app forms...")
        try {
            Handler(Looper.getMainLooper()).post {
                Klaviyo.registerForInAppForms()
            }
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "❌ Register for in-app forms error: ${e.message}")
            result.error("REGISTER_FORMS_ERROR", e.message, null)
        }
    }

    /// Unregisters from in-app forms to stop displaying them
    private fun handleUnregisterFromInAppForms(result: Result) {
        Log.d(TAG, "📝 Unregistering from in-app forms...")
        try {
            Klaviyo.unregisterFromInAppForms()
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "❌ Unregister from in-app forms error: ${e.message}")
            result.error("UNREGISTER_FORMS_ERROR", e.message, null)
        }
    }
}
