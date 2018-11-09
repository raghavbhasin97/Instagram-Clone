import UIKit
import Alamofire

//MARK: Visual Constraints
extension UIView {
    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated(){
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
    
    func center_X(item: UIView) {
        center_X(item: item, constant: 0)
    }
    
    func center_X(item: UIView, constant: CGFloat) {
        self.addConstraint(NSLayoutConstraint(item: item, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: constant))
    }
    
    func center_Y(item: UIView, constant: CGFloat) {
        self.addConstraint(NSLayoutConstraint(item: item, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: constant))
    }
    
    func center_Y(item: UIView) {
        center_Y(item: item, constant: 0)
    }
}


//MARK: Colors Used
extension UIColor {
    
    //MARK: function
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
    }
    
    //MARK: Colors
    static let lighterBlack = UIColor(r: 234, g: 234, b: 234)
    static let textfiled = UIColor(r: 250, g: 250, b: 250)
    static let blueInstagram = UIColor(r: 69, g: 142, b: 255)
    static let blueInstagramLighter = UIColor(r: 69, g: 142, b: 195)
    static let blueButton = UIColor(r: 154, g: 204, b: 246)
    static let buttonUnselected = UIColor(white: 0, alpha: 0.25)
    static let shareBackground = UIColor(r: 240, g: 240, b: 240)
    static let searchBackground = UIColor(r: 230, g: 230, b: 230)
    static let seperator = UIColor(white: 0, alpha: 0.50)
    static let highlightedButton = UIColor(r: 17, g: 154, b: 237)
    static let save = UIColor(white: 0, alpha: 0.3)
}

//MARK: Image Extensions
extension UIImageView {
    func loadImage(_ url: String, completion: (() -> Void)? = nil) {
        if let image = cache.object(forKey: url as AnyObject) {
            self.image = image
            return
        }
        Alamofire.request(url).responseData { response in
            if let data = response.data {
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    self.image = image
                    if let image = image {
                         cache.setObject(image, forKey: url as AnyObject)
                    }
                    completion?()
                }
            }
        }
    }
}
