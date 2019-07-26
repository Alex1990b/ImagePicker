//
//  ImagePicker.swift
//
//  Created by Alex on 5/16/19.
//  Copyright © 2019 alex. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

protocol ImagePickerDelegate: class {
    func didSelect(image: UIImage?)
}

 extension ImagePicker {
    enum SourceType {
        case camera
        case photoLibrary
    }
}

final class ImagePicker: NSObject {

    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?

    var navigationBarIsTranslucent: Bool? {
        didSet {
            pickerController.navigationBar.isTranslucent = navigationBarIsTranslucent ?? false
        }
    }

    var navigationBarBarTintColor: UIColor? {
        didSet {
            pickerController.navigationBar.barTintColor = navigationBarBarTintColor ?? .black
        }
    }

    var navigationBarTintColor: UIColor? {
        didSet {
            pickerController.navigationBar.tintColor = navigationBarTintColor ?? .white
        }
    }

    var navigationBarTitlesColor: UIColor? {
        didSet {
            pickerController.navigationBar.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: navigationBarTitlesColor ?? .white
            ]
        }
    }

    init(presentationController: UIViewController,
         delegate: ImagePickerDelegate) {

        pickerController = UIImagePickerController()
        super.init()

        self.presentationController = presentationController
        self.delegate = delegate
        pickerController.delegate = self

        pickerController.allowsEditing = true
        pickerController.mediaTypes = [kUTTypeImage as String]
    }

    func present(type: SourceType) {

        pickerController.sourceType = type == .camera ? .camera : .photoLibrary

        PHPhotoLibrary.requestAuthorization { [weak self] newStatus in
            guard let self = self else { return }

            if newStatus == PHAuthorizationStatus.authorized {
                self.presentationController?.present(self.pickerController, animated: true)
            } else {
                let alert = UIAlertController(title: "Unable to access Photo Library",
                                              message: "To enable access, go to Settings",
                                              preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in

                    if let url = URL(string: UIApplication.openSettingsURLString) {
                          UIApplication.shared.open(url)
                    }
                })

                self.presentationController?.present(alert, animated: true,
                                                     completion: nil)
            }
        }
    }
}

extension ImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        pickerController(picker, didSelect: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        guard let image = info[.editedImage] as? UIImage else {
            return pickerController(picker, didSelect: nil)
        }

        pickerController(picker, didSelect: image)
    }
}

private extension ImagePicker {
    func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)
        delegate?.didSelect(image: image)
    }
}
