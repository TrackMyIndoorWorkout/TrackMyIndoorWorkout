package dev.csaba.track_my_indoor_exercise;

import android.os.Bundle;
import dev.flutter.plugins.e2e.E2EPlugin;
import io.flutter.app.FlutterActivity;
import com.pauldemarco.flutter_blue.FlutterBluePlugin;

public class EmbeddingV1Activity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    FlutterBluePlugin.registerWith(registrarFor("dev.csaba.track_my_indoor_exercise.FlutterBluePlugin"));
    E2EPlugin.registerWith(registrarFor("dev.flutter.plugins.e2e.E2EPlugin"));
  }
}
