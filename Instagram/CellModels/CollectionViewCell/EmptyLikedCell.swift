import UIKit

class EmptyLikedCell: BaseCollectionViewCell {
    
    let size: CGFloat = 120
    let icon: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = #imageLiteral(resourceName: "heart-BIG").withRenderingMode(.alwaysTemplate)
        image.tintColor = .red
        return image
    }()
    
    let desc: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        let attributed = NSMutableAttributedString(attributedString: NSAttributedString(string: "You haven't liked any posts yet!\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 19), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        attributed.append(NSAttributedString(string: "\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 6)]))
        attributed.append( NSAttributedString(string: "Tap the heart button or double tap the post to like.", attributes: [NSAttributedString.Key.font : UIFont(name: "AppleSDGothicNeo-Regular", size:14)!, NSAttributedString.Key.foregroundColor: UIColor.black]))
        label.attributedText = attributed
        label.numberOfLines = 0
        return label
    }()
    
    override func setup() {
        addSubview(icon)
        center_X(item: icon)
        center_Y(item: icon, constant: -50)
        icon.heightAnchor.constraint(equalToConstant: size).isActive = true
        icon.widthAnchor.constraint(equalToConstant: size).isActive = true
        
        addSubview(desc)
        center_X(item: desc)
        desc.topAnchor.constraint(equalTo: icon.bottomAnchor).isActive = true
        desc.widthAnchor.constraint(equalToConstant: frame.width - 100).isActive = true
    }
}
