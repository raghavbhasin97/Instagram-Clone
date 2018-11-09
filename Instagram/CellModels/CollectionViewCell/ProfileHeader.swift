import UIKit
import Alamofire

protocol ProfileHeaderDelegate {
    func didChangeToListView()
    func didChangeToGridView()
    func shareProfile()
}

class ProfileHeader: BaseCollectionViewCell {
    
    var delegate: ProfileHeaderDelegate?
    
    let currentUser = UserDefaults.standard.object(forKey: "username") as! String
    let currentUid = UserDefaults.standard.object(forKey: "uid") as! String
    var isFollowing: Bool = false
    
    var user: User? {
        didSet {
            if user == nil {
                return
            }
            username = (user?.username)!
            profileImage = (user?.profile)!
            posts = String((user?.posts)!)
            followers = String((user?.followers)!)
            following = String((user?.following)!)
            loadProfile(currentUser == username)
            setupStatsData()
            setupEditButtonForFollow(user ?? nil)
        }
    }
    var username = ""
    var profileImage = ""
    var posts = ""
    var followers = ""
    var following = ""
    
    let profile: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.backgroundColor = UIColor.lightGray.withAlphaComponent(0.40)
        return image
    }()
    
    lazy var gridButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        button.tintColor = .blueInstagram
        button.addTarget(self, action: #selector(toogleGridView), for: .touchUpInside)
        return button
    }()
    
    lazy var listButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        button.tintColor = .buttonUnselected
        button.addTarget(self, action: #selector(toogleLitsView), for: .touchUpInside)
        return button
    }()
    
    lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [gridButton, listButton])
        let topView = UIView()
        topView.backgroundColor = .lightGray
        stack.addSubview(topView)
        stack.addConstraintsWithFormat(format: "H:|[v0]|", views: topView)
        stack.addConstraintsWithFormat(format: "V:|[v0(0.75)]", views: topView)
        stack.distribution = .fillEqually
        let bottomView = UIView()
        bottomView.backgroundColor = .lightGray
        stack.addSubview(bottomView)
        stack.addConstraintsWithFormat(format: "H:|[v0]|", views: bottomView)
        stack.addConstraintsWithFormat(format: "V:[v0(0.50)]|", views: bottomView)
        return stack
    }()
    
    lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    lazy var postLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Share Profile", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.clipsToBounds = true
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 3.0
        button.layer.borderColor = UIColor.black.cgColor
        button.addTarget(self, action: #selector(editOrFollow), for: .touchUpInside)
        return button
    }()
    
    lazy var followersabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var followingLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var statsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [postLabel, followersabel, followingLabel])
        stack.distribution = .fillEqually
        return stack
    }()
    
    fileprivate func setupProfileImage(_ size: CGFloat) {
        addSubview(profile)
        profile.widthAnchor.constraint(equalToConstant: size).isActive = true
        profile.heightAnchor.constraint(equalToConstant: size).isActive = true
        profile.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        profile.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
        profile.layer.cornerRadius = size/2
    }
    
    fileprivate func setupButtons() {
        addSubview(buttonsStackView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: buttonsStackView)
        addConstraintsWithFormat(format: "V:[v0(50)]|", views: buttonsStackView)
    }
    
    fileprivate func setupUsername() {
        addSubview(usernameLabel)
        usernameLabel.centerXAnchor.constraint(equalTo: profile.centerXAnchor, constant: 0).isActive = true
        usernameLabel.topAnchor.constraint(equalTo: profile.bottomAnchor, constant: 5).isActive = true
    }
    
    fileprivate func setupStats() {
        addSubview(statsStackView)
        statsStackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        statsStackView.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        addConstraintsWithFormat(format: "H:[v0]-12-[v1]-12-|", views: profile, statsStackView)
    }
    
    fileprivate func setupShareButton() {
        addSubview(shareButton)
        addConstraintsWithFormat(format: "H:[v0]-12-[v1]-12-|", views: profile, shareButton)
        shareButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        shareButton.topAnchor.constraint(equalTo: statsStackView.bottomAnchor, constant: 2).isActive = true
    }
    
    override func setup() {
        let size = frame.height * 0.48
        backgroundColor = .white
        setupProfileImage(size)
        setupButtons()
        setupUsername()
        setupStats()
        setupShareButton()
    }
    
    fileprivate func setupStatsData() {
        //Following
        let followingAttributedText = NSMutableAttributedString(string: following + "\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        followingAttributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        followingLabel.attributedText = followingAttributedText
        //Followers
        let followersAttributedText = NSMutableAttributedString(string: followers + "\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        followersAttributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        followersabel.attributedText = followersAttributedText
        //Posts
        let postsAttributedText = NSMutableAttributedString(string: posts + "\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        postsAttributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        postLabel.attributedText = postsAttributedText
        //username
        usernameLabel.text = username
    }
    
    fileprivate func loadProfile(_ withLoader: Bool = true) {
        profile.loadImage(profileImage)
    }
    
    fileprivate func setupEditButtonForFollow(_ user: User?) {
        if let user = user {
            if user.username != currentUser {
                if user.usersFollowing[currentUid] == nil {
                    shareButton.setTitle("Follow", for: .normal)
                    shareButton.backgroundColor = .highlightedButton
                    shareButton.setTitleColor(.white, for: .normal)
                    shareButton.layer.borderColor = UIColor.buttonUnselected.cgColor
                } else {
                    isFollowing = true
                    shareButton.setTitle("Unfollow", for: .normal)
                    shareButton.backgroundColor = .white
                    shareButton.setTitleColor(.black, for: .normal)
                    shareButton.layer.borderColor = UIColor.black.cgColor

                }
            }
        }
    }
    
    @objc fileprivate func editOrFollow() {
        //Edit Profile
        guard let user = user else { return }
        if user.username == currentUser {
            delegate?.shareProfile()
        } else if isFollowing { // Unfollow
            isFollowing = false
            unfollow(currentUser: currentUid, otherUser: user.uid!)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateSharedNewPost"), object: nil)
        } else { // Follow
            follow(currentUser: currentUid, otherUser: user.uid!)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateSharedNewPost"), object: nil)
        }
    }
    
    @objc func toogleLitsView() {
        resetTints()
        listButton.tintColor = .blueInstagram
        delegate?.didChangeToListView()
    }
    
    @objc func toogleGridView() {
        resetTints()
        gridButton.tintColor = .blueInstagram
        delegate?.didChangeToGridView()
    }
    
    fileprivate func resetTints() {
        gridButton.tintColor = .buttonUnselected
        listButton.tintColor = .buttonUnselected
    }
}
