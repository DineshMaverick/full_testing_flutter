#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
api="https://api-cloud.browserstack.com/app-automate/xcuitest/v2"
BROWSERSTACK_IOS_DEVICE="${BROWSERSTACK_IOS_DEVICE:-iPhone 16-18}"
app_path="${BROWSERSTACK_IOS_APP_PATH:-$root_dir/build/ios/ipa/Runner.ipa}"
test_suite_path="${BROWSERSTACK_IOS_TEST_SUITE_PATH:-$root_dir/build/ios/RunnerTests.zip}"

if [[ -z "${BROWSERSTACK_USERNAME:-}" ]]; then
  printf 'Required environment variable is not set: BROWSERSTACK_USERNAME\n' >&2
  exit 2
fi
if [[ -z "${BROWSERSTACK_ACCESS_KEY:-}" ]]; then
  printf 'Required environment variable is not set: BROWSERSTACK_ACCESS_KEY\n' >&2
  exit 2
fi
for command in curl jq; do
  if ! command -v "$command" >/dev/null 2>&1; then
    printf 'Required command is not installed or not on PATH: %s\n' "$command" >&2
    exit 2
  fi
done

if [[ "$app_path" != /* ]]; then
  app_path="$root_dir/$app_path"
fi
if [[ "$test_suite_path" != /* ]]; then
  test_suite_path="$root_dir/$test_suite_path"
fi

if [[ ! -f "$app_path" || ! -f "$test_suite_path" ]]; then
  if [[ "$(uname -s)" != "Darwin" ]]; then
    printf 'Required iOS artifacts are missing. Building them requires macOS and Xcode.\n' >&2
    if [[ ! -f "$app_path" ]]; then
      printf 'Missing app: %s\n' "$app_path" >&2
    fi
    if [[ ! -f "$test_suite_path" ]]; then
      printf 'Missing test suite: %s\n' "$test_suite_path" >&2
    fi
    exit 2
  fi
  for command in flutter xcodebuild pod ditto; do
    if ! command -v "$command" >/dev/null 2>&1; then
      printf 'Required command is not installed or not on PATH: %s\n' "$command" >&2
      exit 2
    fi
  done
  if [[ -z "${IOS_DEVELOPMENT_TEAM:-}" ]]; then
    printf 'Set IOS_DEVELOPMENT_TEAM to an Apple Developer team ID to sign the iOS app and test runner.\n' >&2
    exit 2
  fi

  export DEVELOPMENT_TEAM="$IOS_DEVELOPMENT_TEAM"
  ios_build_dir="$root_dir/build/ios/browserstack"
  archive_path="$ios_build_dir/Runner.xcarchive"
  ipa_dir="$root_dir/build/ios/ipa"
  export_options="$ios_build_dir/ExportOptions.plist"
  derived_data="$ios_build_dir/DerivedData"
  mkdir -p "$ios_build_dir" "$ipa_dir"

  printf 'Resolving Flutter and CocoaPods dependencies...\n'
  flutter pub get
  pod install --project-directory="$root_dir/ios"

  if [[ ! -f "$app_path" ]]; then
    printf 'Building and signing iOS app IPA...\n'
    flutter build ios --config-only --release
    xcodebuild archive \
      -workspace "$root_dir/ios/Runner.xcworkspace" \
      -scheme Runner \
      -configuration Release \
      -destination 'generic/platform=iOS' \
      -archivePath "$archive_path" \
      -allowProvisioningUpdates \
      CODE_SIGN_STYLE=Automatic \
      "DEVELOPMENT_TEAM=$IOS_DEVELOPMENT_TEAM"

    cat >"$export_options" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key>
  <string>development</string>
  <key>signingStyle</key>
  <string>automatic</string>
  <key>teamID</key>
  <string>$IOS_DEVELOPMENT_TEAM</string>
</dict>
</plist>
EOF
    xcodebuild -exportArchive \
      -archivePath "$archive_path" \
      -exportPath "$ipa_dir" \
      -exportOptionsPlist "$export_options" \
      -allowProvisioningUpdates
    app_path="$ipa_dir/Runner.ipa"
  fi

  if [[ ! -f "$test_suite_path" ]]; then
    printf 'Building Flutter integration test XCUITest runner...\n'
    flutter build ios --config-only --release integration_test/app_test.dart
    xcodebuild build-for-testing \
      -workspace "$root_dir/ios/Runner.xcworkspace" \
      -scheme Runner \
      -configuration Release \
      -sdk iphoneos \
      -destination 'generic/platform=iOS' \
      -derivedDataPath "$derived_data" \
      -allowProvisioningUpdates \
      CODE_SIGN_STYLE=Automatic \
      "DEVELOPMENT_TEAM=$IOS_DEVELOPMENT_TEAM"

    test_runner="$derived_data/Build/Products/Release-iphoneos/RunnerTests-Runner.app"
    if [[ ! -d "$test_runner" ]]; then
      printf 'Xcode did not produce the expected XCUITest runner: %s\n' "$test_runner" >&2
      exit 1
    fi
    mkdir -p "$(dirname "$test_suite_path")"
    ditto -c -k --sequesterRsrc --keepParent "$test_runner" "$test_suite_path"
  fi
fi

if [[ ! -f "$app_path" ]]; then
  printf 'iOS app IPA was not found: %s\n' "$app_path" >&2
  exit 1
fi
if [[ ! -f "$test_suite_path" ]]; then
  printf 'XCUITest suite ZIP was not found: %s\n' "$test_suite_path" >&2
  exit 1
fi

printf 'Uploading iOS app to BrowserStack...\n'
app_response="$(curl --fail-with-body --silent --show-error \
  --user "$BROWSERSTACK_USERNAME:$BROWSERSTACK_ACCESS_KEY" \
  --request POST "$api/app" \
  --form "file=@$app_path")"
app_url="$(jq -er '.app_url' <<<"$app_response")"

printf 'Uploading XCUITest suite to BrowserStack...\n'
test_suite_response="$(curl --fail-with-body --silent --show-error \
  --user "$BROWSERSTACK_USERNAME:$BROWSERSTACK_ACCESS_KEY" \
  --request POST "$api/test-suite" \
  --form "file=@$test_suite_path")"
test_suite_url="$(jq -er '.test_suite_url' <<<"$test_suite_response")"

printf 'Starting BrowserStack run on %s...\n' "$BROWSERSTACK_IOS_DEVICE"
build_response="$(jq -n \
  --arg app "$app_url" \
  --arg testSuite "$test_suite_url" \
  --arg device "$BROWSERSTACK_IOS_DEVICE" \
  '{
    app: $app,
    testSuite: $testSuite,
    devices: [$device],
    project: "full_testing_flutter",
    customBuildName: "Codespace Flutter iOS integration tests"
  }' | curl --fail-with-body --silent --show-error \
    --user "$BROWSERSTACK_USERNAME:$BROWSERSTACK_ACCESS_KEY" \
    --request POST "$api/build" \
    --header "Content-Type: application/json" \
    --data-binary @-)"
build_id="$(jq -er '.build_id // .id' <<<"$build_response")"

printf 'BrowserStack build ID: %s\n' "$build_id"
printf 'View results: https://app-automate.browserstack.com/dashboard/v2\n'

deadline=$((SECONDS + 1800))
while (( SECONDS < deadline )); do
  build_status="$(curl --fail-with-body --silent --show-error \
    --user "$BROWSERSTACK_USERNAME:$BROWSERSTACK_ACCESS_KEY" \
    "$api/builds/$build_id")"
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
      printf 'BrowserStack iOS test build finished with status: %s\n' "$status" >&2
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
