//
//  ImageViewController.swift
//  Cassini
//
//  Created by CS193p Instructor.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate
{
    var imageData: Data? {
        didSet{
            guard let data = imageData else {return}
            image = UIImage(data: data)
        }
    }
    
     var scrollView = UIScrollView()
    
    // zooming will not work if you don't implement
    // this UIScrollViewDelegate method
    

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
     var imageView = UIImageView()
    
    // a little helper var
    // it just makes sure things are kept in sync
    // whenever we change the image we're displaying
    // it's purely to make our code look prettier elsewhere in this class
    
     var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView.contentSize = imageView.frame.size
        }
    }
    
    // MARK: View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize = imageView.frame.size
        // all three of the next lines of code
        // are necessary to make zooming work
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.03
        scrollView.maximumZoomScale = 1.0

        //navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        view.addSubview(scrollView)
        scrollView.backgroundColor = UIColor.white
        scrollView.addSubview(imageView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let constrains: [NSLayoutConstraint] =  [
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ]
        NSLayoutConstraint.activate(constrains)

    }
    func cancel() {
        dismiss(animated: true, completion: nil)
    }
}
