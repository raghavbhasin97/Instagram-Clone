import UIKit

class Like: UICollectionViewController {
    let cellID = "likeCell"
    let cellIDEmpty = "likeCellEmpty"
    let currentUID = UserDefaults.standard.object(forKey: "uid") as! String
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    var likesPost: [Post] = []
    fileprivate func setup() {
        view.backgroundColor = .white
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(HomeCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.register(EmptyLikedCell.self, forCellWithReuseIdentifier: cellIDEmpty)
        navigationItem.title = "Liked Posts"
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return likesPost.count == 0 ? 1 : likesPost.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if likesPost.count == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIDEmpty, for: indexPath) as! EmptyLikedCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! HomeCell
            cell.delegate = self
            cell.post = likesPost[indexPath.item]
            cell.likeButton.removeFromSuperview()
            cell.bookMarkButton.removeFromSuperview()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        likesPost = posts.filter({ (post) -> Bool in
            return post.likes[currentUID] != nil
        })
        collectionView.reloadData()
    }
}

extension Like: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if likesPost.count == 0 {
            let height = view.frame.height - (tabBarController?.tabBar.frame.height ?? 0) - (navigationController?.navigationBar.frame.height ?? 0) - UIApplication.shared.statusBarFrame.height
            return CGSize(width: view.frame.width, height: height)
        } else {
            if indexPath.item >= posts.count { return CGSize.zero}
            let textHeight = heightForView(post: posts[indexPath.item], width: view.frame.width - 16)
            let height: CGFloat = view.frame.width + 56 + 50 + textHeight + 5
            return CGSize(width: view.frame.width, height: height)
        }
    }
}


extension Like: HomeCellDelegate {
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
