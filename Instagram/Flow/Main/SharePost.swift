import UIKit
import Firebase

class SharePost: BaseViewController {
    let cellID = "SharePostCells"
    var postImage: UIImage? {
        didSet {
            imageView.image = postImage
        }
    }
    
    var currentCount = 0
    var supplementaryImages: [Data] = []
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    lazy var picker: UIImagePickerController = {
        let controller = UIImagePickerController()
        controller.allowsEditing = true
        controller.delegate = self
        return controller
    }()
    
    let imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    lazy var textView: UITextView = {
        let text = UITextView()
        text.font = .systemFont(ofSize: 14)
        text.delegate = self
        text.autocorrectionType = .no
        return text
    }()
    
    let container: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let Actiontitle = "Add Image to Post"
    
    lazy var supplementartImages: UICollectionView = {
        let flow = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: flow)
        collection.backgroundColor = .shareBackground
        collection.showsVerticalScrollIndicator = false
        collection.contentInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        collection.keyboardDismissMode = .interactive
        collection.delegate = self
        collection.dataSource = self
        return collection
    }()
    
    lazy var buttonContainer: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        view.backgroundColor = .shareBackground
        return view
    }()
    
    lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Images", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(addImage), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Share", for: .normal)
        button.addTarget(self, action: #selector(sharePost), for: .touchUpInside)
        return button
    }()
    
    fileprivate func setupContainer() {
        view.addSubview(container)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: container)
        container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        container.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.15).isActive = true
    }
    
    fileprivate func setupComponents(_ padding: CGFloat, _ size: CGFloat) {
        container.addSubview(imageView)
        container.addSubview(textView)
        container.addConstraintsWithFormat(format: "H:|-(\(padding))-[v0(\(size))]-4-[v1]-4-|", views: imageView, textView)
        container.addConstraintsWithFormat(format: "V:|-(\(padding))-[v0(\(size))]", views: imageView)
        container.addConstraintsWithFormat(format: "V:|-4-[v0]-4-|", views: textView)
        
    }
    
    fileprivate func setupSupplementaryContainer() {
        let blackLine: UIView = {
            let view = UIView()
            view.backgroundColor = .black
            return view
        }()
        
        let photo: UIImageView = {
            let image = UIImageView()
            image.image = #imageLiteral(resourceName: "photo-add").withRenderingMode(.alwaysOriginal)
            image.translatesAutoresizingMaskIntoConstraints = false
            return image
        }()
        
        buttonContainer.addSubview(blackLine)
        buttonContainer.addConstraintsWithFormat(format: "H:|[v0]|", views: blackLine)
        buttonContainer.addConstraintsWithFormat(format: "V:|[v0(0.25)]", views: blackLine)
        
        buttonContainer.addSubview(addButton)
        buttonContainer.addSubview(photo)
        buttonContainer.center_X(item: addButton)
        photo.rightAnchor.constraint(equalTo: addButton.leftAnchor).isActive = true
        buttonContainer.center_Y(item: addButton)
        buttonContainer.center_Y(item: photo)
        
    }
    
    fileprivate func setupSupplementaryView() {
        view.addSubview(supplementartImages)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: supplementartImages)
        supplementartImages.topAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        supplementartImages.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 50).isActive = true
    }
    
    override func setup() {
        view.backgroundColor = .shareBackground
        navigationItem.title = "New Post"
        navigationController?.navigationBar.tintColor = .black
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareButton)
        navigationItem.rightBarButtonItem?.isEnabled = false
        setupContainer()
        let size = view.frame.height * 0.127
        let padding = view.frame.height * 0.0115
        setupComponents(padding, size)
        setupSupplementaryContainer()
        setupSupplementaryView()
        
        textView.inputAccessoryView = buttonContainer
        supplementartImages.register(CancelablePhotoCell.self, forCellWithReuseIdentifier: cellID)
        textView.becomeFirstResponder()
        
    }
    
    fileprivate func doneUploading() {
        if currentCount == supplementaryImages.count {
            self.dismiss(animated: true, completion: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateSharedNewPost"), object: nil)
        }
    }
    
    @objc fileprivate func sharePost() {
        view.endEditing(true)
        let activity: UIActivityIndicatorView = {
            let activity = UIActivityIndicatorView(style: .white)
            activity.color = .black
            activity.translatesAutoresizingMaskIntoConstraints = false
            activity.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            activity.startAnimating()
            activity.alpha = 0
            return activity
        }()
        view.addSubview(activity)
        activity.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activity.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20).isActive = true
        UIView.animate(withDuration: 0.35) {
            activity.alpha = 1.0
        }
        let username = UserDefaults.standard.object(forKey: "username") as! String
        let profile = UserDefaults.standard.object(forKey: "profile") as! String
        let uid = Auth.auth().currentUser?.uid
        let postText = textView.text!
        let filename = UUID().uuidString
        if let data = postImage?.jpegData(compressionQuality: 0.3) {
            navigationItem.rightBarButtonItem?.isEnabled = false
            let storage = Storage.storage().reference().child("posts").child(filename)
            storage.putData(data, metadata: nil) {[unowned self] (_, err) in
                if err != nil {
                    activity.removeFromSuperview()
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    let alert = createErrorAlert(message: .postShareFailed)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                storage.downloadURL {[unowned self] (url, err) in
                    let downloadUrl = url?.absoluteString
                    let values: [String: Any] = ["image" : downloadUrl!, "post": postText,  "username" : username ,"profile": profile, "created": Date().timeIntervalSince1970]
                    let refrence = Database.database().reference().child("posts").child(uid!).childByAutoId()
                    let autoID = refrence.key!
                    refrence.updateChildValues(values, withCompletionBlock: { (_, _) in
                        cache.setObject(self.postImage!, forKey: downloadUrl as AnyObject)
                        incrementUserIntegerMetaDataByOne(child: uid!, key: "posts", completion: nil)
                        var count = 0
                        if self.supplementaryImages.count == 0 {
                            self.doneUploading()
                            return
                        }
                        for image in self.supplementaryImages {
                            let key = "url" + String(count)
                            count += 1
                            let add_filename = UUID().uuidString
                            let add_storage = Storage.storage().reference().child("posts").child(add_filename)
                            add_storage.putData(image, metadata: nil) {[unowned self] (_, _) in
                                add_storage.downloadURL {(url, _) in
                                    let add_downloadUrl = url?.absoluteString
                                    cache.setObject(UIImage(data: image)!, forKey: add_downloadUrl as AnyObject)
                                    Database.database().reference().child("posts").child(uid!).child(autoID).child("additionalImages").updateChildValues([key : add_downloadUrl as AnyObject])
                                        self.currentCount += 1
                                        self.doneUploading()
                                }
                            }
                        }
                    })
                }
            }
        }
    }
}

