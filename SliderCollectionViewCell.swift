//
//  SliderCollectionViewCell.swift
//  Mittens
//
//  Created by enrico  gigante on 05/10/16.
//  Copyright © 2016 enrico  gigante. All rights reserved.
//

import UIKit

class SliderCollectionViewCell: UICollectionViewCell {
    
    let userDefault = UserDef()
    
    let slider: UISlider = {
        let slide = UISlider()
        slide.minimumValue = 0
        slide.maximumValue = 1000
        slide.isContinuous = true
        let max = UIImage(named: "Globe")
        max?.draw(in: CGRect(x: 0, y: 0, width: 5, height: 5))
        slide.minimumValueImage = UIImage(named: "Home")?.stretchableImage(withLeftCapWidth: 5, topCapHeight: 0)
        slide.maximumValueImage = max
        return slide
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Raggio"

        label.font = UIFont.init(name: "AppleGothic", size: 16)
        return label
    }()
    
    let distanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "AppleGothic", size: 16)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.addSubview(slider)
        contentView.addSubview(distanceLabel)
        contentView.addSubview(descriptionLabel)
        
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.setValue(userDefault.returnDistance()!, animated: true)
        
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //impostiamo il valore di default salvato
        let defaultValue = userDefault.returnDistance()!
        if (defaultValue == 1) {
            slider.setValue(0, animated: true)
            distanceLabel.text =   "1 Km"
        } else if ( defaultValue == 2){
            slider.setValue(100, animated: true)

            distanceLabel.text = "2 Km"
        } else if (defaultValue == 3) {
            slider.setValue(200, animated: true)
            distanceLabel.text = "3 Km"
        } else if (defaultValue == 5) {
            slider.setValue(300, animated: true)
            distanceLabel.text =  "5 Km"
        } else if (defaultValue == 7) {
            slider.setValue(400, animated: true)
            distanceLabel.text = "7 Km"
        } else if (defaultValue == 10) {
            slider.setValue(500, animated: true)
            distanceLabel.text = "10 Km"
        } else if (defaultValue == 20) {
            slider.setValue(600, animated: true)
            distanceLabel.text = "20 Km"
        } else if (defaultValue == 50){
            slider.setValue(700, animated: true)
            distanceLabel.text = "50 Km"
        } else if (defaultValue == 100) {
            slider.setValue(800, animated: true)
            distanceLabel.text = "100 Km"
        } else if (defaultValue == 500) {
            slider.setValue(900, animated: true)
            distanceLabel.text = "500 Km"
        }else if (defaultValue == 1000) {
            slider.setValue(1000, animated: true)
            distanceLabel.text = "1000 Km"
        } else {
            slider.setValue(1000, animated: true)
            distanceLabel.text = "set distance"
        }
    

        distanceLabel.text = "\(Int(userDefault.returnDistance()!)) km"
        
        let constraints: [NSLayoutConstraint] = [
            descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: distanceLabel.leadingAnchor, constant: -10),
            distanceLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            distanceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            descriptionLabel.centerYAnchor.constraint(equalTo: distanceLabel.centerYAnchor),
            slider.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 7),
            slider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            slider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            slider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
//            distanceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
//            distanceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
//            distanceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        slider.addTarget(self, action: #selector(valueIsChanged(sender:forEvent:)), for: .valueChanged)
    }
    
    func valueIsChanged(sender: UISlider, forEvent event: UIEvent){
        
        let variable = sender.value
        
        if (variable <= 100) {
            sender.setValue(0, animated: true)
            userDefault.storeDistance(forDistance: 1)
            HomeViewController.radousIsChanged = true
            distanceLabel.text =   "1 Km"
        } else if ( variable > 100 && variable <= 200){
            sender.setValue(100, animated: true)
            userDefault.storeDistance(forDistance: 2)
            HomeViewController.radousIsChanged = true
            distanceLabel.text = "2 Km"
        } else if (variable > 200 && variable <= 300) {
            sender.setValue(200, animated: true)
            userDefault.storeDistance(forDistance: 3)
            distanceLabel.text = "3 Km"
            HomeViewController.radousIsChanged = true
        } else if (variable > 300 && variable <= 400) {
            sender.setValue(300, animated: true)
            userDefault.storeDistance(forDistance: 5)
            distanceLabel.text =  "5 Km"
            HomeViewController.radousIsChanged = true
        } else if (variable > 400 && variable <= 500) {
            sender.setValue(400, animated: true)
            userDefault.storeDistance(forDistance: 7)
            distanceLabel.text = "7 Km"
            HomeViewController.radousIsChanged = true
        } else if (variable > 500 && variable <= 600) {
            sender.setValue(500, animated: true)
            userDefault.storeDistance(forDistance: 10)
            distanceLabel.text = "10 Km"
            HomeViewController.radousIsChanged = true
        } else if (variable > 600 && variable <= 700) {
            slider.setValue(600, animated: true)
            userDefault.storeDistance(forDistance: 20)
            distanceLabel.text = "20 Km"
            HomeViewController.radousIsChanged = true
        } else if (variable > 700 && variable <= 800){
            slider.setValue(700, animated: true)
            userDefault.storeDistance(forDistance: 50)
            distanceLabel.text = "50 Km"
            HomeViewController.radousIsChanged = true
        } else if (variable > 800 && variable <= 900) {
            slider.setValue(800, animated: true)
            userDefault.storeDistance(forDistance: 100)
            HomeViewController.radousIsChanged = true
            distanceLabel.text = "100 Km"
        } else if (variable > 900 && variable <= 950) {
            slider.setValue(900, animated: true)
            userDefault.storeDistance(forDistance: 500)
            distanceLabel.text = "500 Km"
            HomeViewController.radousIsChanged = true
        }else if (variable > 950 && variable <= 1000) {
            slider.setValue(1000, animated: true)
            userDefault.storeDistance(forDistance: 1000)
            distanceLabel.text = "1000 Km"
            HomeViewController.radousIsChanged = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
