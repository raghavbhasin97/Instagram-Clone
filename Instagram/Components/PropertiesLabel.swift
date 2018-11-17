import UIKit

class PropertiesLabel: UILabel {
    var properties: LabelProperties?
    
    init(properties: LabelProperties) {
        super.init(frame: CGRect(x: properties.location.x, y: properties.location.y, width: 0, height: 0))
        self.properties = properties
        self.font = properties.font
        self.text = properties.text
        self.textColor = properties.color
        sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
