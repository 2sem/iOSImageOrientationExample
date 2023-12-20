//
//  ViewController.swift
//  ImageOrientationExample
//
//  Created by 영준 이 on 2023/12/11.
//

import UIKit
import Photos

class MainViewController: UIViewController {
    var imageView: UIImageView = {
        var value = UIImageView.init()
        
        value.translatesAutoresizingMaskIntoConstraints = false
        value.layer.borderWidth = 3
        
        return value
    }()
    
    var photoPickButton: UIButton = {
        var value = UIButton.init()
        
        value.translatesAutoresizingMaskIntoConstraints = false
        value.setTitle("Pick Photo", for: .normal)
        value.setTitleColor(.orange, for: .normal)
        
        return value
    }()
    
    var orientationLabel: UILabel = {
        var value = UILabel()
        
        value.translatesAutoresizingMaskIntoConstraints = false
        value.text = "unknown"
        value.textColor = .blue
        value.textAlignment = .center
        
        return value
    }()
    
    var selectedImage: UIImage? {
        didSet{
            updateOrientationLabel()
            updateImage()
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .cyan
        
        self.setupLayout()
        self.setupHandler()
    }

    func setupLayout() {
        let centerXAnchor = self.view.centerXAnchor

        self.imageView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        self.imageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        view.addSubview(self.imageView)
        
        self.imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        self.imageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        self.orientationLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        view.addSubview(self.orientationLabel)
        
        self.orientationLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        self.orientationLabel.bottomAnchor.constraint(equalTo: self.imageView.topAnchor, constant: -44).isActive = true
        
        view.addSubview(self.photoPickButton)
        
        self.photoPickButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        self.photoPickButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        self.photoPickButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        self.photoPickButton.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 44).isActive = true
    }
    
    func setupHandler() {
        self.photoPickButton.addAction(.init(handler: onBeginPickingPhoto), for: .touchUpInside)
    }
    
    func updateOrientationLabel() {
        self.orientationLabel.text = self.selectedImage?.imageOrientation.name
    }
    
    func updateImage() {
        self.imageView.image = self.selectedImage//?.clone(size: self.imageView.frame.size)
    }
    
    lazy var onBeginPickingPhoto: UIActionHandler = { [weak self](act) in
        print("onBeginPickingPhoto");
        
        guard let self = self else {
            return
        }
        
        var picker = UIImagePickerController()
        picker.delegate = self
        picker.mediaTypes = ["public.image"] //UIImagePickerController.availableMediaTypes(for: .photoLibrary) ?? []
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        
        self.present(picker, animated: true)
    }
}

extension MainViewController: UINavigationControllerDelegate {
    
}
                                    
extension MainViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        debugPrint("onBeginPickingPhoto");
        
        guard let image = info[.originalImage] as? UIImage else {
            assertionFailure("can not use image");
            return
        }
        
        self.selectedImage = image
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        debugPrint("onCancelPickingPhoto");
    }
}

extension UIImage.Orientation {
    var name: String {
        switch self {
        case .up: "up"
        case .down: "down"
        case .downMirrored: "downMirrored"
        case .left: "left"
        case .leftMirrored: "leftMirrored"
        case .right: "right"
        case .rightMirrored: "rightMirrored"
        case .upMirrored: "upMirrored"
            
        @unknown default:
            fatalError()
        }
    }
}

extension UIImage {
    func clone(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let ctx = context.cgContext
            
            switch imageOrientation {
                case .up:
                    ctx.translateBy(x: 0, y: size.height);
                    ctx.scaleBy(x: 1, y: -1);
                
                    ctx.draw(self.cgImage!, in: CGRect(origin: CGPoint.zero, size: size));
                    break;
                case .down:
                    ctx.translateBy(x: size.width, y: 0);
                    ctx.scaleBy(x: -1, y: 1);
                
                    ctx.draw(self.cgImage!, in: CGRect(origin: CGPoint.zero, size: size));
                    break;
                case .right:
                    ctx.rotate(by: CGFloat(Double.pi / 2));
                    ctx.scaleBy(x: 1, y: -1);
                
                    ctx.draw(self.cgImage!, in: CGRect(origin: CGPoint.zero, size: CGSize(width: size.height, height: size.width)));
                    break;
                case .left:
                    ctx.rotate(by: -CGFloat(Double.pi / 2));
                    ctx.scaleBy(x: 1, y: -1);
                    ctx.translateBy(x: -size.height, y: -size.width);

                    ctx.draw(self.cgImage!, in: CGRect(origin: CGPoint.zero, size: CGSize(width: size.height, height: size.width)));
                    break;
                case .upMirrored:
                    break
                case .downMirrored:
                    break
                case .leftMirrored:
                    break
                case .rightMirrored:
                    break
                @unknown default:
                    break
            }
        }
    }
}

