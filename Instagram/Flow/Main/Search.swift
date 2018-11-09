import UIKit
import Firebase

class Search: UICollectionViewController {
    let cellID = "SearchCell"
    var users: [User] = []
    var filtered: [User] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        search.delegate = self
        search.placeholder = "Search username"
        search.tintColor = .lightGray
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = .searchBackground
        return search
    }()
    
    fileprivate func setup() {
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.keyboardDismissMode = .onDrag
        collectionView.register(UserCell.self, forCellWithReuseIdentifier: cellID)
        let nav = navigationController?.navigationBar
        nav?.addSubview(searchBar)
        nav?.addConstraintsWithFormat(format: "H:|-8-[v0]-8-|", views: searchBar)
        nav?.addConstraintsWithFormat(format: "V:|[v0]|", views: searchBar)
        fetchUsers()
    }
    
    fileprivate func fetchUsers() {
        let uid = UserDefaults.standard.object(forKey: "uid") as! String
        Database.database().reference().child("users").observe(.value) {[unowned self] (snap) in
            if snap.value is NSNull {
                return
            }
            self.users = []
            let data = snap.value as! [String: Any]
            data.forEach({ (k ,val) in
                if k != uid {
                    let value = val as! [String: Any]
                    var newUser = User(data: value)
                    newUser.uid = k
                    self.users.append(newUser)
                }
            })
            self.users.sort(by: { (u1, u2) -> Bool in
                return u1.username.compare(u2.username) == .orderedAscending
            })
            self.filtered = self.users
            self.collectionView.reloadData()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filtered.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! UserCell
        cell.user = filtered[indexPath.item]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        searchBar.isHidden = true
        let profileFlow = UICollectionViewFlowLayout()
        let controller = Profile(collectionViewLayout: profileFlow)
        controller.userId = users[indexPath.item].uid
        controller.user = users[indexPath.item]
        controller.navigationItem.title = users[indexPath.item].username
        controller.navigationItem.rightBarButtonItem = nil
        navigationController?.pushViewController(controller, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.isHidden = false
    }
}

extension Search: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filtered = users
        } else {
            filtered = self.users.filter({ (user) -> Bool in
                            return user.username.lowercased().contains(searchText.lowercased())
                        })
        }
        collectionView.reloadData()
    }
}

extension Search: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: view.frame.width, height: 66)
    }
}
