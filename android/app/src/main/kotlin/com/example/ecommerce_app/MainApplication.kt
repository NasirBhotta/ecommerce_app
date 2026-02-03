package com.example.ecommerce_app

import android.app.Application
import com.facebook.FacebookSdk
import com.facebook.appevents.AppEventsLogger

class MainApplication : Application() {
  override fun onCreate() {
    super.onCreate()
    FacebookSdk.sdkInitialize(applicationContext)
    AppEventsLogger.activateApp(this)
  }
}
