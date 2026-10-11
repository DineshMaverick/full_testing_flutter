# Flutter App's simplest automated full test

[![Codemagic build status](https://api.codemagic.io/apps/5ddbe31c011bc93c37050c9f/5ddbe31c011bc93c37050c9e/status_badge.svg)](https://codemagic.io/apps/5ddbe31c011bc93c37050c9f/5ddbe31c011bc93c37050c9e/latest_build) [![Travis build status](https://img.shields.io/travis/chinnonsantos/full_testing_flutter/master?logo=travis)](https://travis-ci.org/chinnonsantos/full_testing_flutter) [![Codecov coverage](https://codecov.io/gh/chinnonsantos/full_testing_flutter/branch/master/graph/badge.svg)](https://codecov.io/gh/chinnonsantos/full_testing_flutter) [![Flutter version](https://img.shields.io/badge/flutter-3.24%2B-blue?logo=flutter)](https://flutter.dev/docs/get-started/install) [![GitHub license](https://img.shields.io/github/license/chinnonsantos/full_testing_flutter)](https://choosealicense.com/licenses/mit/) [![Twitter follow](https://img.shields.io/twitter/follow/chinnonsantos?label=follow&style=flat&logo=twitter)](https://twitter.com/intent/follow?screen_name=chinnonsantos) [![Slack channel](https://img.shields.io/badge/slack-%23geral-blueviolet?logo=slack)](https://join.slack.com/t/chinnonsantos-nudemo/signup) [![Open source Love](https://badges.frapsoft.com/os/v2/open-source.svg?v=103)](https://github.com/ellerbrock/open-source-badges/)

This project shows an example of the main forms of automated testing in Flutter mobile App, including integration into a [CI/CD platform][], as follows:

- [Unitary][] (including [mocking][] on unitary);
- [Widgets][];
- [Integration][] (or assertion).

Using native libraries or recommended by official Flutter documentation (Google).

> Note that everything here fits within the guidelines set out in [Effective Dart][].

[CI/CD platform]: https://en.wikipedia.org/wiki/CI/CD
[Unitary]: https://flutter.dev/docs/cookbook/testing/unit/introduction
[mocking]: https://flutter.dev/docs/cookbook/testing/unit/mocking
[Widgets]: https://flutter.dev/docs/cookbook/testing/widget/introduction
[Integration]: https://flutter.dev/docs/cookbook/testing/integration/introduction
[Effective Dart]: https://www.dartlang.org/guides/language/effective-dart

## Nudemo - Flutter APP + AWS DeviceFarm Automation Tests (Backend in Clojure)

[<img width="1215" alt="Captura de Tela 2024-09-23 às 16 57 46" src="https://github.com/user-attachments/assets/e2bb12c2-72db-413c-8b3a-17bf8793a73b">](https://www.youtube.com/watch?v=cBgz7RTjDeo)

https://hub.docker.com/u/chinnonsantos

## Codemagic - CI for Flutter

At the [Flutter Live][] 2018 conference in London, [Nevercode][] launched their dedicated CI/CD solution for Flutter apps which is known as [Codemagic][].

This project uses **Codemagic for CI/CD**, selected after various analysis and testing with other CI platforms ([Travis CI][], [Codecov][], [Coveralls][]...), which support the Dart language (in some cases only Dart < 2.0), but do not have good support for the Flutter App.

> "Codemagic is the official CI/CD solution dedicated just for Flutter apps."
> \- Getting Started with Codemagic

See more details about Codemagic in '[Getting Started with Codemagic]'.

[Flutter Live]: https://developers.google.com/events/flutter-live/
[Nevercode]: https://nevercode.io/
[Codemagic]: https://codemagic.io/
[Travis CI]: https://travis-ci.org/
[Codecov]: https://codecov.io/
[Coveralls]: https://coveralls.io/
[Getting Started with Codemagic]: https://blog.codemagic.io/getting-started-with-codemagic/

## Prerequisites

You will need Flutter 3.24 or later, the Android SDK, and Java 17. Android Studio can install the Android SDK and create an emulator. Verify the setup with:

    flutter doctor
    flutter doctor --android-licenses

In Android Studio, start an Android emulator before running the app. From the project root, fetch dependencies and check the available device IDs:

    flutter pub get
    flutter devices

Run the app on the selected emulator (replace `<emulator-id>` with the ID shown by `flutter devices`):

    flutter run -d <emulator-id>

If only one emulator/device is running, `flutter run` selects it automatically.

> The Dart SDK **is not required** because Flutter has _[Dart language][]_ support as an integrated tool in the framework.

[Flutter]: https://flutter.dev/
[Dart language]: https://dart.dev/

**Libraries:**

- [provider][] 6.x
- [integration_test][] (Flutter SDK)
- [flutter_driver][] (Flutter SDK, legacy integration tests)
- [flutter_lints][] 5.x (dev)

[provider]: https://pub.dev/packages/provider
[integration_test]: https://pub.dev/packages/integration_test
[flutter_driver]: https://api.flutter.dev/flutter/flutter_driver/flutter_driver-library.html
[flutter_lints]: https://pub.dev/packages/flutter_lints

## Running tests

To automatically [formatting][] code, run:

    dart format lib test test_driver integration_test

[formatting]: https://flutter.dev/docs/development/tools/formatting

To analyzing the Dart language code, run:

    flutter analyze

> The [Dart analyzer][] will check your code and look for possible errors.

[Dart analyzer]: https://flutter.dev/docs/testing/debugging#the-dart-analyzer

To [testing] the project, run:

    flutter test

[testing]: https://flutter.dev/docs/testing

To check test coverage, run:

- Run test with `--coverage` flag:

      flutter test --coverage

- Convert the LCOV report generated to a readable HTML file:

      genhtml coverage/lcov.info -o coverage/html

  > The **`flutter test --coverage`** command will generate a **`lcov.info`** file, you will need to install the **[LCOV][]** program to convert (**`genhtml ...`**) the report to an HTML file (human readable).

- Open the HTML report (with a Web Browser)

      google-chrome coverage/html/index.html

[LCOV]: http://ltp.sourceforge.net/coverage/lcov.php

To test only **Unit tests** of the project, run:

    flutter test test/unit/

To test only **Widget tests** of the project, run:

    flutter test test/widget/

The sample app demonstrates dependency injection with Provider: `MyApp` accepts an optional `PersonFormModel` and otherwise creates one. The form has name and age fields with validation; submitting valid values displays the result. Dependency-injection scenarios are in `test/unit/dependency_injection_test.dart`.

To run the Flutter Driver integration test on a connected Android device, run:

    flutter drive --target=test_driver/app.dart -d <device-id>

The BrowserStack workflow uses the modern `integration_test` test below:

    flutter test integration_test/app_test.dart -d <device-id>

To run the unit and widget tests here and the device integration test on BrowserStack, add `BROWSERSTACK_USERNAME` and `BROWSERSTACK_ACCESS_KEY` as Codespaces secrets, then run:

    ./scripts/run_browserstack.sh

The script defaults to the `Google Pixel 7-13.0` BrowserStack device; override it by setting `BROWSERSTACK_DEVICE`. It runs unit and widget tests locally, builds and uploads the Android app and integration-test APKs, then waits for the BrowserStack result. The Codespace needs Flutter, the Android SDK/command-line tools, Java 17, `curl`, and `jq`. No local Android emulator is needed. Keep the access key in Codespaces secrets, not in the repository. The remote device run is the integration test; unit and widget test output remains in the Codespace terminal.

### Run the integration test on BrowserStack iOS

The iOS BrowserStack workflow uses XCUITest, not Android Espresso. The Xcode project includes a `RunnerTests` target configured for Flutter's `integration_test` runner. On macOS, set `BROWSERSTACK_USERNAME`, `BROWSERSTACK_ACCESS_KEY`, `IOS_DEVELOPMENT_TEAM` (your Apple Developer team ID), and `BROWSERSTACK_IOS_DEVICE` (the exact iPhone model and OS version from BrowserStack), then run:

    bash scripts/run_browserstack_ios.sh

The script installs the Flutter CocoaPods, builds and signs the app IPA, builds and packages the XCUITest runner ZIP, uploads both artifacts, starts the BrowserStack build, and waits for its result. The Mac needs Flutter, CocoaPods, Xcode, and an Apple Developer account that can provision the app and test runner. If artifacts have already been built, set `BROWSERSTACK_IOS_APP_PATH` and `BROWSERSTACK_IOS_TEST_SUITE_PATH` to reuse them; in that case the upload can also run from Linux. Building/signing requires macOS and Xcode. Keep credentials in Codespaces secrets, not in the repository.

To run **Formatting code** ✔️; **Analyzing code** 🔍; **Unit test code** 🆗; **Widget test** 📲 and **Test coverage** ☔️. everything together ⏲️:

    sh scripts/flutter_test.sh

## Drive testing on AWS Device Farm with Sylph

To runs Flutter integration tests on real devices in cloud, use the **Sylph**.

- Install Sylph:

      pub global activate sylph

    > For more details see [Sylph][].

- Configure the [AWS CLI][] credentials:

      $ aws configure
      AWS Access Key ID [None]: YOUR_KEY_ID_HERE
      AWS Secret Access Key [None]: YOUR_SECRET_ACCESS_KEY_HERE
      Default region name [None]: us-west-2
      Default output format [None]: json

    > The AWS Device Farm is only available in Oregon region (**us-west-2**)!

- Run the Sylph:

      sylph

    > Sylph uses the [`sylph.yaml`][] file in this repository to configure and run device on AWS.
    >> By default, it has only two Android devices (Samsung Galaxy S9+ and Samsung Galaxy J7).
    >> Running iOS devices requires an [Apple Developer Certificate] (Team ID), We don't cover this steps!

  ![Screenshot from 2019-11-26 16-36-14](https://user-images.githubusercontent.com/3258293/69670720-47cb2300-1073-11ea-8035-1754d43ae395.png)

[Sylph]: https://github.com/mmcc007/sylph
[AWS CLI]: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html
[`sylph.yaml`]: https://github.com/chinnonsantos/full_testing_flutter/blob/master/sylph.yaml
[Apple Developer Certificate]: https://developer.apple.com/account/#/membership

## Drive testing on Codemagic CI/CD (using AWS Device Farm and Sylph)

Execute the same process when previous step **"Drive testing on AWS Device Farm with Sylph"**.

When you can run local drive testing with Sylph on AWS Device Farm, see [this article] to learn how to configure Codemagic console to automate the process.

![Screenshot from 2019-11-27 09-53-00](https://user-images.githubusercontent.com/3258293/69724965-d71c1900-10fb-11ea-870b-b6d3aab44e2b.png)

[this article]: https://blog.codemagic.io/flutter-ci-cd-with-codemagic-sylph-aws-device-farm/

## Running the APP

To start the mobile app on a running Android emulator from the project root, run:

    flutter run -d <emulator-id>

## License

Copyright © 2019 | Chinnon Santos | MIT
