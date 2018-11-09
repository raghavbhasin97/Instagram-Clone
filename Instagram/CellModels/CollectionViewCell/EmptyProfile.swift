import UIKit

protocol EmptyProfileDelegate {
    func firstPost()
}

class EmptyProfile: BaseCollectionViewCell {
    let size: CGFloat = 90
    var delegate: EmptyProfileDelegate?
    lazy var icon: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.tintColor = .black
        return image
    }()
    
    let desc: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Share your first photo", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(clickButton), for: .touchUpInside)
        button.setTitleColor(.blueInstagram, for: .normal)
        return button
    }()
    
    override func setup() {
        addSubview(icon)
        center_X(item: icon)
        center_Y(item: icon, constant: -65)
        icon.heightAnchor.constraint(equalToConstant: size).isActive = true
        icon.widthAnchor.constraint(equalToConstant: size).isActive = true
        addSubview(desc)
        center_X(item: desc)
        desc.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 15).isActive = true
        desc.widthAnchor.constraint(equalToConstant: frame.width - 100).isActive = true
        setCurrent()
    }
    
    func setCurrent() {
        let attributed = NSMutableAttributedString(attributedString: NSAttributedString(string: "Share Photos\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 19), NSAttributedString.Key.foregroundColor: UIColor.black]))
        attributed.append(NSAttributedString(string: "\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]))
        attributed.append( NSAttributedString(string: "When you share photos, they'll appear on your profile.", attributes: [NSAttributedString.Key.font : UIFont(name: "AppleSDGothicNeo-Regular", size:14)!, NSAttributedString.Key.foregroundColor: UIColor.black]))
        desc.attributedText = attributed
        icon.image = #imageLiteral(resourceName: "noPosts").withRenderingMode(.alwaysTemplate)
        setupButton()
    }
    
    func setOther() {
        let attributed = NSMutableAttributedString(attributedString: NSAttributedString(string: "No Posts Yet\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 19), NSAttributedString.Key.foregroundColor: UIColor.black]))
        attributed.append(NSAttributedString(string: "\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 10)]))
        attributed.append( NSAttributedString(string: "When this user posts, you will see their photos here.", attributes: [NSAttributedString.Key.font : UIFont(name: "AppleSDGothicNeo-Regular", size:14)!, NSAttributedString.Key.foregroundColor: UIColor.black]))
        desc.attributedText = attributed
        icon.image = #imageLiteral(resourceName: "no-post-camera-small").withRenderingMode(.alwaysTemplate)
        for const in button.constraints {
            button.removeConstraint(const)
        }
        button.removeFromSuperview()
    }
    
    func setupButton() {
        addSubview(button)
        center_X(item: button)
        button.topAnchor.constraint(equalTo: desc.bottomAnchor, constant: 8).isActive = true
    }
    
    @objc func clickButton() {
        delegate?.firstPost()
    }
}
