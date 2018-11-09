import UIKit

class PhotoCell: BaseCollectionViewCell {
    
    var index: Int?
    
    let imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    override func setup() {
        addSubview(imageView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: imageView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: imageView)
    }
    
    public func setImage(image: UIImage) {
        imageView.image = image
    }
    
    public func getImage() -> UIImage? {
        return imageView.image
    }
}
