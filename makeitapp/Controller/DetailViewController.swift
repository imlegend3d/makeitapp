//
//  DetailViewController.swift
//  makeitapp
//
//  Created by David on 2019-04-27.
//  Copyright © 2019 David. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework


class DetailViewController: UIViewController {

    var item: Item?
    
    let titleLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(titleLabel)
        if item != nil {
          print(item!.title)
            if let item = item {
                //let textRect = CGRect(x: (titleLabel.bounds.origin.x + 16), y: (titleLabel.bounds.origin.y + 16), width: (titleLabel.bounds.width - 32), height: (titleLabel.bounds.height))
               // titleLabel.textRect(forBounds: textRect , limitedToNumberOfLines: 0)
                
                titleLabel.text = item.title
                titleLabel.numberOfLines = 0
                titleLabel.font = UIFont(name: "Marker Felt", size: 23)
                titleLabel.backgroundColor = UIColor(hexString: item.color)
                titleLabel.textColor = ContrastColorOf(backgroundColor: UIColor(hexString: item.color), returnFlat: true)
                view.backgroundColor = ContrastColorOf(backgroundColor: UIColor(hexString: item.color), returnFlat: true)
                titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 40, left: 16, bottom: 0, right: 16), size: CGSize(width: 0 , height: 60))
            }
        }
    }
}

extension UIView {
    func anchorSize(to view: UIView){
        widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    func anchor(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero) {
     translatesAutoresizingMaskIntoConstraints = false
        if let top = top {
           topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }
        if let trailing = trailing {
           trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
}

