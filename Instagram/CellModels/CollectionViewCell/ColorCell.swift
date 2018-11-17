import UIKit

class ColorCell: BaseCollectionViewCell {
    
    var color: UIColor? {
        didSet {
            backgroundColor = color
        }
    }
    
    override func setup() {
        clipsToBounds = true
        layer.cornerRadius = frame.width/2
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2.15
    }
}
