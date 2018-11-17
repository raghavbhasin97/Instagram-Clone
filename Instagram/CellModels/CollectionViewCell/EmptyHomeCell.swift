import UIKit

protocol EmptyHomeCellDelegate {
    func firstPost()
}

class EmptyHomeCell: BaseCollectionViewCell {
    
    var delegate: EmptyHomeCellDelegate?
    let size: CGFloat = 120
    let icon: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = #imageLiteral(resourceName: "empty Post").withRenderingMode(.alwaysOriginal)
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    let desc: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        let attributed = NSMutableAttributedString(attributedString: NSAttributedString(string: "You haven't posted anything yet!\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 19), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        attributed.append(NSAttributedString(string: "\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 6)]))
        attributed.append( NSAttributedString(string: "Click the button below to share your first post.", attributes: [NSAttributedString.Key.font : UIFont(name: "AppleSDGothicNeo-Regular", size:14)!, NSAttributedString.Key.foregroundColor: UIColor.black]))
        label.attributedText = attributed
        label.numberOfLines = 0
        return label
    }()
    
    lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start sharing", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(clickButton), for: .touchUpInside)
        button.setTitleColor(.blueInstagram, for: .normal)
        return button
    }()
    
    func setupButton() {
        addSubview(button)
        center_X(item: button)
        button.topAnchor.constraint(equalTo: desc.bottomAnchor, constant: 8).isActive = true
    }
    
    fileprivate func setupDesc() {
        addSubview(desc)
        center_X(item: desc)
        desc.topAnchor.constraint(equalTo: icon.bottomAnchor).isActive = true
        desc.widthAnchor.constraint(equalToConstant: frame.width - 100).isActive = true
    }
    
    fileprivate func setupImage() {
        addSubview(icon)
        center_X(item: icon)
        center_Y(item: icon, constant: -50)
        icon.heightAnchor.constraint(equalToConstant: size).isActive = true
        icon.widthAnchor.constraint(equalToConstant: size).isActive = true
    }
    
    override func setup() {
        setupImage()
        setupDesc()
        setupButton()
    }
    
    @objc func clickButton() {
        delegate?.firstPost()
    }
}
