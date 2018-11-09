import UIKit
import Firebase

class Profile: UICollectionViewController {
    
    var userId: String?
    
    var user: User? {
        didSet {
            navigationItem.title = user?.username
        }
    }
    var isCurrent = true
    var isGrid = true
    var header: ProfileHeader?
    
    let cellID = "profileCell"
    let headerId = "profileHeader"
    let emptyCellID = "EmptyprofileCell"
    var postImages: [String] = []
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(logOut))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var refresh: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.tintColor = .black
        refresh.addTarget(self, action: #selector(refreshAction), for: .allEvents)
        return refresh
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        if user == nil {
            userId = UserDefaults.standard.object(forKey: "uid") as? String
            navigationItem.title = UserDefaults.standard.object(forKey: "username") as? String
        } else {
            isCurrent = false
        }
        
        let tempView = UIView()
        tempView.backgroundColor = .white
        view.addSubview(tempView)
        tempView.frame = view.frame
        let activity: UIActivityIndicatorView = {
            let activity = UIActivityIndicatorView(style: .white)
            activity.color = .black
            activity.translatesAutoresizingMaskIntoConstraints = false
            activity.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            activity.startAnimating()
            return activity
        }()
        view.addSubview(activity)
        activity.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activity.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loadUserData {[unowned self] in
            tempView.removeFromSuperview()
            activity.removeFromSuperview()
            self.collectionView.reloadData()
        }
    }
    
    fileprivate func setup() {
        collectionView?.backgroundColor = .white
        collectionView?.showsVerticalScrollIndicator = false
        collectionView.refreshControl = refresh
        collectionView.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.register(EmptyProfile.self, forCellWithReuseIdentifier: emptyCellID)
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! ProfileHeader
        header.user = user
        header.delegate = self
        self.header = header
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(postImages.count,1)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if postImages.count > 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! PhotoCell
            if indexPath.item >= postImages.count { return cell}
            cell.imageView.loadImage(postImages[indexPath.item])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellID, for: indexPath) as! EmptyProfile
            if isCurrent {
                cell.setCurrent()
            } else {
                cell.setOther()
            }
            cell.delegate = self
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if isGrid {
            if postImages.count > 0 {
                let size = (view.frame.width - 3)/3
                return CGSize(width: size, height: size)
            } else {
                return CGSize(width: view.frame.width, height: view.frame.height * 0.50)
            }
        } else {
            if postImages.count > 0 {
                 return CGSize(width: view.frame.width, height: 250)
            } else {
                 return CGSize(width: view.frame.width, height: view.frame.height * 0.50)
            }
        }
    }
    
    fileprivate func loadUserData(completions: (() -> Void)?) {
        let uid = userId!
        Database.database().reference().child("users").child(uid).observe(.value) {(snap) in
            let data = snap.value as! [String: Any]
            self.user = User(data: data)
            self.user?.uid = uid
            self.postImages = []
            posts.forEach({ (post) in
                if post.uid == uid {
                    self.postImages.append(post.image)
                    post.additionalImages.forEach({ (_,v) in
                         self.postImages.append(v)
                    })
                }
                
            })
            completions?()
        }
    }
    
    @objc fileprivate func logOut() {
        let title = "Are you sure you want to log out?"
        let alert = UIAlertController(title: nil, message: title, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            do{
                try Auth.auth().signOut()
                UserDefaults.standard.set(false, forKey: "logged")
                posts = []
                Database.database().reference().removeAllObservers()
                let conroller = UINavigationController(rootViewController: Login())
                self.present(conroller, animated: true, completion: nil)
            } catch {
                debugPrint("Error Occurred while logging out!")
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc fileprivate func refreshAction() {
        loadUserData {[unowned self] in
            self.refresh.endRefreshing()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !isCurrent {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            tabBarController?.tabBar.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         if !isCurrent {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            tabBarController?.tabBar.isHidden = true
        }
        loadUserData {[unowned self] in
            self.collectionView.reloadData()
        }
    }
    
}

extension Profile: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
       return CGSize(width: view.frame.width, height: view.frame.height * 0.315)
    }
}


extension Profile: ProfileHeaderDelegate {
    func shareProfile() {
        if let header = header {
            let share = UIActivityViewController(activityItems: [header.profile.image!], applicationActivities: [])
            present(share, animated: true, completion: nil)
        }
    }
    
    func didChangeToListView() {
        isGrid = false
        collectionView.reloadData()
    }
    
    func didChangeToGridView() {
        isGrid = true
        collectionView.reloadData()
    }
    
    
}

extension Profile: EmptyProfileDelegate {
    func firstPost() {
        let flow = UICollectionViewFlowLayout()
        let controller = UINavigationController(rootViewController:  NewPost(collectionViewLayout: flow))
        present(controller, animated: true, completion: nil)
    }
    
}
