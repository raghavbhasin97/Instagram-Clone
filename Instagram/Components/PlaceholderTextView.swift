import UIKit


protocol PlaceholderTextViewDelegate {
    func drag(_ touches: Set<UITouch>, with event: UIEvent?)
}

class PlaceholderTextView: UITextView {

    var dragDelegate: PlaceholderTextViewDelegate?
    
    private lazy var placeHolderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        return label
    }()
    
    init(placeholder: String) {
        super.init(frame: .zero, textContainer: nil)
        setup()
        placeHolderLabel.text = placeholder
        NotificationCenter.default.addObserver(self, selector: #selector(textChanged), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        addSubview(placeHolderLabel)
        addConstraintsWithFormat(format: "H:|-2-[v0]", views: placeHolderLabel)
        addConstraintsWithFormat(format: "V:|-6-[v0]-6-|", views: placeHolderLabel)
    }
    
    @objc func textChanged() {
        if self.text.count > 0 {
            placeHolderLabel.alpha = 0
        } else {
            placeHolderLabel.alpha = 1.0
        }
    }
    
    func clearText() {
        self.text = ""
        placeHolderLabel.alpha = 1.0
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        dragDelegate?.drag(touches, with: event)
    }
}
