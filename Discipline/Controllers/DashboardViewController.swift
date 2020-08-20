//
//  DashboardViewController.swift
//  Discipline
//
//  Created by Neo Yi Siang on 5/8/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import UIKit
import FirebaseAuth

class DashboardViewController: UIViewController, ReloadableViewController {
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var classgroupTF: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var toDoListSectionView: UIView!
    @IBOutlet weak var toDoListCompleteTF: UILabel!
    @IBOutlet weak var booksSectionView: UIView!
    @IBOutlet weak var booksCompleteTF: UILabel!
    
    let emailKey = "EMAIL"
    let passwordKey = "PASSWORD"
    let defaults = UserDefaults.standard
    var profilePicURL: String?
    
    var rootTabBarController: MainTabBarController!
    let imagePicker = UIImagePickerController()
    let refreshControl = UIRefreshControl()
    var imagePickerTap: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rootTabBarController = tabBarController as? MainTabBarController

        profilePicImageView.tintColor = Colors.LightCyan
        profilePicImageView.backgroundColor = Colors.BdazzledBlue
        profilePicImageView.layer.cornerRadius = 75
        profilePicImageView.image = UIImage.init(systemName: "person")
        profilePicImageView.contentMode = .scaleAspectFill
        profilePicImageView.layer.masksToBounds = true
        
        toDoListSectionView.layer.cornerRadius = 20

        booksSectionView.layer.cornerRadius = 20
        
        imagePickerTap = UITapGestureRecognizer(target: self, action: #selector(self.showImagePicker))
        profilePicImageView.isUserInteractionEnabled = true
        profilePicImageView.addGestureRecognizer(imagePickerTap)
        
        createClassGroupPicker()
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        scrollView.addSubview(refreshControl)
        
        reloadView()
    }

    override func viewWillAppear(_ animated: Bool) {
        reloadView()
    }
    
    @objc func refresh(_ sender: AnyObject) {
        rootTabBarController.refresh()
    }

    @IBAction func switchToDoView(_ sender: Any) {
        rootTabBarController.selectedIndex = 1
    }
    
    @IBAction func switchBooksView(_ sender: Any) {
        rootTabBarController.selectedIndex = 2
    }
    
    @IBAction func switchToNewView(_ sender: Any) {
        rootTabBarController.selectedIndex = 3
    }
    
    func createClassGroupPicker() {
        let classGroupPicker = UIPickerView()
        classGroupPicker.delegate = self
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.updateData))
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        classgroupTF.inputView = classGroupPicker
        classgroupTF.inputAccessoryView = toolBar
        classgroupTF.tintColor = UIColor.clear
        usernameTF.inputAccessoryView = toolBar
    }
    
    @objc func showImagePicker() {
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.mediaTypes = ["public.image"]
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func updateData() {
        view.endEditing(true)
        let classGroupID = searchForClassGroupID(name: classgroupTF.text ?? "")
        var updateQuery = [
            "name": usernameTF.text ?? Auth.auth().currentUser!.email!,
            "classGroupID": classGroupID!,
            "books": []
        ] as [String : Any]
        if let currentClassGroupID = rootTabBarController.student?.classGroupID {
            if classGroupID == currentClassGroupID {
                updateQuery = [
                    "name": usernameTF.text ?? Auth.auth().currentUser!.email!
                ]
            }
        }
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
    
    func searchForClassGroupID(name: String) -> String? {
        if let classGroups = rootTabBarController.classGroup {
            for (key, value) in classGroups {
                if (value.name == name) {
                    return key
                }
            }
        }
        return nil
    }
    
    func reloadView() {
        refreshControl.endRefreshing()
        if let student = rootTabBarController.student {
            if let url = student.profilePicURL {
                if let currentURL = profilePicURL {
                    if currentURL != url {
                        profilePicImageView.downloaded(from: url, contentMode: .scaleAspectFill)
                        profilePicURL = url
                    }
                }
                else {
                    profilePicImageView.downloaded(from: url, contentMode: .scaleAspectFill)
                    profilePicURL = url
                }
            }
            else {
                profilePicImageView.image = UIImage(systemName: "person")
            }
            usernameTF.text = student.name
            if let classID = student.classGroupID {
                if let classGroups = rootTabBarController.classGroup {
                    classgroupTF.text = classGroups[classID]?.name
                }
                else {
                    classgroupTF.text = "Select your class"
                }
            }
            else {
                classgroupTF.text = "Select your class"
            }
            updateStatusView(student: student)
        }
    }
    
    func updateStatusView(student: Student) {
        toDoListCompleteTF.text = "Incomplete"
        toDoListSectionView.backgroundColor = Colors.BurntSienna
        if let desc = student.toDoDesc, desc != "" {
            if let _ = student.toDoImageURL {
                toDoListCompleteTF.text = "Complete"
                toDoListSectionView.backgroundColor = Colors.BdazzledBlue
            }
        }
        
        booksCompleteTF.text = "Incomplete"
        booksSectionView.backgroundColor = Colors.BurntSienna
        if let booksID = rootTabBarController.currentClassBooksKeys {
            if booksID.sorted() == student.books.sorted() {
                booksCompleteTF.text = "Complete"
                booksSectionView.backgroundColor = Colors.BdazzledBlue
            }
        }
    }
    
    @IBAction func logOutBtnPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            defaults.removeObject(forKey: emailKey)
            defaults.removeObject(forKey: passwordKey)
            rootTabBarController.clearData()
            let targetVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginMenu")
            UIApplication.shared.windows.first?.rootViewController = targetVC!
        }
        catch {
            print("Sign out error")
        }
    }
}

extension DashboardViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let classGroups = rootTabBarController.classGroup {
            return classGroups.count
        }
        else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let classGroups = rootTabBarController.classGroup {
            return classGroups[rootTabBarController.classGroupKeys![row]]?.name
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let classGroups = rootTabBarController.classGroup {
            classgroupTF.text = classGroups[rootTabBarController.classGroupKeys![row]]?.name
        }
    }
}

extension DashboardViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            FirebaseUtil.uploadImage(image: image, mode: .profilePic, uniqueID: Auth.auth().currentUser!.uid) {[unowned self] (url, err) in
                if let err = err {
                    print (err)
                    DispatchQueue.main.async {
                        self.present(Utilities.alertMessage(title: "Error", message: "Failed to upload image to Firestore"), animated: true)
                    }
                }
                else if let url = url {
                    let updateQuery = ["profilePicURL": url]
                    FirebaseUtil.updateUser(uniqueID: Auth.auth().currentUser!.uid, query: updateQuery as [String : Any]) { (error) in
                        if let error = error {
                            print (error)
                            DispatchQueue.main.async {
                                self.present(Utilities.alertMessage(title: "Error", message: "Failed to update user on Firestore"), animated: true)
                            }
                        }
                        else {
                            self.rootTabBarController.student!.profilePicURL = url
                            self.profilePicURL = url
                            self.profilePicImageView.image = image
                        }
                    }
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
}
