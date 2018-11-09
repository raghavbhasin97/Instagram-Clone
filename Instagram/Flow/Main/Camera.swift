import UIKit
import AVFoundation


class Camera: BaseViewController {

    let output = AVCapturePhotoOutput()
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "cancel_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(backPressed), for: .touchUpInside)
        return button
    }()
    
    lazy var capture: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "capture_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        return button
    }()
    
    fileprivate func setupSession() {
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
            } catch let err {
                print("Could not setup camera input:", err)
            }
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
            
            let preview = AVCaptureVideoPreviewLayer(session: session)
            preview.frame = view.frame
            view.layer.addSublayer(preview)
            session.startRunning()
        }
    }
    
    fileprivate func setupBack() {
        view.addSubview(backButton)
        view.addConstraintsWithFormat(format: "H:[v0(50)]-12-|", views: backButton)
        view.addConstraintsWithFormat(format: "V:|-12-[v0(50)]", views: backButton)
    }
    
    override func setup() {
        navigationItem.title = "Camera"
        view.backgroundColor = .white
        setupSession()
        setupBack()
        view.addSubview(capture)
        view.center_X(item: capture)
        view.addConstraintsWithFormat(format: "V:[v0(80)]-20-|", views: capture)
        capture.widthAnchor.constraint(equalToConstant: 80).isActive = true
    }

    @objc fileprivate func backPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        capture.isEnabled = false
        output.capturePhoto(with: settings , delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
}

extension Camera: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let data = photo.fileDataRepresentation() {
            let image = UIImage(data: data)
            let previewContainer = SnappedPhoto(frame: view.frame)
            previewContainer.image = image
            previewContainer.viewController = self
            view.addSubview(previewContainer)
            view.addConstraintsWithFormat(format: "H:|[v0]|", views: previewContainer)
            view.addConstraintsWithFormat(format: "V:|[v0]|", views: previewContainer)
            capture.isEnabled = true
        }
        
    }
}
