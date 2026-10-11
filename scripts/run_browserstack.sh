#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
android_dir="$root_dir/android"
app_apk="$root_dir/build/app/outputs/apk/debug/app-debug.apk"
test_apk="$root_dir/build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk"
api="https://api-cloud.browserstack.com/app-automate"

if ! command -v flutter >/dev/null 2>&1 && [[ -x "$HOME/flutter/bin/flutter" ]]; then
  export PATH="$HOME/flutter/bin:$PATH"
fi

if [[ -d /opt/android-sdk ]]; then
  export ANDROID_HOME="${ANDROID_HOME:-/opt/android-sdk}"
  export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$ANDROID_HOME}"
  export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
fi

if [[ -x /usr/lib/jvm/java-17-openjdk-amd64/bin/java ]]; then
  export JAVA_HOME="${JAVA_HOME:-/usr/lib/jvm/java-17-openjdk-amd64}"
  export PATH="$JAVA_HOME/bin:$PATH"
fi

if [[ -z "${BROWSERSTACK_USERNAME:-}" ]]; then
  printf 'Required environment variable is not set: BROWSERSTACK_USERNAME\n' >&2
  exit 2
fi
if [[ -z "${BROWSERSTACK_ACCESS_KEY:-}" ]]; then
  printf 'Required environment variable is not set: BROWSERSTACK_ACCESS_KEY\n' >&2
  exit 2
fi
BROWSERSTACK_DEVICE="${BROWSERSTACK_DEVICE:-Google Pixel 7-13.0}"

for command in flutter curl jq; do
  if ! command -v "$command" >/dev/null 2>&1; then
    printf 'Required command is not installed or not on PATH: %s\n' "$command" >&2
    exit 2
  fi
done

cd "$root_dir"
flutter pub get
flutter test

cd "$android_dir"
./gradlew app:assembleAndroidTest -Ptarget-platform=android-arm64
./gradlew app:assembleDebug \
  -Ptarget-platform=android-arm64 \
  -Ptarget="$root_dir/integration_test/app_test.dart"

for artifact in "$app_apk" "$test_apk"; do
  if [[ ! -f "$artifact" ]]; then
    printf 'Expected APK was not produced: %s\n' "$artifact" >&2
    exit 1
  fi
done

printf 'Uploading app APK to BrowserStack...\n'
app_response="$(curl --fail-with-body --silent --show-error \
  --user "$BROWSERSTACK_USERNAME:$BROWSERSTACK_ACCESS_KEY" \
  --request POST "$api/upload" \
  --form "file=@$app_apk")"
app_url="$(jq -er '.app_url' <<<"$app_response")"

printf 'Uploading Flutter test APK to BrowserStack...\n'
test_response="$(curl --fail-with-body --silent --show-error \
  --user "$BROWSERSTACK_USERNAME:$BROWSERSTACK_ACCESS_KEY" \
  --request POST "$api/espresso/v2/test-suite" \
  --form "file=@$test_apk")"
test_url="$(jq -er '.test_suite_url' <<<"$test_response")"

printf 'Starting BrowserStack run on %s...\n' "$BROWSERSTACK_DEVICE"
build_response="$(jq -n \
  --arg app "$app_url" \
  --arg testSuite "$test_url" \
  --arg device "$BROWSERSTACK_DEVICE" \
  '{
    app: $app,
    testSuite: $testSuite,
    devices: [$device],
    project: "full_testing_flutter",
    customBuildName: "Codespace Flutter integration tests"
  }' | curl --fail-with-body --silent --show-error \
    --user "$BROWSERSTACK_USERNAME:$BROWSERSTACK_ACCESS_KEY" \
    --request POST "$api/espresso/v2/build" \
    --header "Content-Type: application/json" \
    --data-binary @-)"
build_id="$(jq -er '.build_id // .id' <<<"$build_response")"

printf 'BrowserStack build ID: %s\n' "$build_id"
printf 'View results: https://app-automate.browserstack.com/dashboard/v2\n'

deadline=$((SECONDS + 1800))
while (( SECONDS < deadline )); do
  build_status="$(curl --fail-with-body --silent --show-error \
    --user "$BROWSERSTACK_USERNAME:$BROWSERSTACK_ACCESS_KEY" \
    "$api/espresso/v2/builds/$build_id")"
  status="$(jq -er '.status' <<<"$build_status")"

  case "$status" in
    passed|failed|error|timedout|timeout|aborted)
      jq '{
        status,
        duration,
        devices: [.devices[]? | {
          device,
          os_version,
          sessions: [.sessions[]? | {
            status,
            testcases: .testcases.status
          }]
        }]
      }' <<<"$build_status"
      if [[ "$status" == "passed" ]]; then
        exit 0
      fi
      printf 'BrowserStack test build finished with status: %s\n' "$status" >&2
      exit 1
      ;;
    *)
      printf 'BrowserStack status: %s\n' "$status"
      sleep 15
      ;;
  esac
done

printf 'Timed out waiting for BrowserStack build %s. Check the dashboard for its status.\n' "$build_id" >&2
exit 1