//
//  SharedMediaCollectionViewController.swift
//  mittens
//
//  Created by Cristian Turetta on 21/10/16.
//  Copyright © 2016 Cristian Turetta. All rights reserved.
//
import UIKit
import CoreData

private let reuseIdentifier = "Cell"

class SharedMediaCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Model
    var sharedMedias = [Media]() {
        didSet {
            sharedMedias = sharedMedias.filter { (media) -> Bool in
                return UIImage(data: media.data as! Data) != nil
            }
        }
    }
    // MARK: - Outlets
    var collectionView : UICollectionView?{
        
        didSet{
            collectionView?.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(changeScale(_:))))
            
        }
        
        
    }
    var scale:CGFloat = 3 { didSet {  collectionView?.collectionViewLayout.invalidateLayout() } }
    
    func changeScale (_ recognizer: UIPinchGestureRecognizer){
        switch recognizer.state {
        case .changed:
            // diamo un limite allo zooming!
            scale = max (min(5, scaleZooming(scale, recognizer: recognizer)), 1)
            //scale *= recognizer.scale
            recognizer.scale = 1
        case .ended:
            //questo è per le bitches di instagram
            if scale.truncatingRemainder(dividingBy: 1) < 1{
                scale -= scale.truncatingRemainder(dividingBy: 1)
            }
        default:
            break
        }
    }
    
    func scaleZooming(_ scale : CGFloat, recognizer: UIPinchGestureRecognizer) -> CGFloat{
        return scale * recognizer.scale
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Do any additional setup after loading the view.
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        view.addSubview(collectionView!)
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        
        view.addConstraintsWithFormat("H:|[v0]|", views: collectionView!)
        view.addConstraintsWithFormat("V:|[v0]|", views: collectionView!)
        
        // Register cell classes
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return sharedMedias.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        // Configure the cell
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        image.contentMode = .scaleAspectFit
        
        image.image = UIImage(data: sharedMedias[indexPath.row].data as! Data)
        
        cell.backgroundView = image
        cell.backgroundColor = .white
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.bounds.size.width/scale
        let size = CGSize(width: width-1, height: width-1)
        
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
}
