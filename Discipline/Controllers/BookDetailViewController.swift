//
//  BookDetailViewController.swift
//  Discipline
//
//  Created by Neo Yi Siang on 7/8/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import UIKit

class BookDetailViewController: UIViewController {

    @IBOutlet weak var bookStatusLabel: UILabel!
    @IBOutlet weak var bookNameLabel: UILabel!
    @IBOutlet weak var bookImageView: UIImageView!
    
    var book: Book!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = book.bought ? Colors.BdazzledBlue : Colors.BurntSienna
        bookNameLabel.text = book.name
        bookStatusLabel.text = book.bought ? "Bought" : "Not Yet Bought"
        bookImageView.layer.cornerRadius = 20
        bookImageView.tintColor = Colors.LightCyan
        bookImageView.backgroundColor = UIColor.clear
        if let url = book.imageURL {
            bookImageView.downloaded(from: url)
        }
        else {
            bookImageView.image = UIImage(systemName: "book.circle")
        }
    }

}
