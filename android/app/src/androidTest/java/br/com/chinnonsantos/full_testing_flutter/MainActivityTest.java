package br.com.chinnonsantos.full_testing_flutter;

import androidx.test.rule.ActivityTestRule;
import br.com.chinnonsantos.full_testing_flutter.MainActivity;
import dev.flutter.plugins.integration_test.FlutterTestRunner;
import org.junit.Rule;
import org.junit.runner.RunWith;

@RunWith(FlutterTestRunner.class)
public class MainActivityTest {
    @Rule
    public ActivityTestRule<MainActivity> activityRule =
            new ActivityTestRule<>(MainActivity.class, true, false);
}
