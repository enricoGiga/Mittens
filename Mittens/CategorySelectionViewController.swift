//
//  ViewController.swift
//  Mittens
//
//  Created by enrico  gigante on 16/09/16.
//  Copyright © 2016 enrico  gigante. All rights reserved.
//

import UIKit

class CategorySelectionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    // MARK: - Model
    var selectedCategory: String?
    let categories = ["Sport", "Istruzione", "Lavoro", "Hobby", "Musica", "Viaggi e Vacanze", "Ristorazione", "Salute e Benessere"]

    // MARK: - Outlets
    let picker = UIPickerView()
    
    // MARK: - Overrided Funcions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        
        title = "Category"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(pressContinue))

        picker.delegate = self
        picker.dataSource = self

        selectedCategory = categories.first
        setConstraints()
    }
    
    private func setConstraints(){
       
        view.addSubview(picker)
//        picker.translatesAutoresizingMaskIntoConstraints = false
    
//        let constrains: [NSLayoutConstraint] = [
//            picker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            picker.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            picker.leftAnchor.constraint(equalTo: view.leftAnchor),
//            picker.rightAnchor.constraint(equalTo: view.rightAnchor)
//        ]
//        NSLayoutConstraint.activate(constrains)
        
        view.addConstraintsWithFormat("H:|[v0]|", views: picker)
        view.addConstraintsWithFormat("V:|[v0]|", views: picker)
    }

    func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func pressContinue() {
        let PostCreationVC = PostCerationViewController()
        PostCreationVC.selectedCategory = selectedCategory
        navigationController?.pushViewController(PostCreationVC, animated: true)
    }
    
    // MARK: - UIPickerViewDelegate Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let highlightedCategory = categories[row]
        return NSAttributedString(string: highlightedCategory, attributes: [NSForegroundColorAttributeName: UIColor.black])
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selected = categories[row]
        selectedCategory = selected
    }
}
