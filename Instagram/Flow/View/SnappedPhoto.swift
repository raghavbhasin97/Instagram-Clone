import UIKit

class SnappedPhoto: UIView {
    var viewController: UIViewController?
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    let imageView: UIImageView = {
        let image = UIImageView()
        return image
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "cancel_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(backPressed), for: .touchUpInside)
        return button
    }()
    
    lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "save_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(save), for: .touchUpInside)
        return button
    }()
    
    lazy var postButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("New Post", for: .normal)
        button.addTarget(self, action: #selector(post), for: .touchUpInside)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.clipsToBounds = true
        button.layer.cornerRadius = 4.0
        return button
    }()
    
    fileprivate func setupBack() {
        addSubview(backButton)
        addConstraintsWithFormat(format: "H:[v0(50)]-12-|", views: backButton)
        addConstraintsWithFormat(format: "V:|-12-[v0(50)]", views: backButton)
    }
    
    fileprivate func setupPostButton() {
        addSubview(postButton)
        addConstraintsWithFormat(format: "H:[v0(90)]-12-|", views: postButton)
        addConstraintsWithFormat(format: "V:[v0(40)]-12-|", views: postButton)
    }
    
    fileprivate func setupSaveButton() {
        addSubview(saveButton)
        addConstraintsWithFormat(format: "H:|-12-[v0(50)]", views: saveButton)
        addConstraintsWithFormat(format: "V:[v0(50)]-12-|", views: saveButton)
    }
    
    fileprivate func setupImageView() {
        addSubview(imageView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: imageView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: imageView)
    }
    
    fileprivate func setup() {
        setupImageView()
        setupBack()
        setupPostButton()
        setupSaveButton()
    }
    
    @objc fileprivate func backPressed() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        let attributedTitle = NSMutableAttributedString()
        attributedTitle.append(NSAttributedString(string: "Discard Photo?", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.black]))
        attributedTitle.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 4)]))
        attributedTitle.append(NSAttributedString(string: "If you go back now, you will lose your photo.", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.gray]))
        
        alert.setValue(attributedTitle, forKey: "attributedTitle")
        alert.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: {[unowned self] (_) in
            self.removeFromSuperview()
        }))
        alert.addAction(UIAlertAction(title: "Keep", style: .cancel, handler: nil))
        viewController?.present(alert, animated: true, completion: nil)
    }
    
    @objc fileprivate func post() {
        let controller = SharePost()
        controller.postImage = image
        viewController?.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc fileprivate func save() {
        UIImageWriteToSavedPhotosAlbum(image!, self, #selector(finishedSaving(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc fileprivate func finishedSaving(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        let saveLabel: UILabel = {
            let label = UILabel()
            label.text = "Image Saved"
            label.numberOfLines = 0
            label.backgroundColor = .save
            label.textColor = .white
            label.font = .boldSystemFont(ofSize: 18)
            label.frame = CGRect(x: 0, y: 0, width: 150, height: 60)
            label.textAlignment = .center
            label.clipsToBounds = true
            label.layer.cornerRadius = 6.0
            return label
        }()
        saveLabel.center = center
        addSubview(saveLabel)
        saveLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            saveLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }) { (_) in
            UIView.animate(withDuration: 0.5, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                saveLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                saveLabel.alpha = 0
            }, completion: { (_) in
                saveLabel.removeFromSuperview()
            })
        }
    }
    
}
