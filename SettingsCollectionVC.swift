//
//  SettingsCollectionVC.swift
//  mittens
//
//  Created by enrico  gigante on 21/10/16.
//  Copyright © 2016 enrico  gigante. All rights reserved.
//

import UIKit
import MapKit
class SettingsCollectionVC: UIViewController , UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MKMapViewDelegate{
    
    var collectionView: UICollectionView?
    
    let map : MKMapView = {
        let map = MKMapView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        map.mapType = .standard
        map.isZoomEnabled = false
        map.isPitchEnabled = false
        map.isScrollEnabled = false
        return map
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionHeadersPinToVisibleBounds = true
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        view.addSubview(collectionView!)
        // add constrains
        view.addConstraintsWithFormat("H:|[v0]|", views: collectionView!)
        view.addConstraintsWithFormat("V:|[v0]|", views: collectionView!)
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        // Register cell classes
        collectionView?.register(SliderCollectionViewCell.self, forCellWithReuseIdentifier: "slider")
        collectionView?.register(MapCollectionViewCell.self, forCellWithReuseIdentifier: "map")
        
        // Do any additional setup after loading the view.
    }
    
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 2
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "slider", for: indexPath)
                as? SliderCollectionViewCell
            return cell!
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "map", for: indexPath) as? MapCollectionViewCell
            map.delegate = self
            cell?.contentView.addSubview(map)
            cell?.addConstraintsWithFormat("H:|[v0]|", views: map)
            cell?.addConstraintsWithFormat("V:|[v0]|", views: map)
            map.setCenter(CLLocationCoordinate2D.init(latitude: CLLocationDegrees.abs(MyLocationInfo.myLocation.latitude!), longitude: CLLocationDegrees.abs(MyLocationInfo.myLocation.longitude!)) , animated: true)
            map.setRegion(MKCoordinateRegion.init(center: CLLocationCoordinate2D.init(latitude: CLLocationDegrees.abs(MyLocationInfo.myLocation.latitude!), longitude: CLLocationDegrees.abs(MyLocationInfo.myLocation.longitude!)), span: MKCoordinateSpan.init(latitudeDelta: 0.5, longitudeDelta: 0.5)), animated: true)
            map.showsUserLocation = true
            return cell!
            
        default: break
            
        }
        return UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
            
        case 0:
            return CGSize(width: view.bounds.width, height: 100)
        case 1:
            return CGSize(width: view.bounds.width, height: 300)
            
            
        default:
            return CGSize(width: 0, height: 0)
        }
        
    }
    
}
