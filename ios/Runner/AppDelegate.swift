import Flutter
import StoreKit
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // サブスクの管理（解約・確認）を、アプリから離れず OS のシートで開くための窓口。
    let channel = FlutterMethodChannel(
      name: "memory_game/subscriptions",
      binaryMessenger: engineBridge.applicationRegistrar.messenger())
    channel.setMethodCallHandler { call, result in
      guard call.method == "showManageSubscriptions" else {
        result(FlutterMethodNotImplemented)
        return
      }
      AppDelegate.showManageSubscriptions(result: result)
    }
  }

  /// StoreKit の「サブスクリプションの管理」シートをアプリ内に表示する。
  ///
  /// 表示できた場合は `true`、iOS 15 未満やウィンドウを取得できないなどで
  /// 表示できなかった場合は `false` を返す。Flutter 側は `false` のとき
  /// ストアの管理ページを外部で開くフォールバックに切り替える。
  private static func showManageSubscriptions(result: @escaping FlutterResult) {
    guard #available(iOS 15.0, *) else {
      result(false)
      return
    }
    // 前面に出ているシーンを優先し、無ければ最初のウィンドウシーンを使う。
    let scene = UIApplication.shared.connectedScenes
      .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
      ?? UIApplication.shared.connectedScenes.first as? UIWindowScene
    guard let windowScene = scene else {
      result(false)
      return
    }
    Task { @MainActor in
      do {
        try await AppStore.showManageSubscriptions(in: windowScene)
        result(true)
      } catch {
        result(false)
      }
    }
  }
}
