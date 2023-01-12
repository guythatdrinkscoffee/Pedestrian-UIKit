//
//  SceneDelegate.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 12/31/22.
//

import UIKit
import CoreMotion

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let scene = (scene as? UIWindowScene),
               let pedometerManager = (UIApplication.shared.delegate as? AppDelegate)?.pedometerManager
        else {
            return
        }

        // init the window
        window = UIWindow(frame: scene.coordinateSpace.bounds)
        
        // assign the scene
        window?.windowScene = scene
        
        // assign the root view controller
        let rootViewController =  determineRootViewController(for: pedometerManager.determineAuthorizationStatus(), with: pedometerManager)
        window?.rootViewController = rootViewController
        
        // make the window visible
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
        if let homeViewController = window?.rootViewController as? HomeScreen {
            homeViewController.startUpdatingLiveSteps()
        }
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
        if let homeViewController = window?.rootViewController as? HomeScreen {
            homeViewController.stopUpdatingSteps()
        }
    }
    
    func determineRootViewController(for status: CMAuthorizationStatus, with manager: PedometerManager) -> UIViewController {
        switch status {
        case .notDetermined:
            makeAuthorizationRequest(with: manager)
            return LoadingStatusScreen()
        case .restricted:
            return UIViewController()
        case .denied:
            return OpenSettingsScreen()
        case .authorized:
            return HomeScreen(pedometerManager: manager)
        @unknown default:
            fatalError("failed to make a root view controller")
        }
    }
    
    func makeRootViewController(for status: CMAuthorizationStatus, with manager: PedometerManager) {
        if status == .denied {
            self.window?.rootViewController = OpenSettingsScreen()
        } else if status == .authorized {
            let homeScreen = HomeScreen(pedometerManager: manager)
            self.window?.rootViewController = homeScreen
        }
    }
    
    func makeAuthorizationRequest(with manager: PedometerManager){
        manager.makeAuthorizationRequest {
            DispatchQueue.main.async {
                self.makeRootViewController(for: manager.determineAuthorizationStatus(), with: manager)
                return
            }
        }
    }
}

