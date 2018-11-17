import UIKit

class DrawingView: UIView {
    
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }

    var expandedSizeMultiplier: CGFloat = 1.35
    var drawH: NSLayoutConstraint?
    var drawW: NSLayoutConstraint?
   
    var eraseH: NSLayoutConstraint?
    var eraseW: NSLayoutConstraint?
    
    var isErasing = false
    let drawingBoard: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .clear
        return image
    }()
    
    let colors: [UIColor] = [.red, .green, .yellow, .blue, .black, .purple , .white, .gray, .orange]
    
    let cellID = "ColorCell"
    var lastPoint: CGPoint?
    var delegate: EditPhotoViewDelegate?
    var color: UIColor = .red
    var radius: CGFloat = 0
    let sliderSize: CGFloat = 200
    var allowChangeSize = false
    let sizeButtonSize: CGFloat = 30
    let selectedColorViewSize: CGFloat = 34
    
    let maxRadius: Float = 10.0
    let minRadius: Float = 3.5
    let radiusSize: CGFloat = 30
    
    
    var previewH: NSLayoutConstraint?
    var previewW: NSLayoutConstraint?
    
    let animator = UIViewPropertyAnimator(duration: 0.5, curve: .linear)
    
    lazy var previewView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.75, alpha: 1)
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = radiusSize/2
        return view
    }()
    
    lazy var drawButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(changeModeDraw), for: .touchUpInside)
        button.setImage( #imageLiteral(resourceName: "draw-1").withRenderingMode(.alwaysOriginal), for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = sizeButtonSize/2
        return button
    }()
    
    lazy var eraseButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(changeModeErase), for: .touchUpInside)
        button.setImage( #imageLiteral(resourceName: "eraser").withRenderingMode(.alwaysOriginal), for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = sizeButtonSize/2
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    lazy var brushSize: UISlider = {
        let slider = UISlider()
        slider.maximumValue = maxRadius
        slider.minimumValue = minRadius
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
    
    lazy var sizeButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(changeSize), for: .touchUpInside)
        button.setImage( #imageLiteral(resourceName: "change").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        
        button.clipsToBounds = true
        button.layer.cornerRadius = sizeButtonSize/2
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
    
    fileprivate func setupDrawingBoard() {
        addSubview(drawingBoard)
        addConstraintsWithFormat(format: "H:|[v0]|", views: drawingBoard)
        addConstraintsWithFormat(format: "V:|[v0]|", views: drawingBoard)
    }
    
    fileprivate func setupDone() {
        addSubview(doneButton)
        addConstraintsWithFormat(format: "V:|-8-[v0(50)]", views: doneButton)
    }
    
    fileprivate func setupCancel() {
        addSubview(cancelButton)
        addConstraintsWithFormat(format: "V:|-8-[v0(50)]", views: cancelButton)
    }
    
    fileprivate func setupChangeSize() {
        addSubview(sizeButton)
        sizeButton.heightAnchor.constraint(equalToConstant: sizeButtonSize).isActive = true
        sizeButton.centerYAnchor.constraint(equalTo: doneButton.centerYAnchor).isActive = true
    }
    
    fileprivate func setupDrawButton() {
        addSubview(drawButton)
        drawH = drawButton.heightAnchor.constraint(equalToConstant: sizeButtonSize * expandedSizeMultiplier)
        drawH?.isActive = true
        drawButton.centerYAnchor.constraint(equalTo: doneButton.centerYAnchor).isActive = true
    }
    
    fileprivate func setupEraseButton() {
        addSubview(eraseButton)
        eraseH = eraseButton.heightAnchor.constraint(equalToConstant: sizeButtonSize)
        eraseH?.isActive = true
        eraseButton.centerYAnchor.constraint(equalTo: doneButton.centerYAnchor).isActive = true
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
    
    fileprivate func setupBrushSize() {
        addSubview(brushSize)
        brushSize.widthAnchor.constraint(equalToConstant: sliderSize).isActive = true
        brushSize.leftAnchor.constraint(equalTo: leftAnchor, constant: -sliderSize/2 + 20).isActive = true
        center_Y(item: brushSize, constant: -sliderSize/2)
    }
    
    
    fileprivate func setupBrushPreview() {
        addSubview(previewView)
        previewW = previewView.widthAnchor.constraint(equalToConstant: radiusSize)
        previewW?.isActive = true
        previewH = previewView.heightAnchor.constraint(equalToConstant: radiusSize)
        previewH?.isActive = true
        previewView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        previewView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    fileprivate func setup() {
        backgroundColor = .black
        setupImageView()
        setupDrawingBoard()
        setupSupportingView()
        setupDone()
        setupCancel()
        addConstraintsWithFormat(format: "H:[v0(55)]-20-[v1(50)]-15-|", views: cancelButton, doneButton)
        setupChangeSize()
        setupColorPicker()
        setupSelectedView()
        addConstraintsWithFormat(format: "H:|-10-[v0(\(selectedColorViewSize))]-15-[v1]-10-|", views: selectedCorlorView, colorPicker)
        setupBrushSize()
        setupBrushPreview()
        setupDrawButton()
        setupEraseButton()
        addConstraintsWithFormat(format: "H:|-15-[v0(\(sizeButtonSize))]-15-[v1]-6.5-[v2]", views: sizeButton, drawButton, eraseButton)
        drawW = drawButton.widthAnchor.constraint(equalToConstant: sizeButtonSize * expandedSizeMultiplier)
        drawW?.isActive = true
        
        eraseW = eraseButton.widthAnchor.constraint(equalToConstant: sizeButtonSize)
        eraseW?.isActive = true
        
        animator.addAnimations {[unowned self] in
            let size = (1 - self.animator.fractionComplete) * (self.radiusSize * 2)
            self.previewW?.constant = size
            self.previewH?.constant = size
            self.previewView.layer.cornerRadius = size/2
            self.layoutIfNeeded()
        }
        radius = CGFloat(minRadius)
    }
    
    
    
    @objc func changeModeDraw() {
        if isErasing {
            isErasing = false
            setupDrawingControlls()
        }
    }
    
    @objc func changeModeErase() {
        if !isErasing {
            isErasing = true
            setupDrawingControlls()
        }
    }
    
    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                previewView.alpha = 1.0
            case .moved:
                 radius = CGFloat(slider.value)
                 animator.fractionComplete = (CGFloat(slider.value) - CGFloat(minRadius))/CGFloat((maxRadius - minRadius))
            case .ended:
                previewView.alpha = 0.0
            default:
                break
            }
        }
    }
    
    @objc func donePressed() {
        delegate?.setImage(image: getImage())
        removeView()
    }
    
    @objc func cancelPressed() {
        removeView()
    }
    
    fileprivate func removeView() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {[unowned self] in
            self.alpha = 0
        }) {[unowned self] (_) in
            self.animator.stopAnimation(true)
            self.removeFromSuperview()
        }
    }
    
    
    @objc func changeSize() {
        var alpha: CGFloat = 0.0
        if !allowChangeSize {
            alpha = 1.0
        }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {[unowned self] in
            self.brushSize.alpha = alpha
        }, completion: nil)
        
        allowChangeSize = !allowChangeSize
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            lastPoint = touch.location(in: self)
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let current = touch.location(in: self)
            drawLineFrom(fromPoint: lastPoint ?? current, toPoint: current)
            lastPoint = current
        }
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        
        UIGraphicsBeginImageContext(frame.size)
        let context = UIGraphicsGetCurrentContext()
        drawingBoard.image?.draw(in: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        context?.move(to: fromPoint)
        context?.addLine(to: toPoint)
        if isErasing {
            let clearColor = UIColor.init(patternImage: #imageLiteral(resourceName: "empty"))
            context?.setStrokeColor(clearColor.cgColor)
            context?.setShadow(offset: CGSize(width:0, height: 0), blur: 17, color: clearColor.cgColor)
            context?.setBlendMode(.clear)
        } else {
            context?.setFillColor(UIColor.white.cgColor)
            context?.setStrokeColor(color.cgColor)
            context?.setShadow(offset: CGSize(width:0, height: 0), blur: 17, color: color.cgColor)
        }
        context?.setLineJoin(.round)
        context?.setLineCap(.round)
        context?.setLineWidth(radius * 2)
        context?.drawPath(using: .stroke)
        drawingBoard.image = UIGraphicsGetImageFromCurrentImageContext()
        drawingBoard.alpha = 1.0
        UIGraphicsEndImageContext()
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
    
    fileprivate func setupDrawingControlls() {
        if isErasing {
            drawW?.constant = sizeButtonSize
            drawH?.constant = sizeButtonSize
            eraseH?.constant = sizeButtonSize * expandedSizeMultiplier
            eraseW?.constant = sizeButtonSize * expandedSizeMultiplier
            
        } else  {
           drawW?.constant = sizeButtonSize * expandedSizeMultiplier
           drawH?.constant = sizeButtonSize * expandedSizeMultiplier
           eraseH?.constant = sizeButtonSize
           eraseW?.constant = sizeButtonSize
        }
        layoutIfNeeded()
    }
    
    func flipContents(off: Bool) {
        if off {
            doneButton.alpha = 0
            cancelButton.alpha = 0
            supportingView.alpha = 0
            selectedCorlorView.alpha = 0
            colorPicker.alpha = 0
            sizeButton.alpha = 0
            brushSize.alpha = 0
            eraseButton.alpha = 0
            drawButton.alpha = 0
        } else {
            doneButton.alpha = 1
            cancelButton.alpha = 1
            supportingView.alpha = 1
            selectedCorlorView.alpha = 1
            colorPicker.alpha = 1
            sizeButton.alpha = 1
            brushSize.alpha = 1
            eraseButton.alpha = 1
            drawButton.alpha = 1
        }
    }
}

extension DrawingView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
    }
}
