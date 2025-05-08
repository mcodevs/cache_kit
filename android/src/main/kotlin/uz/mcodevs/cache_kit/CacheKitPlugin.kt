package uz.mcodevs.cache_kit

import android.content.Context
import android.app.ActivityManager
import android.os.Build
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** CacheKitPlugin */
class CacheKitPlugin: FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
  private lateinit var context: Context

  @RequiresApi(Build.VERSION_CODES.KITKAT)
  private fun clearUserData(): Boolean {
      val activityManager =
          context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
      return activityManager.clearApplicationUserData()
  }

  private lateinit var channel: MethodChannel

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    context = binding.applicationContext
    channel = MethodChannel(binding.binaryMessenger, "cache_kit")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    if (call.method == "clear_app_data") {
      val success = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
        clearUserData()
      } else {
        // Fallback for API < 19; nothing to clear programmatically
        false
      }
      result.success(success)
    } else {
      result.notImplemented()
    }
  }

  // ActivityAware interfeysi uchun bo‘sh implementation
  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
  override fun onAttachedToActivity(binding: ActivityPluginBinding) {}
  override fun onDetachedFromActivityForConfigChanges() {}
  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}
  override fun onDetachedFromActivity() {}
}
