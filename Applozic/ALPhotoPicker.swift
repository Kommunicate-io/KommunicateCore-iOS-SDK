//
//  ALPhotoPicker.swift
//  Applozic
//
//  Created by apple on 12/11/20.
//  Copyright © 2020 applozic Inc. All rights reserved.
//

import Foundation
import PhotosUI

@objc public class ALPhotoPicker: NSObject {
    @objc public weak var delegate: ALCustomPickerDelegate?
    private var selectionLimit: Int
    private var loadingTitle: String = ""
    private let multimediaData: ALMultimediaData = ALMultimediaData()
    @objc public init(selectionLimit: Int,
                      loadingTitle: String) {
        self.selectionLimit = selectionLimit
        self.loadingTitle = loadingTitle
        super.init()
    }

    @available(iOS 14, *)
    @objc public func openGallery(from controller: UIViewController) {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = selectionLimit
        var filter: PHPickerFilter?
        if  ALApplozicSettings.imagesHiddenInGallery() {
            filter = .any(of: [.videos])
        } else if  ALApplozicSettings.videosHiddenInGallery() {
            filter = .any(of: [.images])
        } else{
            filter = .any(of: [.images, .videos])
        }
        configuration.filter = filter
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        controller.present(picker, animated: true)
    }

    @available(iOS 14, *)
    private func export(
        results: [PHPickerResult],
        completion: @escaping (_ images: [UIImage], _ videos: [String], _ gif: [Data]) -> Void
    ) {
        var selectedImages: [UIImage] = []
        var selectedVideosPath: [String] = []
        var selectedGif: [Data] = []
        let exportGroup = DispatchGroup()
        DispatchQueue.global(qos: .userInitiated).async {
            for result in results {
                exportGroup.enter()
                let provider = result.itemProvider
                if  provider.hasItemConformingToTypeIdentifier(UTType.gif.identifier) {
                    provider.loadDataRepresentation(forTypeIdentifier: UTType.gif.identifier) { (data, error) in
                        if let error = error {
                            print("Failed to export gif due to error: \(error)")
                        } else if let data = data {
                            selectedGif.append(data)
                        }
                        exportGroup.leave()
                    }
                } else if provider.canLoadObject(ofClass: UIImage.self) {
                    provider.loadObject(ofClass: UIImage.self) { image, error in
                        if let error = error {
                            print("Failed to export image due to error: \(error)")
                        } else if let image = image as? UIImage {
                            selectedImages.append(image)
                        }
                        exportGroup.leave()
                    }
                } else {
                    provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                        if let error = error {
                            print("Failed to export video due to error: \(error)")
                        } else if let url = url,
                                  let newURL = ALUtilityClass.moveFileToDocuments(withFileURL: url) {
                            selectedVideosPath.append(newURL.path)
                        }
                        exportGroup.leave()
                    }
                }
            }
            exportGroup.wait()
            DispatchQueue.main.async {
                completion(selectedImages, selectedVideosPath, selectedGif)
            }
        }
    }

    private func selectedMultimediaList(images: [UIImage], videos: [String], gifs: [Data]) -> [ALMultimediaData] {
        var multimediaList = [ALMultimediaData]()

        for gifData in gifs {
            multimediaList.append(multimediaData.getOf(ALMultimediaTypeGif, with: UIImage.animatedImage(withAnimatedGIFData: gifData),
                                                       withGif: gifData, withVideo: nil))
        }

        for image in images {
            multimediaList.append(multimediaData.getOf(ALMultimediaTypeImage, with: image, withGif: nil, withVideo: nil))
        }

        for video in videos {
            multimediaList.append(multimediaData.getOf(ALMultimediaTypeVideo, with: nil, withGif: nil, withVideo: video))
        }

        return multimediaList
    }
}

@available(iOS 14, *)
extension ALPhotoPicker: PHPickerViewControllerDelegate {
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard !results.isEmpty else {
            picker.dismiss(animated: true)
            return
        }
        let alertController = ALUIUtilityClass.displayLoadingAlertController(withText: loadingTitle);
        export(results: results) { images, videos, gifData in
            ALUIUtilityClass.dismiss(alertController) { (dismiss) in
                picker.dismiss(animated: true)
                self.delegate?.multimediaSelected(self.selectedMultimediaList(images: images, videos: videos, gifs: gifData))
            }
        }
    }
}
