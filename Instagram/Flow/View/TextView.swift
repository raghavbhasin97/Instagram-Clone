import UIKit

class TextView: UIView {
    
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    let sizeButtonSize: CGFloat = 30
    let maxSize: Float = 30
    let minSize: Float = 20
    var allowChangeSize = false
    let sliderSize: CGFloat = 200
    
    lazy var text: UITextView = {
        let text = PlaceholderTextView(placeholder: "")
        text.font = .boldSystemFont(ofSize: CGFloat(minSize))
        text.textColor = color
        text.backgroundColor = .clear
        text.showsVerticalScrollIndicator = false
        text.delegate = self
        text.dragDelegate = self
        text.isScrollEnabled = false
        text.autocorrectionType = .no
        text.autocapitalizationType = .sentences
        return text
    }()
    
    lazy var textSize: UISlider = {
        let slider = UISlider()
        slider.maximumValue = maxSize
        slider.minimumValue = minSize
        slider.isContinuous = true
        slider.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        slider.transform =  CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.alpha = 0
        slider.thumbTintColor = .white
        slider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.40)
        slider.minimumTrackTintColor = .white
        return slider
    }()
    
    
    lazy var sizeButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(changeSize), for: .touchUpInside)
        button.setImage( #imageLiteral(resourceName: "change").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        
        button.clipsToBounds = true
        button.layer.cornerRadius = sizeButtonSize/2
        return button
    }()
    
    let colors: [UIColor] = [.red, .green, .yellow, .blue, .black, .purple , .white, .gray, .orange]
    
    let cellID = "ColorCell"
    
    var delegate: EditPhotoViewDelegate?
   
    var color: UIColor = .red

    
    let selectedColorViewSize: CGFloat = 34
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    lazy var colorPicker: UICollectionView = {
        let flow = UICollectionViewFlowLayout()
        flow.minimumInteritemSpacing = 2.15
        flow.scrollDirection = .horizontal
        let collection = UICollectionView(frame: .zero, collectionViewLayout: flow)
        collection.register(ColorCell.self, forCellWithReuseIdentifier: cellID)
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .clear
        return collection
    }()
    
    let imageView: UIImageView = {
        let image = UIImageView()
        return image
    }()
    
    lazy var selectedCorlorView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.layer.cornerRadius = selectedColorViewSize/2
        view.clipsToBounds = true
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 2.0
        return view
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        button.addTarget(self, action: #selector(donePressed), for: .touchUpInside)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        button.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
        button.setTitleColor(.white, for: .normal)
        return button
    }()

    let supportingView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.5
        return view
    }()
    
    fileprivate func setupImageView() {
        addSubview(imageView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: imageView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: imageView)
    }
    
    fileprivate func setupDone() {
        addSubview(doneButton)
        addConstraintsWithFormat(format: "V:|-8-[v0(50)]", views: doneButton)
    }
    
    fileprivate func setupCancel() {
        addSubview(cancelButton)
        addConstraintsWithFormat(format: "V:|-8-[v0(50)]", views: cancelButton)
    }
    
    fileprivate func setupColorPicker() {
        addSubview(colorPicker)
        addConstraintsWithFormat(format: "V:[v0(30)]-12-|", views: colorPicker)
    }
    
    fileprivate func setupSelectedView() {
        addSubview(selectedCorlorView)
        addConstraintsWithFormat(format: "V:[v0(\(selectedColorViewSize))]-12-|", views: selectedCorlorView)
    }
    
    fileprivate func setupSupportingView() {
        addSubview(supportingView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: supportingView)
        addConstraintsWithFormat(format: "V:|[v0(58)]", views: supportingView)
    }
    
    fileprivate func setupTextView() {
        addSubview(text)
        addConstraintsWithFormat(format: "H:|-30-[v0]-30-|", views: text)
        text.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        text.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    fileprivate func setupChangeSize() {
        addSubview(sizeButton)
        sizeButton.heightAnchor.constraint(equalToConstant: sizeButtonSize).isActive = true
        sizeButton.centerYAnchor.constraint(equalTo: doneButton.centerYAnchor).isActive = true
        addConstraintsWithFormat(format: "H:|-15-[v0(\(sizeButtonSize))]", views: sizeButton)
    }
    
    fileprivate func setupTextSize() {
        addSubview(textSize)
        textSize.widthAnchor.constraint(equalToConstant: sliderSize).isActive = true
        textSize.leftAnchor.constraint(equalTo: leftAnchor, constant: -sliderSize/2 + 20).isActive = true
        center_Y(item: textSize, constant: -sliderSize/2)
    }
    
    fileprivate func setup() {
        backgroundColor = .black
        setupImageView()
        setupSupportingView()
        setupDone()
        setupCancel()
        setupChangeSize()
        addConstraintsWithFormat(format: "H:[v0(55)]-20-[v1(50)]-15-|", views: cancelButton, doneButton)
        setupColorPicker()
        setupSelectedView()
        setupTextSize()
        addConstraintsWithFormat(format: "H:|-10-[v0(\(selectedColorViewSize))]-15-[v1]-10-|", views: selectedCorlorView, colorPicker)
        setupTextView()
        text.becomeFirstResponder()
    }
    
    @objc func donePressed() {
        text.resignFirstResponder()
        delegate?.setImage(image: getImage())
        removeView()
    }
    
    @objc func cancelPressed() {
        text.resignFirstResponder()
        removeView()
    }
    
    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                break
            case .moved:
                let textSize = CGFloat(slider.value)
                text.font = .boldSystemFont(ofSize: textSize)
            case .ended:
                break
            default:
                break
            }
        }
    }
    
    @objc func changeSize() {
        var alpha: CGFloat = 0.0
        if !allowChangeSize {
            alpha = 1.0
        }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {[unowned self] in
            self.textSize.alpha = alpha
            }, completion: nil)
        
        allowChangeSize = !allowChangeSize
    }
    
    fileprivate func removeView() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {[unowned self] in
            self.alpha = 0
        }) {[unowned self] (_) in
            self.removeFromSuperview()
        }
    }
    
    func flipContents(off: Bool) {
        if off {
            doneButton.alpha = 0
            cancelButton.alpha = 0
            supportingView.alpha = 0
            selectedCorlorView.alpha = 0
            colorPicker.alpha = 0
            textSize.alpha = 0
            sizeButton.alpha = 0
        } else {
            doneButton.alpha = 1
            cancelButton.alpha = 1
            supportingView.alpha = 1
            selectedCorlorView.alpha = 1
            colorPicker.alpha = 1
            textSize.alpha = 1
            sizeButton.alpha = 1
        }
    }
    
    fileprivate func getImage() -> UIImage{
        flipContents(off: true)
        if let data = dataForViewAsImage() {
            if let drawnImage = UIImage(data: data) {
                return drawnImage
            }
        }
        flipContents(off: false)
        return image!
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        text.resignFirstResponder()
    }
}

extension TextView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ColorCell
        cell.color = colors[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size: CGFloat = 24.15
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        color = colors[indexPath.item]
        selectedCorlorView.backgroundColor = color
        text.textColor = color
    }
}

extension TextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count == 0 { return }
        let lastCharacter = String(textView.text[textView.text.index(textView.text.endIndex, offsetBy: -1)])
        if textView.text.count > 55 || lastCharacter == "\n" {
            let end = textView.text.index(textView.text.endIndex, offsetBy: -1)
            textView.text = String(textView.text[..<end])
        }
    }
}

extension TextView: PlaceholderTextViewDelegate {
    func drag(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let point = touch.location(in: self)
            text.center = point
        }
    }
    
    
}
