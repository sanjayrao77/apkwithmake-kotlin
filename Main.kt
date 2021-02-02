package com.example.skeleton

import android.app.Activity
import android.content.res.Configuration
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.TextView

class Main: Activity() {
	override fun onCreate(savedInstanceState: Bundle?) {
		super.onCreate(savedInstanceState)
	}
	override fun onResume() {
		super.onResume()
		setContentView(R.layout.main)
		val tv : TextView
		tv=findViewById(R.id.helloworld) as TextView
		tv.setText("Hello world, no java, ant or gradle!")
	}
}
