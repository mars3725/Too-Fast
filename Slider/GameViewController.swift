//
//  GameViewController.swift
//  Too Fast!
//
//  Created by Matthew Mohandiss on 8/21/16.
//  Copyright (c) 2016 Matthew Mohandiss. All rights reserved.
//

import UIKit
import SpriteKit
import GoogleMobileAds
import CoreLocation
import GCHelper
import AVFoundation

//Important App Constants
var bannerView: GADBannerView!
let appFont = "Palatino-Bold"
var backgroundPause = false
var soundEnabled = true
var adRequest = GADRequest()

class GameViewController: UIViewController, CLLocationManagerDelegate {
    var locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global().async {
            GCHelper.sharedInstance.authenticateLocalUser()
        }
        
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.isHidden = true
        bannerView.frame = bannerView.frame.offsetBy(dx: 0, dy: self.view.frame.height - bannerView.frame.height)
        bannerView.adUnitID = "ca-app-pub-1759114201727768/8442648733"
        bannerView.rootViewController = self
        view.addSubview(bannerView)
        adRequest.testDevices = ["5f0881fedb47e23a63e67d2d0f40e3cf", kGADSimulatorID]
        
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.notDetermined {
        locationManager.requestWhenInUseAuthorization()
        }
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
        } else {
            print("location dervices request denied")
            DispatchQueue.global().async {
                showAd()
            }
        }
        
        let skView = self.view as! SKView
        let scene = MenuScene(size: self.view.frame.size)
        
        skView.ignoresSiblingOrder = true
        skView.shouldCullNonVisibleNodes = false
        scene.scaleMode = .aspectFill
        
        skView.presentScene(scene)
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        adRequest.setLocationWithLatitude(CGFloat(locations.last!.coordinate.latitude), longitude: CGFloat(locations.last!.coordinate.longitude), accuracy: CGFloat(locationManager.desiredAccuracy))
            showAd()

        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("failed to find the user's location")
        showAd()
    }
}

func showAd() {
    bannerView.load(adRequest)
    bannerView.isHidden = false
}

func hideAd() {
    bannerView.isHidden = true
}
