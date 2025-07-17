import UIKit

@main
class InvestFlowApp: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("InvestFlowApp: Application did finish launching")
        
        let screenBounds = UIScreen.main.bounds
        print("InvestFlowApp: Screen bounds: \(screenBounds)")
        
        window = UIWindow(frame: screenBounds)
        print("InvestFlowApp: Window created with frame: \(window?.frame ?? .zero)")
        
        // Запускаем основной MainViewController
        let mainVC = MainViewController()
        let nav = UINavigationController(rootViewController: mainVC)
        print("InvestFlowApp: MainViewController создан и обёрнут в UINavigationController")
        window?.rootViewController = nav
        print("InvestFlowApp: Root view controller set")
        window?.makeKeyAndVisible()
        print("InvestFlowApp: Window made key and visible")
        
        // Проверка состояния окна
        print("InvestFlowApp: Window is key: \(window?.isKeyWindow ?? false)")
        print("InvestFlowApp: Window is hidden: \(window?.isHidden ?? true)")
        print("InvestFlowApp: Window alpha: \(window?.alpha ?? -1)")
        
        // Асинхронная проверка
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let window = self?.window else { return }
            print("InvestFlowApp: Async check - Window is key: \(window.isKeyWindow)")
            print("InvestFlowApp: Async check - Window is hidden: \(window.isHidden)")
            window.layoutIfNeeded()
            print("InvestFlowApp: Layout updated")
        }
        
        return true
    }
} 
