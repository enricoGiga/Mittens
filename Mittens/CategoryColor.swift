//
//  CategoryColor.swift
//  Mittens
//
//  Created by Cristian Turetta on 20/09/16.
//  Copyright © 2016 Cristian Turetta. All rights reserved.
//

import Foundation
import UIKit

struct Category {
    static let sport = "Sport"
    static let education = "Istruzione"
    static let job = "Lavoro"
    static let hobby = "Hobby"
    static let musica = "Musica"
    static let viaggi = "Viaggi e Vacanze"
    static let ristorazione = "Ristorazione"
    static let salute = "Salute e Benessere"
}

func setColor(forCategory category: String) -> UIColor {
    switch category {
    case Category.sport:
        return UIColor(red: 41/255, green: 255/255, blue: 127/255, alpha: 1)
    case Category.education:
        return UIColor(red: 117/255, green: 143/255, blue: 247/255, alpha: 1)
    case Category.job:
        return UIColor(red: 208/255, green: 133/255, blue: 76/255, alpha: 1)
    case Category.hobby:
        return UIColor(red: 241/255, green: 91/255, blue: 96/255, alpha: 1)
    default:
        return UIColor.black
    }
}
