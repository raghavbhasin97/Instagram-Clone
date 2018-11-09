import UIKit
import Firebase

class ForgetPassword: BaseViewController {
    
    var imageSize: CGFloat?
    
    let forgetImage: UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "passwordForget").withRenderingMode(.alwaysOriginal)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
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
    
    let troubleText: UILabel = {
        let label = UILabel()
        label.text = "Trouble logging in?"
        label.font = .boldSystemFont(ofSize: 20.5)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let descriptionText: UILabel = {
        let label = UILabel()
        label.text = "Enter your email and we'll send you a link to get back into your account."
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16.5)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    lazy var signinButton: UIButton = {
        let button = UIButton()
        button.setTitle("Back to Log In", for: .normal)
        button.setTitleColor(.blueInstagramLighter, for: .normal)
        button.setTitleColor(.blueInstagram, for: .highlighted)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14.0)
        button.addTarget(self, action: #selector(showSignIn), for: .touchUpInside)
        return button
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
        field.returnKeyType = .done
        field.attributedPlaceholder =   NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.30)])
        field.textColor = .black
        field.addTarget(self, action: #selector(shouldEnable), for: .editingChanged)
        return field
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .blueButton
        button.setTitleColor(.white, for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 5.0
        button.titleLabel?.font = .boldSystemFont(ofSize: 16.0)
        button.setTitle("Send Reset Link", for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(sendResetLink), for: .touchUpInside)
        return button
    }()
    
    override func setup() {
        view.backgroundColor = .white
        
        //Forget Image
        imageSize = view.frame.height * 0.15
        view.addSubview(forgetImage)
        view.center_X(item: forgetImage)
        forgetImage.widthAnchor.constraint(equalToConstant: imageSize!).isActive = true
        forgetImage.heightAnchor.constraint(equalToConstant: imageSize!).isActive = true
        forgetImage.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height * 0.125).isActive = true
        
        //Text
        view.addSubview(troubleText)
        view.center_X(item: troubleText)
        view.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        troubleText.topAnchor.constraint(equalTo: forgetImage.bottomAnchor, constant: 20).isActive = true
        view.addSubview(descriptionText)
        view.addConstraintsWithFormat(format: "H:|-40-[v0]-40-|", views: descriptionText)
        descriptionText.topAnchor.constraint(equalTo: troubleText.bottomAnchor, constant: 20).isActive = true
        
        //Email
        view.addSubview(emailField)
        view.addConstraintsWithFormat(format: "H:|-20-[v0]-20-|", views: emailField)
        emailField.topAnchor.constraint(equalTo: descriptionText.bottomAnchor, constant: 20).isActive = true
        emailField.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        //Button
        view.addSubview(sendButton)
        view.addConstraintsWithFormat(format: "H:|-20-[v0]-20-|", views: sendButton)
        sendButton.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 10).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //SignIn View
        view.addSubview(bottomView)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: bottomView)
        bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bottomView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.07).isActive = true
        bottomView.addSubview(signinButton)
        bottomView.center_X(item: signinButton)
        bottomView.addConstraintsWithFormat(format: "V:|[v0]|", views: signinButton)
        signinButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
    }
    
    @objc fileprivate func shouldEnable() {
        let email = emailField.text!
        if validEmail(email: email) {
            sendButton.isEnabled = true
            sendButton.backgroundColor = .blueInstagram
        } else {
            sendButton.backgroundColor = .blueButton
            sendButton.isEnabled = false
        }
    }
    
    @objc fileprivate func sendResetLink() {
        view.endEditing(true)
        let email = emailField.text!
        let activity: UIActivityIndicatorView = {
            let activity = UIActivityIndicatorView(style: .white)
            activity.translatesAutoresizingMaskIntoConstraints = false
            activity.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            activity.startAnimating()
            return activity
        }()
        sendButton.setTitle(nil, for: .normal)
        sendButton.addSubview(activity)
        activity.centerXAnchor.constraint(equalTo: sendButton.centerXAnchor).isActive = true
        activity.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor).isActive = true
        Auth.auth().sendPasswordReset(withEmail: email) {[unowned self] (err) in
            if err != nil {
                activity.stopAnimating()
                self.sendButton.setTitle("Send Reset Link", for: .normal)
                activity.removeFromSuperview()
                let alert = createErrorAlert(message: .sendResetFailed)
                self.present(alert, animated: true, completion: nil)
                return
            }
            let alert = UIAlertController(title: "Success!", message: AlertMessages.sendResetSuccess.rawValue, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: {[unowned self] (_) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    @objc fileprivate func showSignIn() {
        navigationController?.popViewController(animated: true)
    }
    
}

extension ForgetPassword: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
