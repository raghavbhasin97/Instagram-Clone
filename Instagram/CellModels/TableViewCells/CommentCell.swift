import UIKit

class CommentCell: BaseTableViewCell {
    
    var comment: CommentItem? {
        didSet {
            if let comment = comment {
                setupData(comment: comment)
            }
        }
    }
    
    let profile: UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.layer.cornerRadius = 25
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    let commentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate func setupProfile() {
        addSubview(profile)
        center_Y(item: profile)
        addConstraintsWithFormat(format: "H:|-8-[v0(50)]", views: profile)
        profile.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    fileprivate func setupCommentLabel() {
        addSubview(commentLabel)
        commentLabel.leftAnchor.constraint(equalTo: profile.rightAnchor, constant: 8).isActive = true
        commentLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        center_Y(item: commentLabel)
    }
    
    override func setup() {
        backgroundColor = .white
        setupProfile()
        setupCommentLabel()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(false, animated: false)
    }
    
    fileprivate func setupData(comment: CommentItem) {
        profile.loadImage(comment.profile)
        let attributedText = NSMutableAttributedString(string: comment.username + " ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: comment.comment, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13), NSAttributedString.Key.foregroundColor: UIColor.black]))
        commentLabel.attributedText = attributedText
    }

}
