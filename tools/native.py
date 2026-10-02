from __future__ import annotations

import argparse
import json
import platform
import plistlib
import subprocess
import tempfile
import time
import uuid
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BUNDLE_ID = "dev.swiftcheatsheet.validation"


def run(*arguments: str, timeout: int = 180) -> str:
    print("Running:", " ".join(arguments), flush=True)
    return subprocess.check_output(arguments, text=True, timeout=timeout).strip()


def verify(compile_only: bool = False) -> dict:
    # examples/app holds the tested logic the SwiftUI screens build on
    sources = [path for folder in ("app", "swiftui", "uikit") for path in sorted((ROOT / "examples" / folder).glob("*.swift"))]
    architecture = "arm64" if platform.machine() == "arm64" else "x86_64"
    sdk = run("xcrun", "--sdk", "iphonesimulator", "--show-sdk-path")
    compiler = ["xcrun", "--sdk", "iphonesimulator", "swiftc", "-sdk", sdk, "-target", f"{architecture}-apple-ios17.0-simulator", "-swift-version", "6", "-strict-concurrency=complete", "-warnings-as-errors"]
    print(f"Type-checking {len(sources)} native examples", flush=True)
    subprocess.run(compiler + ["-typecheck"] + list(map(str, sources)), check=True, timeout=300)
    if compile_only:
        return {"typechecked": len(sources), "sdk": sdk}
    with tempfile.TemporaryDirectory(prefix="swift-cheatsheet-native-") as temporary:
        app = Path(temporary) / "NativeFixture.app"
        app.mkdir()
        print("Building simulator fixture", flush=True)
        subprocess.run(compiler + ["-parse-as-library"] + list(map(str, sources)) + [str(ROOT / "tests/native/Fixture.swift"), "-o", str(app / "NativeFixture")], check=True, timeout=300)
        metadata = {
            "CFBundleIdentifier": BUNDLE_ID, "CFBundleExecutable": "NativeFixture",
            "CFBundleName": "NativeFixture", "CFBundlePackageType": "APPL",
            "CFBundleVersion": "1", "CFBundleShortVersionString": "1.0",
            "MinimumOSVersion": "17.0", "LSRequiresIPhoneOS": True,
            "UIDeviceFamily": [1, 2], "UILaunchScreen": {},
            "UIApplicationSceneManifest": {"UIApplicationSupportsMultipleScenes": False},
        }
        with (app / "Info.plist").open("wb") as output:
            plistlib.dump(metadata, output)
        run("codesign", "--force", "--sign", "-", str(app))
        runtimes = json.loads(run("xcrun", "simctl", "list", "runtimes", "--json"))["runtimes"]
        candidates = [runtime for runtime in runtimes if runtime["isAvailable"] and "iOS" in runtime["name"]]
        if not candidates:
            raise RuntimeError("No available iOS simulator runtime; native behavior checks did not run")
        runtime = max(candidates, key=lambda candidate: tuple(map(int, candidate["version"].split("."))))
        devices = runtime.get("supportedDeviceTypes", [])
        if not devices:
            devices = json.loads(run("xcrun", "simctl", "list", "devicetypes", "--json"))["devicetypes"]
        device_type = next(device["identifier"] for device in devices if device.get("productFamily") == "iPhone")
        device = run("xcrun", "simctl", "create", f"SwiftCheatSheet-{uuid.uuid4().hex[:8]}", device_type, runtime["identifier"])
        try:
            run("xcrun", "simctl", "boot", device)
            print(f"Booting isolated iOS {runtime['version']} simulator", flush=True)
            subprocess.run(["xcrun", "simctl", "bootstatus", device, "-b", "-d"], check=True, timeout=600)
            run("xcrun", "simctl", "install", device, str(app))
            run("xcrun", "simctl", "launch", device, BUNDLE_ID)
            container = Path(run("xcrun", "simctl", "get_app_container", device, BUNDLE_ID, "data"))
            result_path = container / "Documents/native-results.json"
            deadline = time.monotonic() + 90
            while time.monotonic() < deadline and not result_path.exists():
                time.sleep(0.5)
            if not result_path.exists():
                raise RuntimeError("Native fixture did not produce results within 90 seconds")
            results = json.loads(result_path.read_text())
            failed = [name for name, passed in results.items() if not passed]
            if failed:
                raise AssertionError(f"Native checks failed: {failed}")
            return {"typechecked": len(sources), "runtime": runtime["version"], "checks": results}
        finally:
            try:
                subprocess.run(["xcrun", "simctl", "shutdown", device], capture_output=True, timeout=60)
            finally:
                subprocess.run(["xcrun", "simctl", "delete", device], check=True, timeout=60)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--compile-only", action="store_true")
    print(json.dumps(verify(parser.parse_args().compile_only), indent=2))
