import UIKit


protocol SnappedPhotoDelegate {
    func backEvent()
    func shareEvent(image: UIImage)
}

protocol EditPhotoViewDelegate {
    func setImage(image: UIImage)
}

class SnappedPhoto: UIView {
    
    var delegate: SnappedPhotoDelegate?
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    let supportingView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.5
        return view
    }()
    
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
    
    lazy var drawButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage( #imageLiteral(resourceName: "draw").withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(startDrawing), for: .touchUpInside)
        button.tintColor = .white
        return button
    }()
    
    lazy var textButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage( #imageLiteral(resourceName: "text").withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(startAddingText), for: .touchUpInside)
        button.tintColor = .white
        return button
    }()
    
    lazy var postButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Share", for: .normal)
        button.addTarget(self, action: #selector(post), for: .touchUpInside)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.clipsToBounds = true
        button.layer.cornerRadius = 20.0
        button.titleLabel?.font = .systemFont(ofSize: 14)
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
    
    fileprivate func setupSupportingView() {
        addSubview(supportingView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: supportingView)
        addConstraintsWithFormat(format: "V:|[v0(58)]", views: supportingView)
    }
    
    fileprivate func setupDraw() {
        addSubview(drawButton)
        addConstraintsWithFormat(format: "V:|-12-[v0(50)]", views: drawButton)
    }
    
    fileprivate func setupText() {
        addSubview(textButton)
        addConstraintsWithFormat(format: "V:|-12-[v0(50)]", views: textButton)
    }
    
    fileprivate func setup() {
        backgroundColor = .black
        setupImageView()
        setupSupportingView()
        setupBack()
        setupPostButton()
        setupSaveButton()
        setupDraw()
        setupText()
        //Horizontal Constraints
        addConstraintsWithFormat(format: "H:|-12-[v0(50)]-7.5-[v1(50)]", views: drawButton, textButton)
    }
    
    @objc fileprivate func backPressed() {
       delegate?.backEvent()
    }
    
    @objc fileprivate func post() {
        delegate?.shareEvent(image: image!)
    }
    
    @objc fileprivate func save() {
        UIImageWriteToSavedPhotosAlbum(image!, self, #selector(finishedSaving(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc fileprivate func finishedSaving(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        let saveLabel: UILabel = {
            let label = UILabel()
            label.text = "Image Saved!"
            label.numberOfLines = 0
            label.backgroundColor = .save
            label.textColor = .white
            label.font = .boldSystemFont(ofSize: 15)
            label.frame = CGRect(x: 0, y: 0, width: 120, height: 50)
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
    
    @objc fileprivate func startDrawing() {
        let drawView = DrawingView()
        drawView.delegate = self
        drawView.image = image
        drawView.alpha = 0
        addSubview(drawView)
        drawView.frame = frame
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            drawView.alpha = 1.0
        }, completion: nil)
    }
    
    @objc fileprivate func startAddingText() {
        let drawView = TextView()
        drawView.delegate = self
        drawView.image = image
        drawView.alpha = 0
        addSubview(drawView)
        drawView.frame = frame
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            drawView.alpha = 1.0
        }, completion: nil)
    }
    
}

extension SnappedPhoto: EditPhotoViewDelegate {
    func setImage(image: UIImage) {
        self.image = image
        imageView.image = image
    }
    
}
