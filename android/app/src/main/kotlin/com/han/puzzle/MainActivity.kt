package com.han.fifteen

import android.graphics.Color
import android.os.Bundle
import androidx.activity.SystemBarStyle
import androidx.activity.enableEdgeToEdge
import io.flutter.embedding.android.FlutterFragmentActivity

// 💡 enableEdgeToEdge()는 ComponentActivity 확장 함수이므로
//    FlutterActivity(→ android.app.Activity) 대신
//    FlutterFragmentActivity(→ FragmentActivity → ComponentActivity)를 상속한다.
class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 💡 상태/내비게이션 바를 투명하게 두고 아이콘은 밝게(흰색) 표시
        //    → 어두운 배경 위의 흰색 텍스트 UI와 시각적 일치 유지
        enableEdgeToEdge(
            statusBarStyle = SystemBarStyle.dark(Color.TRANSPARENT),
            navigationBarStyle = SystemBarStyle.dark(Color.TRANSPARENT),
        )
    }
}
