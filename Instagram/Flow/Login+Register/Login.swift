import UIKit
import Firebase
import Photos

class Login: BaseViewController {

    var top:NSLayoutConstraint?
    var stack:NSLayoutConstraint?
    var login:NSLayoutConstraint?
    
    let logo: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.image = #imageLiteral(resourceName: "logo2")
        return image
    }()
    
    lazy var forgotButton: UIButton = {
        let button = UIButton()
        button.setTitle("Forgot Password?", for: .normal)
        button.setTitleColor(.blueInstagramLighter, for: .normal)
        button.setTitleColor(.blueInstagram, for: .highlighted)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14.0)
        button.addTarget(self, action: #selector(showForgetPassword), for: .touchUpInside)
        return button
    }()
    
    let sigupText: UILabel = {
        let label = UILabel()
        label.text = "Don't have an account?"
        label.font = .systemFont(ofSize: 15.0)
        label.textColor = UIColor.black.withAlphaComponent(0.30)
        return label
    }()
    
    lazy var sigupButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign Up.", for: .normal)
        button.setTitleColor(.blueInstagramLighter, for: .normal)
        button.setTitleColor(.blueInstagram, for: .highlighted)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14.0)
        button.addTarget(self, action: #selector(showSignUp), for: .touchUpInside)
        return button
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .blueButton
        button.setTitleColor(.white, for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 5.0
        button.titleLabel?.font = .boldSystemFont(ofSize: 16.0)
        button.setTitle("Login", for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(LoginClicked), for: .touchUpInside)
        return button
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
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [emailField, passwordField])
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
    
    override func setup() {
        view.backgroundColor = .white
        //Logo
        view.addSubview(logo)
        view.addConstraintsWithFormat(format: "H:|-75-[v0]-75-|", views: logo)
        logo.heightAnchor.constraint(equalTo: logo.widthAnchor, multiplier: 0.343).isActive = true
        top = logo.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height * 0.175)
        top?.isActive = true
        
        //Signup View
        view.addSubview(bottomView)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: bottomView)
        bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bottomView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.07).isActive = true
        
        //Stack View
        view.addSubview(stackView)
        view.addConstraintsWithFormat(format: "H:|-20-[v0]-20-|", views: stackView)
        stack = stackView.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 20)
        stack?.isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        //Forget Button
        view.addSubview(forgotButton)
        view.addConstraintsWithFormat(format: "H:[v0]-20-|", views: forgotButton)
        forgotButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 12.5).isActive = true
        
        //Login Button
        view.addSubview(loginButton)
        view.addConstraintsWithFormat(format: "H:|-20-[v0]-20-|", views: loginButton)
        loginButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        login = loginButton.topAnchor.constraint(equalTo: forgotButton.bottomAnchor, constant: 20.0)
        login?.isActive = true
        
        //Sign Up
        bottomView.addSubview(sigupText)
        bottomView.addConstraintsWithFormat(format: "V:|[v0]|", views: sigupText)
        bottomView.center_X(item: sigupText, constant: -32.50)
        
        bottomView.addSubview(sigupButton)
        bottomView.addConstraintsWithFormat(format: "V:|[v0]|", views: sigupButton)
        sigupButton.widthAnchor.constraint(equalToConstant: 63).isActive = true
        sigupButton.leadingAnchor.constraint(equalTo: sigupText.trailingAnchor, constant: 2).isActive = true
        PHPhotoLibrary.requestAuthorization { (_) in
    
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(_:)), name: UIWindow.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(_:)), name: UIWindow.keyboardWillShowNotification, object: nil)
    }
    
    @objc func keyboardWillAppear(_ notification: NSNotification) {
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        top?.constant = view.frame.height * 0.06
        stack?.constant = 7.0
        login?.constant = 7.0
        UIView.animate(withDuration: duration) {[unowned self] in
                self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillDisappear(_ notification: NSNotification) {
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        top?.constant = view.frame.height * 0.175
        stack?.constant = 20.0
        login?.constant = 20.0
        UIView.animate(withDuration: duration) {[unowned self] in
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    @objc fileprivate func shouldEnable() {
        let email = emailField.text!
        let password = passwordField.text!
        if validEmail(email: email) && validPassword(password: password) {
            loginButton.isEnabled = true
            loginButton.backgroundColor = .blueInstagram
        } else {
            loginButton.backgroundColor = .blueButton
            loginButton.isEnabled = false
        }
    }
    
    @objc fileprivate func showSignUp() {
        let controller = Register()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc fileprivate func showForgetPassword() {
        let controller = ForgetPassword()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @objc fileprivate func LoginClicked() {
        view.endEditing(true)
        let activity: UIActivityIndicatorView = {
            let activity = UIActivityIndicatorView(style: .white)
            activity.translatesAutoresizingMaskIntoConstraints = false
            activity.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            activity.startAnimating()
            return activity
        }()
        loginButton.setTitle(nil, for: .normal)
        loginButton.addSubview(activity)
        activity.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor).isActive = true
        activity.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor).isActive = true
        let email = emailField.text!
        let password = passwordField.text!
        Auth.auth().signIn(withEmail: email, password: password) {[unowned self] (user, err) in
            if err != nil {
                activity.stopAnimating()
                self.loginButton.setTitle("Login", for: .normal)
                activity.removeFromSuperview()
                let alert = createErrorAlert(message: .loginFailed)
                self.present(alert, animated: true, completion: nil)
                return
            }
            let uid = user?.user.uid
            
            UserDefaults.standard.set(true, forKey: "logged")
            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set(password, forKey: "password")
            UserDefaults.standard.set(uid, forKey: "uid")
            Database.database().reference().child("users").child(uid!).observeSingleEvent(of: DataEventType.value, with: {[unowned self] (snap) in
                let data = snap.value as! [String: Any]
                UserDefaults.standard.set(data["username"] as! String, forKey: "username")
                UserDefaults.standard.set(data["profile"] as! String, forKey: "profile")
                let controller = TabBarController()
                self.present(controller, animated: true, completion: nil)
            })
        }
    }
}

extension Login: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
        return false
    }
}
