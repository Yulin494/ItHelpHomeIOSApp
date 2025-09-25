//
//  SceneDelegate.swift
//  ItHelpHome
//
//  Created by imac on 2025/9/23.
//

import UIKit
import IQKeyboardManagerSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {        
        // 1. 確保場景是 UIWindowScene 的實例，否則返回。
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // 2. 創建主視圖控制器的實例，使用 XIB 檔案來初始化它。
        let rootVC = MainViewController(nibName: "MainViewController", bundle: nil)
        
        // 3. 使用主視圖控制器創建一個導航控制器。
        let navigationController = UINavigationController(rootViewController: rootVC)
        
        // 4. 創建並設置 UIWindow 的實例，這個窗口是應用的主要顯示區域。
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        
        // 5. 設置窗口的場景，這樣窗口就會和指定的場景關聯。
        window?.windowScene = windowScene
        
        // 6. 設置窗口的根視圖控制器為導航控制器，這樣應用的初始視圖會顯示在這個導航控制器中。
        window?.rootViewController = navigationController
        
        // 7. 使窗口顯示並成為應用的主要窗口。
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

