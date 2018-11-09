import UIKit

protocol CancelablePhotoCellDelegate {
    func removeItem(index: Int)
}

class CancelablePhotoCell: BaseCollectionViewCell {
    
    var delegate: CancelablePhotoCellDelegate?
    var index = 0
    lazy var cancelView: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .black
        button.setImage(#imageLiteral(resourceName: "close").withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.clipsToBounds = true
        button.layer.cornerRadius = 10.0
        button.layer.borderWidth = 0.75
        button.layer.borderColor = UIColor.black.cgColor
        button.addTarget(self, action: #selector(cancellicked), for: .touchUpInside)
        return button
    }()
    
    let imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    override func setup() {
        addSubview(imageView)
        addSubview(cancelView)
        addConstraintsWithFormat(format: "H:|[v0]-8-|", views: imageView)
        addConstraintsWithFormat(format: "V:|-8-[v0]|", views: imageView)
        cancelView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        cancelView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
    }
    
    public func setImage(image: UIImage) {
        imageView.image = image
    }
    
    public func getImage() -> UIImage? {
        return imageView.image
    }
    
    @objc func cancellicked() {
        delegate?.removeItem(index: index)
    }
}
