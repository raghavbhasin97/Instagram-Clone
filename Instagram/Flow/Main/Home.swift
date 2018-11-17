import UIKit
import Firebase

class Home: UICollectionViewController {
    let cellIDEmpty = "EmptyHomeCell"
    let cellID = "homeCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        NotificationCenter.default.addObserver(self, selector: #selector(postedNotification), name: NSNotification.Name(rawValue: "updateSharedNewPost"), object: nil)
    }
    
    lazy var refresh: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.tintColor = .black
        refresh.addTarget(self, action: #selector(refreshAction), for: .allEvents)
        return refresh
    }()
    
    
    let titleView: UIImageView = {
        let view = UIImageView()
        view.image = #imageLiteral(resourceName: "logo2").withRenderingMode(.alwaysOriginal)
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    fileprivate func setup() {
        view.backgroundColor = .white
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(HomeCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.register(EmptyHomeCell.self, forCellWithReuseIdentifier: cellIDEmpty)
        navigationItem.titleView = titleView
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "showCamera").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(showCamera))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "send2").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(shareButtonPressed))
        collectionView.refreshControl = refresh
        loadPosts {[unowned self] in
            posts.sort(by: { (p1, p2) -> Bool in
                return p1.created > p2.created
            })
            self.collectionView.reloadData()
        }
    }
    
    @objc fileprivate func showCamera() {
        let controller = UINavigationController(rootViewController: Camera())
        present(controller, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count == 0 ? 1 : posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if posts.count == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIDEmpty, for: indexPath) as! EmptyHomeCell
            cell.delegate = self
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! HomeCell
        cell.delegate = self
        if indexPath.item >= posts.count { return cell }
        cell.post = posts[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    @objc fileprivate func refreshAction() {
        loadPosts {[unowned self] in
            var tmp = Set<String>()
            posts = posts.filter({ (post) -> Bool in
                let key = String(post.created) + post.description
                if tmp.contains(key) {
                    return false
                }
                tmp.insert(key)
                return true
            })
            posts.sort(by: { (p1, p2) -> Bool in
                return p1.created > p2.created
            })
            self.refresh.endRefreshing()
            self.collectionView.reloadData()
        }
    }
    
    @objc func shareButtonPressed() {
        
    }
    
    @objc func postedNotification() {
        refreshAction()
    }
}

extension Home: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if posts.count == 0 {
            let height = view.frame.height - (tabBarController?.tabBar.frame.height ?? 0) - (navigationController?.navigationBar.frame.height ?? 0) - UIApplication.shared.statusBarFrame.height
            return CGSize(width: view.frame.width, height: height)
        } else {
            if indexPath.item >= posts.count { return CGSize.zero}
            let textHeight = heightForView(post: posts[indexPath.item], width: view.frame.width - 16)
            var height: CGFloat = view.frame.width + 106 + textHeight + 5
            if posts[indexPath.item].additionalImages.count > 0 {
                height += 10
            }
            return CGSize(width: view.frame.width, height: height)
        }
    }
}

extension Home: HomeCellDelegate {
    func showComments(_ post: Post) {
        let controller = Comment()
        controller.post = post
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func sharePost(_ image: UIImage) {
         let share = UIActivityViewController(activityItems: [image], applicationActivities: [])
        present(share, animated: true, completion: nil)
    }
}

extension Home: EmptyHomeCellDelegate {
    func firstPost() {
        let flow = UICollectionViewFlowLayout()
        let controller = UINavigationController(rootViewController:  NewPost(collectionViewLayout: flow))
        present(controller, animated: true, completion: nil)
    }
    
}
