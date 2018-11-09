import UIKit

class UserCell: BaseCollectionViewCell {
    
    var user: User? {
        didSet {
            setupElements(user ?? nil)
        }
    }
    
    let profile: UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.layer.cornerRadius = 25
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .seperator
        return view
    }()
    
    fileprivate func setupProfile() {
        addSubview(profile)
        center_Y(item: profile)
        addConstraintsWithFormat(format: "H:|-8-[v0(50)]", views: profile)
        profile.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    fileprivate func setupSeperator() {
        addSubview(separator)
        separator.leftAnchor.constraint(equalTo: profile.rightAnchor, constant: 8).isActive = true
        separator.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        addConstraintsWithFormat(format: "V:[v0(0.5)]|", views: separator)
    }
    
    fileprivate func setupUsername() {
        addSubview(usernameLabel)
        usernameLabel.leftAnchor.constraint(equalTo: profile.rightAnchor, constant: 8).isActive = true
        usernameLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        center_Y(item: usernameLabel)
    }
    
    override func setup() {
        backgroundColor = .white
        setupProfile()
        setupSeperator()
        setupUsername()
    }
    
    fileprivate func setupElements(_ user: User?) {
        if let user = user {
            profile.loadImage(user.profile)
            let attributedText = NSMutableAttributedString(string: user.username, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 4)]))
            attributedText.append(NSAttributedString(string: String(user.posts) + " posts", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13), NSAttributedString.Key.foregroundColor: UIColor.gray]))
            usernameLabel.attributedText = attributedText
        }
    }
}
