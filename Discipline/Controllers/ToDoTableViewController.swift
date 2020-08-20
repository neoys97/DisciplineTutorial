//
//  ToDoTableViewController.swift
//  Discipline
//
//  Created by Neo Yi Siang on 5/8/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import UIKit
import FirebaseAuth

class ToDoTableViewController: UITableViewController, ReloadableViewController {

    @IBOutlet weak var DescriptionView: UIView!
    @IBOutlet weak var AdviceView: UIView!
    @IBOutlet weak var MainView: UIView!
    @IBOutlet weak var toDoImageView: UIImageView!
    @IBOutlet weak var toDoTextBgView: UIView!
    @IBOutlet weak var toDoTextView: UITextView!
    @IBOutlet weak var editSaveBtn: UIButton!
    
    var rootTabBarController: MainTabBarController!
    let imagePicker = UIImagePickerController()
    
    var isModifying = false
    var imagePickerTap: UITapGestureRecognizer!
    var dismissKeyboardTap: UITapGestureRecognizer!
    var currentImageURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rootTabBarController = tabBarController as? MainTabBarController
        
        dismissKeyboardTap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        dismissKeyboardTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissKeyboardTap)
        
        imagePickerTap = UITapGestureRecognizer(target: self, action: #selector(self.showImagePicker))
        toDoImageView.isUserInteractionEnabled = false
        toDoImageView.addGestureRecognizer(imagePickerTap)
        
        DescriptionView.layer.cornerRadius = 20
        AdviceView.layer.cornerRadius = 20
        MainView.layer.cornerRadius = 20
        toDoTextBgView.layer.cornerRadius = 20
        toDoImageView.tintColor = Colors.LightCyan
        toDoImageView.backgroundColor = Colors.BdazzledBlue
        toDoImageView.layer.cornerRadius = 20
        toDoImageView.image = UIImage.init(systemName: "plus")
        
        self.refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadView()
    }
    
    @objc func refresh(_ sender: AnyObject) {
        rootTabBarController.refresh()
    }
    
    @IBAction func editSaveBtnPressed(_ sender: Any) {
        if isModifying {
            editSaveBtn.setTitle("Edit", for: .normal)
            toDoImageView.isUserInteractionEnabled = false
            toDoTextView.isEditable = false
            updateData()
        }
        else {
            editSaveBtn.setTitle("Save", for: .normal)
            toDoImageView.isUserInteractionEnabled = true
            toDoTextView.isEditable = true
        }
        isModifying = !isModifying
    }
    
    func updateData() {
        var updateQuery = [String: Any]()
        var update = false
        if let desc = toDoTextView.text {
            updateQuery["toDoDesc"] = desc
            update = true
        }
        if let imageURL = currentImageURL {
            updateQuery["toDoImageURL"] = imageURL
            update = true
        }
        if update {
            FirebaseUtil.updateUser(uniqueID: Auth.auth().currentUser!.uid, query: updateQuery as [String : Any]) { (error) in
                if let error = error {
                    print (error)
                    DispatchQueue.main.async {
                        self.present(Utilities.alertMessage(title: "Error", message: "Failed to update user on Firestore"), animated: true)
                    }
                }
                self.rootTabBarController.refresh()
            }
        }
    }
    
    @objc func showImagePicker() {
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.mediaTypes = ["public.image"]
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func reloadView() {
        refreshControl?.endRefreshing()
        if let student = rootTabBarController.student {
            if let imageURL = student.toDoImageURL {
                if let currentURL = currentImageURL {
                    if currentURL != imageURL {
                        toDoImageView.downloaded(from: imageURL)
                        currentImageURL = imageURL
                    }
                }
                else {
                    toDoImageView.downloaded(from: imageURL)
                    currentImageURL = imageURL
                }
            }
            else {
                toDoImageView.image = UIImage.init(systemName: "plus")
            }
            if let toDoDesc = student.toDoDesc {
                toDoTextView.text = toDoDesc
            }
            else {
                toDoTextView.text = ""
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
}

extension ToDoTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            FirebaseUtil.uploadImage(image: image, mode: .toDoImage, uniqueID: Auth.auth().currentUser!.uid) { (url, err) in
                if let err = err {
                    print (err)
                    DispatchQueue.main.async {
                        self.present(Utilities.alertMessage(title: "Error", message: "Failed to upload image to Firestore"), animated: true)
                    }
                }
                else if let url = url {
                    self.currentImageURL = url
                    self.toDoImageView.image = image
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
}
