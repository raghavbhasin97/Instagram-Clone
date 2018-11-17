import UIKit
import Photos

class NewPost: UICollectionViewController {

    var headerView: PhotoCell?
    let cellID = "newPostCell"
    let headerID = "newPostHeader"
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    var images: [UIImage] = []
    var assests: [PHAsset] = []
    var selectedIndex = 0
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.addTarget(self, action: #selector(nextClicked), for: .touchUpInside)
        return button
    }()
    
    fileprivate func setup() {
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        collectionView?.showsVerticalScrollIndicator = false
        navigationItem.title = "Select Photo"
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.register(PhotoCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerID)
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelHandler))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: nextButton)
        DispatchQueue.main.async {
            self.fetchPhotosFromDevice()
        }
    }
    
    @objc fileprivate func cancelHandler() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func nextClicked() {
        let controller = SharePost()
        controller.postImage = headerView?.getImage()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! PhotoCell
        if indexPath.item >= images.count { return cell}
        cell.setImage(image: images[indexPath.item])
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerID, for: indexPath) as! PhotoCell
        headerView = header
        if assests.count > 0 {
            loadResolutionImage(index: selectedIndex)
        }
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (view.frame.width - 4.5)/4
        return CGSize(width: size, height: size)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.item
        loadResolutionImage(index: selectedIndex)
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .bottom, animated: true)
    }
    
    fileprivate func loadResolutionImage(index: Int) {
        let imageManager = PHImageManager()
        let reqOptions = PHImageRequestOptions()
        reqOptions.isSynchronous = true
        imageManager.requestImage(for: assests[index], targetSize: CGSize(width: 450, height: 450), contentMode: .aspectFill, options: reqOptions) {[unowned self] (image, _) in
            if let unwrappedImage = image {
                self.headerView?.setImage(image: unwrappedImage)
            }
        }
    }
    
    fileprivate func fetchPhotosFromDevice() {
        images = []
        assests = []
        let imageManager = PHImageManager()
        let options = PHFetchOptions()
        options.fetchLimit = 100
        let sortOptions = NSSortDescriptor(key: "creationDate", ascending: false)
        options.sortDescriptors = [sortOptions]
        let photos = PHAsset.fetchAssets(with: .image, options: options)
        let reqOptions = PHImageRequestOptions()
        reqOptions.isSynchronous = true
        photos.enumerateObjects {[unowned self] (asset, count, _) in
            imageManager.requestImage(for: asset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: reqOptions, resultHandler: {[unowned self] (image, _) in
                if let unwrappedImage = image {
                    self.assests.append(asset)
                    self.images.append(unwrappedImage)
                }
                if count == photos.count - 1{
                    self.collectionView.reloadData()
                }
            })
        }
    }
}


extension NewPost: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height * 0.40)
    }
}