extension SharePost: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if !textView.text.isEmpty {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
}



extension SharePost: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc fileprivate func addImage() {
        view.endEditing(true)
        let action = UIAlertController(title: "Add Image to Post", message: nil, preferredStyle: .actionSheet)
        var attributedTitle = NSMutableAttributedString()
        attributedTitle = NSMutableAttributedString(string: Actiontitle as String, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15.0)])
        attributedTitle.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange(location: 0,length: Actiontitle.count))
        
        action.setValue(attributedTitle, forKey: "attributedTitle")
        action.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: {[unowned self] (_) in
            self.takeImage()
        }))
        action.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: {[unowned self] (_) in
            self.selectFromLibrary()
        }))
        action.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(action, animated: true, completion: nil)
    }
    
    
    @objc fileprivate func selectFromLibrary() {
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    @objc fileprivate func takeImage() {
        picker.sourceType = .camera
        picker.cameraDevice = .rear
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var image: UIImage?
        if let edited =  info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
           image = edited
        } else if let nonEdited = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
          image = nonEdited
        }
        if let data = image?.jpegData(compressionQuality: 0.30) {
            supplementaryImages.append(data)
        }
        supplementartImages.reloadData()
        textView.becomeFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        textView.becomeFirstResponder()
        dismiss(animated: true, completion: nil)
    }
}

extension SharePost: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return supplementaryImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! CancelablePhotoCell
        cell.setImage(image: UIImage(data: supplementaryImages[indexPath.item])!)
        cell.index = indexPath.item
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = view.frame.height * 0.16
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
}

extension SharePost: CancelablePhotoCellDelegate {
    func removeItem(index: Int) {
        supplementaryImages.remove(at: index)
        supplementartImages.reloadData()
    }
    
}

