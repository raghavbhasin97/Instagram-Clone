import UIKit
import Firebase

class Register: BaseViewController {

    var top:NSLayoutConstraint?
    var stack:NSLayoutConstraint?
    var signUp:NSLayoutConstraint?
    var imageSize: CGFloat?
    var selectedAPhoto: Bool = false
    var Actiontitle  = "Add Profile Photo"
    
    lazy var picker: UIImagePickerController = {
        let controller = UIImagePickerController()
        controller.allowsEditing = true
        controller.delegate = self
        return controller
    }()
    
    let bottomView: UIView = {
        let view = UIView()
        let blackview = UIView()
        blackview.backgroundColor = .lighterBlack
        view.addSubview(blackview)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: blackview)
        view.addConstraintsWithFormat(format: "V:|[v0(1.50)]", views: blackview)
        return view
    }()
    
    let signInText: UILabel = {
        let label = UILabel()
        label.text = "Already have an account?"
        label.font = .systemFont(ofSize: 15.0)
        label.textColor = UIColor.black.withAlphaComponent(0.30)
        return label
    }()
    
    let addProfileLabel: UILabel = {
        let label = UILabel()
        label.text = "Add Profile Photo"
        label.font = .systemFont(ofSize: 24)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    lazy var signinButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign In.", for: .normal)
        button.setTitleColor(.blueInstagramLighter, for: .normal)
        button.setTitleColor(.blueInstagram, for: .highlighted)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14.0)
        button.addTarget(self, action: #selector(showSignIn), for: .touchUpInside)
        return button
    }()
    
    lazy var photoButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "selectPhoto").withRenderingMode(.alwaysOriginal), for: .normal)
        button.setImage(#imageLiteral(resourceName: "selectPhotoHighlighted").withRenderingMode(.alwaysOriginal), for: .highlighted)
        button.addTarget(self, action: #selector(selectPhoto), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [userField, emailField, passwordField])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 12.5
        return stack
    }()
    
    lazy var emailField: UITextField = {
        let field = UITextField()
        field.keyboardType = .emailAddress
        field.borderStyle = .roundedRect
        field.backgroundColor = .textfiled
        field.delegate = self
        field.clearButtonMode = .whileEditing
        field.autocapitalizationType = .none
        field.font = .systemFont(ofSize: 15)
        field.returnKeyType = .next
        field.attributedPlaceholder =   NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.30)])
        field.textColor = .black
        field.addTarget(self, action: #selector(shouldEnable), for: .editingChanged)
        return field
    }()
    
    lazy var userField: UITextField = {
        let field = UITextField()
        field.keyboardType = .default
        field.borderStyle = .roundedRect
        field.backgroundColor = .textfiled
        field.delegate = self
        field.clearButtonMode = .whileEditing
        field.autocapitalizationType = .none
        field.font = .systemFont(ofSize: 15)
        field.returnKeyType = .next
        field.attributedPlaceholder =   NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.30)])
        field.textColor = .black
        field.addTarget(self, action: #selector(shouldEnable), for: .editingChanged)
        return field
    }()
    
    lazy var passwordField: UITextField = {
        let field = UITextField()
        field.keyboardType = .default
        field.borderStyle = .roundedRect
        field.backgroundColor = .textfiled
        field.delegate = self
        field.autocapitalizationType = .none
        field.isSecureTextEntry = true
        field.clearButtonMode = .whileEditing
        field.font = .systemFont(ofSize: 15)
        field.returnKeyType = .done
        field.attributedPlaceholder =   NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.30)])
        field.textColor = .black
        field.addTarget(self, action: #selector(shouldEnable), for: .editingChanged)
        return field
    }()
    
    lazy var signupButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .blueButton
        button.setTitleColor(.white, for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 5.0
        button.titleLabel?.font = .boldSystemFont(ofSize: 16.0)
        button.setTitle("Create New Account", for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(signUpClicked), for: .touchUpInside)
        return button
    }()
    
    override func setup() {
        view.backgroundColor = .white
        //Profile
        imageSize = view.frame.height * 0.15
        view.addSubview(photoButton)
        photoButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        photoButton.widthAnchor.constraint(equalToConstant: imageSize!).isActive = true
        photoButton.heightAnchor.constraint(equalToConstant: imageSize!).isActive = true
        top = photoButton.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height * 0.125)
        top?.isActive = true
        
        view.addSubview(addProfileLabel)
        addProfileLabel.leftAnchor.constraint(equalTo: photoButton.rightAnchor, constant: 15).isActive = true
        addProfileLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        addProfileLabel.centerYAnchor.constraint(equalTo: photoButton.centerYAnchor).isActive = true
        
        //Stack View
        view.addSubview(stackView)
        view.addConstraintsWithFormat(format: "H:|-20-[v0]-20-|", views: stackView)
        stack = stackView.topAnchor.constraint(equalTo: photoButton.bottomAnchor, constant: 20)
        stack?.isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 156.25).isActive = true
        
        //SignUp Button
        view.addSubview(signupButton)
        view.addConstraintsWithFormat(format: "H:|-20-[v0]-20-|", views: signupButton)
        signupButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        signUp = signupButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20.0)
        signUp?.isActive = true
        
        //SignIn View
        view.addSubview(bottomView)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: bottomView)
        bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bottomView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.07).isActive = true
        
        //SignIn
        bottomView.addSubview(signInText)
        bottomView.addConstraintsWithFormat(format: "V:|[v0]|", views: signInText)
        bottomView.center_X(item: signInText, constant: -32.50)
        
        bottomView.addSubview(signinButton)
        bottomView.addConstraintsWithFormat(format: "V:|[v0]|", views: signinButton)
        signinButton.widthAnchor.constraint(equalToConstant: 63).isActive = true
        signinButton.leadingAnchor.constraint(equalTo: signInText.trailingAnchor, constant: 2).isActive = true
    }
    //Take Photo // Choose from Library
    @objc fileprivate func selectPhoto() {
        let action = UIAlertController(title: "Select Profile Photo", message: nil, preferredStyle: .actionSheet)
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

    @objc fileprivate func showSignIn() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc fileprivate func shouldEnable() {
        let email = emailField.text!
        let password = passwordField.text!
        let username = userField.text!
        if validEmail(email: email) && validPassword(password: password) && validUsername(username: username) && selectedAPhoto{
            signupButton.isEnabled = true
            signupButton.backgroundColor = .blueInstagram
        } else {
            signupButton.backgroundColor = .blueButton
            signupButton.isEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(_:)), name: UIWindow.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(_:)), name: UIWindow.keyboardWillShowNotification, object: nil)
    }
    
    @objc func keyboardWillAppear(_ notification: NSNotification) {
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        top?.constant = view.frame.height * 0.055
        stack?.constant = 15.0
        signUp?.constant = 15.0
        UIView.animate(withDuration: duration) {[unowned self] in
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillDisappear(_ notification: NSNotification) {
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        top?.constant = view.frame.height * 0.125
        stack?.constant = 20.0
        signUp?.constant = 20.0
        UIView.animate(withDuration: duration) {[unowned self] in
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc fileprivate func selectFromLibrary() {
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    @objc fileprivate func takeImage() {
        picker.sourceType = .camera
        picker.cameraDevice = .front
        present(picker, animated: true, completion: nil)
    }
    
    @objc fileprivate func signUpClicked() {
        view.endEditing(true)
        let activity: UIActivityIndicatorView = {
            let activity = UIActivityIndicatorView(style: .white)
            activity.translatesAutoresizingMaskIntoConstraints = false
            activity.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            activity.startAnimating()
            return activity
        }()
        signupButton.setTitle(nil, for: .normal)
        signupButton.addSubview(activity)
        activity.centerXAnchor.constraint(equalTo: signupButton.centerXAnchor).isActive = true
        activity.centerYAnchor.constraint(equalTo: signupButton.centerYAnchor).isActive = true
        let email = emailField.text!
        let password = passwordField.text!
        let username = userField.text!
        let profile = photoButton.imageView?.image?.jpegData(compressionQuality: 0.3)
        Auth.auth().createUser(withEmail: email, password: password) {[unowned self] (user, err) in
            if err != nil {
                activity.stopAnimating()
                self.signupButton.setTitle("Create New Account", for: .normal)
                activity.removeFromSuperview()
                let alert = createErrorAlert(message: .registrationFailed)
                self.present(alert, animated: true, completion: nil)
                
                return
            }
            let fileName = UUID().uuidString
            let storage = Storage.storage().reference().child("profiles").child(fileName)
            storage.putData(profile!, metadata: nil, completion: { (_, err) in
                storage.downloadURL(completion: { (url, err) in
                    let downloadURL = url?.absoluteString
                    let values = [user?.user.uid: ["username": username, "profile": downloadURL!, "posts": 0, "followers": 0, "following":0]]
                    Database.database().reference().child("users").updateChildValues(values)
                    activity.stopAnimating()
                    self.signupButton.setTitle("Account Created!", for: .normal)
                    activity.removeFromSuperview()
                    let alert = UIAlertController(title: "Success!", message: AlertMessages.registrationSucceeded.rawValue, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Sign In", style: .cancel, handler: { (_) in
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alert, animated: true, completion: nil)
                })
            })
        }
    }
}

extension Register: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userField {
            emailField.becomeFirstResponder()
        } else if textField == emailField {
            passwordField.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
        return false
    }
}

extension Register: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let edited =  info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            photoButton.setImage(edited.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let nonEdited = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            photoButton.setImage(nonEdited.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        addProfileLabel.text = "Profile Photo Added"
        photoButton.setImage(nil, for: .highlighted)
        photoButton.clipsToBounds = true
        photoButton.layer.cornerRadius = imageSize!/2
        photoButton.layer.borderColor = UIColor.black.cgColor
        photoButton.layer.borderWidth = 1.75
        selectedAPhoto = true
        shouldEnable()
        Actiontitle = "Change Profile Photo"
        dismiss(animated: true, completion: nil)
    }
}
