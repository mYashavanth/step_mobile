package com.ghastep;

import android.os.Bundle;
import android.view.WindowManager;
import io.flutter.embedding.android.FlutterFragmentActivity;

public class MainActivity extends FlutterFragmentActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // Prevent screenshots and screen recording
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_SECURE, 
                           WindowManager.LayoutParams.FLAG_SECURE);
    }
}
