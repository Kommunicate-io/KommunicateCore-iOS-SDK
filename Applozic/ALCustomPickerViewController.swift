//
//  CustomPickerView.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 14/07/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import UIKit
import Photos

enum ALCameraPhotoType {
    case NoCropOption
    case CropOption
}

enum ALCameraType {
    case Front
    case Back
}

class ALPhotoCollectionCell: UICollectionViewCell {

    @IBOutlet weak var videoIcon: UIImageView!
    @IBOutlet var imgPreview: UIImageView!

    @IBOutlet weak var selectedIcon: UIImageView!
}

public class ALBaseNavigationViewController: UINavigationController {

    override public func viewDidLoad() {
        super.viewDidLoad()

        setNeedsStatusBarAppearanceUpdate()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

}

@objc public protocol ALCustomPickerDelegate: class {
    @objc func multimediaSelected(_ list: [ALMultimediaData])
}

@objc public class ALCustomPickerViewController: UIViewController {
    //photo library
    var asset: PHAsset!
    var allPhotos: PHFetchResult<PHAsset>!
    var selectedImage:UIImage!
    var cameraMode:ALCameraPhotoType = .NoCropOption
    let option = PHImageRequestOptions()
    var selectedRows = [Int]()
    var selectedImages = [Int: PHAsset]()
    var selectedVideos = [Int: PHAsset]()
    var selectedGifs = [Int: PHAsset]()
    
    // EXPORT PROGRESS VALUES
    var exportingVideoSessions = [String: AVAssetExportSession]()
    var progressItems = [String: Progress]()
    var mainProgress: Progress?
    var exportProgressBarTimer: Timer?
    var exportWasCalceled = false
    
    
    var multimediaData: ALMultimediaData = ALMultimediaData()
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    weak var delegate: ALCustomPickerDelegate?
    

    @IBOutlet weak var previewGallery: UICollectionView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        doneButton.title = NSLocalizedString("DoneButton", value: "Done", comment: "")
        self.title = NSLocalizedString("PhotosTitle", value: "Photos", comment: "")
        checkPhotoLibraryPermission()
        previewGallery.delegate = self
        previewGallery.dataSource = self
        previewGallery.allowsMultipleSelection = true
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigation()
    }

    @objc public static func makeInstanceWith(delegate: ALCustomPickerDelegate) -> ALBaseNavigationViewController? {
        let storyboard = UIStoryboard(name: "CustomPicker", bundle: Bundle(for: ALChatViewController.self))
//        let storyboard = UIStoryboard.name(storyboard: UIStoryboard.Storyboard.picker, bundle: Bundle.applozic)
        guard
            let vc = storyboard.instantiateViewController(withIdentifier: "CustomPickerNavigationViewController")
                as? ALBaseNavigationViewController,
            let cameraVC = vc.viewControllers.first as? ALCustomPickerViewController else { return nil }
        cameraVC.delegate = delegate
        return vc
    }

    //MARK: - UI control
    private func setupNavigation() {
        self.navigationController?.title = title
        guard let navVC = self.navigationController else {return}
        navVC.navigationBar.shadowImage = UIImage()
        navVC.navigationBar.isTranslucent = true
        var backImage = UIImage.init(named: "icon_back", in: Bundle(for: ALChatViewController.self), compatibleWith: nil)
        if #available(iOS 9.0, *) {
            backImage = backImage?.imageFlippedForRightToLeftLayoutDirection()
        }
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: backImage, style: .plain, target: self , action: #selector(dismissAction(_:)))
        self.navigationController?.navigationBar.barTintColor = ALApplozicSettings.getColorForNavigation()
        self.navigationController?.navigationBar.tintColor = ALApplozicSettings.getColorForNavigationItem()
        if let aSize = UIFont(name: "Helvetica-Bold", size: 18) {
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: ALApplozicSettings.getColorForNavigationItem(),
                                                                            NSAttributedString.Key.font: aSize]
        }
    }

    private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            self.getAllImage(completion: { [weak self] (isGrant) in
                guard let weakSelf = self else {return}
                weakSelf.createScrollGallery(isGrant:isGrant)
            })
            break
        //handle authorized status
        case .denied, .restricted :
            break
        //handle denied status
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization() { status in
                switch status {
                case .authorized:
                    self.getAllImage(completion: {[weak self] (isGrant) in
                        guard let weakSelf = self else {return}
                        weakSelf.createScrollGallery(isGrant:isGrant)
                    })
                    break
                // as above
                case .denied, .restricted:
                    break
                default: break
                    //whatever
                }
            }
        }
    }

    //MARK: - Access to gallery images
    private func getAllImage(completion: (_ success: Bool) -> Void) {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.includeHiddenAssets = false

        let p1 = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        let p2 = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
        allPhotosOptions.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [p1, p2])
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        (allPhotos != nil) ? completion(true) :  completion(false)
    }

    private func createScrollGallery(isGrant:Bool) {
        if isGrant
        {
            self.selectedRows = Array(repeating: 0, count: (self.allPhotos != nil) ? self.allPhotos.count:0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.previewGallery.reloadData()
            })
        }

    }
    
    func exportMultipleVideos(_ assets: [PHAsset], exportStarted: @escaping () -> Void, completion: @escaping ([String]) -> Void) {
        
        guard !assets.isEmpty else {
            completion([])
            return
        }
        
        let dispatchExportStartedGroup = DispatchGroup()
        let dispatchExportCompletedGroup = DispatchGroup()
        
        var videoPaths: [String] = []
        for video in assets {
            
            dispatchExportStartedGroup.enter()
            dispatchExportCompletedGroup.enter()
            exportVideoAsset(video, exportStarted: dispatchExportStartedGroup.leave(), completion: { path in
                if let videoPath = path {
                    videoPaths.append(videoPath)
                }
                dispatchExportCompletedGroup.leave()
            })
        }
        
        dispatchExportStartedGroup.notify(queue: .main, execute: exportStarted)
        dispatchExportCompletedGroup.notify(queue: .main) {
            completion(videoPaths)
        }
    }

    func exportVideoAsset(_ asset: PHAsset, exportStarted: @autoclosure @escaping () -> Void, completion: @escaping (String?) -> Void) {
        let filename = String(format: "VID-%f.mp4", Date().timeIntervalSince1970*1000)
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let filePath = documentsUrl.absoluteString.appending(filename)
        guard var fileurl = URL(string: filePath) else {
            completion(nil)
            return
        }
        print("exporting video to ", fileurl)
        fileurl = fileurl.standardizedFileURL


        let options = PHVideoRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true

        // remove any existing file at that location
        do {
            try FileManager.default.removeItem(at: fileurl)
        }
        catch {
            // most likely, the file didn't exist.  Don't sweat it
        }

        PHImageManager.default().requestExportSession(forVideo: asset, options: options, exportPreset: AVAssetExportPresetHighestQuality) { [weak self]
            (exportSession: AVAssetExportSession?, _) in

            guard let avExportSession = exportSession else {
                print("COULD NOT CREATE EXPORT SESSION")
                completion(nil)
                return
            }

            avExportSession.outputURL = fileurl
            avExportSession.outputFileType = AVFileType.mp4 //file type encode goes here, you can change it for other types

            print("GOT EXPORT SESSION")
            avExportSession.exportAsynchronously() {
                print("EXPORT DONE")
                completion(fileurl.path)
            }
            
            self?.exportingVideoSessions[filePath] = avExportSession
            self?.progressItems[filePath] = Progress(totalUnitCount: 100)

            print("progress: \(avExportSession.progress)")
            print("error: \(String(describing: avExportSession.error))")
            print("status: \(avExportSession.status.rawValue)")
            
            exportStarted()
        }
    }
    
    func exportGifAsset(_ asset: PHAsset, completion: @escaping (Data?) -> Void){
        let options = PHImageRequestOptions()
        options.isSynchronous = true;
        options.isNetworkAccessAllowed = false;
        options.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat;
        
        gifData(asset: asset, options: options, completionHandler: {
            data, error in
            if data == nil {
                NSLog("Error while exporting gif \(error ?? "")")
            }
            completion(data)
        })
    }
    
    func gifData(asset: PHAsset, options: PHImageRequestOptions, completionHandler: @escaping ((Data?, String?)->())){
        PHImageManager().requestImageData(for: asset, options: options) { (imageData, dataUti, orientation, info) in
            if let isError = info?[PHImageErrorKey] as? String, !isError.isEmpty {
                completionHandler(nil, isError)
            }
            if let isCloud = info?[PHImageResultIsInCloudKey] as? Bool, isCloud {
                completionHandler(nil, "gif is not even present in cloud")
            }
            // success, data is in imageData
            guard let uti = dataUti else{
                completionHandler(nil, "Optional String is found to be nil")
                return
            }
            let gifUti = uti as CFString
            if UTTypeConformsTo(gifUti, kUTTypeGIF){
                completionHandler(imageData, nil)
            }
        }
    }

    @IBAction func doneButtonAction(_ sender: UIBarButtonItem) {

        let dispatchGroup = DispatchGroup()
        
        var videoPaths: [String] = []
        dispatchGroup.enter()
        exportMultipleVideos(Array(selectedVideos.values), exportStarted: { [weak self] in
            self?.showProgressAlert()
        }, completion: { paths in
            videoPaths = paths
            dispatchGroup.leave()
        })
        
        var images: [UIImage] = []
        for image in selectedImages.values {
            dispatchGroup.enter()
            PHCachingImageManager.default().requestImageData(for: image, options:nil) { (imageData, _, _, _) in
                if let image = UIImage(data: imageData!) {
                    images.append(image)
                }
                dispatchGroup.leave()
            }
        }
        
        var gifsData: [Data] = []
        for gif in selectedGifs.values {
            dispatchGroup.enter()
            exportGifAsset(gif) { data in
                if let data = data {
                    gifsData.append(data)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            
            self?.exportProgressBarTimer?.invalidate()
            guard self?.exportWasCalceled == false else {
                self?.exportWasCalceled = false
                self?.presentedViewController?.dismiss(animated: true)
                return
            }
            
            if let list = self?.selectedMultimediaList(images: images, videos: videoPaths, gifs: gifsData) {
                self?.delegate?.multimediaSelected(list)
            }
            self?.navigationController?.presentingViewController?.dismiss(animated: false, completion: nil)
        }
    }
    
    func showProgressAlert() {
        let alertView = UIAlertController(title: NSLocalizedString("Optimizing...", comment: ""), message: " ", preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { [weak self] _ in
            self?.exportWasCalceled = true
            self?.exportingVideoSessions.values.forEach { $0.cancelExport() }
            self?.progressItems.removeAll()
            self?.exportProgressBarTimer?.invalidate()
            alertView.dismiss(animated: true)
        }))
        var mainProgress: Progress?
        if #available(iOS 9.0, *) {
            mainProgress = Progress(totalUnitCount: 100)
            for item in progressItems.values {
                mainProgress?.addChild(item, withPendingUnitCount: Int64(100.0/Double(progressItems.count)))
            }
            self.mainProgress = mainProgress
        }
        
        present(alertView, animated: true, completion: {
            if #available(iOS 9.0, *) {
                let margin: CGFloat = 8.0
                let rect = CGRect(x: margin, y: 62.0, width: alertView.view.frame.width - margin * 2.0, height: 2.0)
                let progressView = UIProgressView(frame: rect)
                progressView.observedProgress = mainProgress
                progressView.tintColor = UIColor.blue
                alertView.view.addSubview(progressView)
            }
        })
        if #available(iOS 9.0, *) {
            exportProgressBarTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgressIndicator), userInfo: nil, repeats: true)
        }
    }
    
    @objc func updateProgressIndicator() {
        for (key, session) in exportingVideoSessions {
            progressItems[key]?.completedUnitCount = Int64(session.progress * 100.0)
        }
    }

    @IBAction func dismissAction(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: false, completion: nil)
    }
    
    func selectedMultimediaList(images: [UIImage], videos: [String], gifs: [Data]) -> [ALMultimediaData]{
        var multimediaList = [ALMultimediaData]()

        for image in images
        {
            multimediaList.append(multimediaData.getOf(ALMultimediaTypeImage, with: image, withGif: nil, withVideo: nil))
        }

        for video in videos
        {
            multimediaList.append(multimediaData.getOf(ALMultimediaTypeVideo, with: nil, withGif: nil, withVideo: video))
        }

        for gifData in gifs
        {
            multimediaList.append(multimediaData.getOf(ALMultimediaTypeGif, with: UIImage.animatedImage(withAnimatedGIFData: gifData),
                                                       withGif: gifData, withVideo: nil))
        }

        return multimediaList
    }
    
}

extension ALCustomPickerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    // MARK: CollectionViewEnvironment
    private class CollectionViewEnvironment {
        struct Spacing {
            static let lineitem: CGFloat = 5.0
            static let interitem: CGFloat = 0.0
            static let inset: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 3.0, bottom: 0.0, right: 3.0)
        }
    }

    // MARK: UICollectionViewDelegate
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //grab all the images
        let asset = allPhotos.object(at: indexPath.item)
        if selectedRows[indexPath.row] == 1 {
            selectedRows[indexPath.row] = 0
            if checkGif(asset: asset){
                selectedGifs.removeValue(forKey: indexPath.row)
            }else if asset.mediaType == .video {
                selectedVideos.removeValue(forKey: indexPath.row)
            } else {
                selectedImages.removeValue(forKey: indexPath.row)
            }
        } else {
            selectedRows[indexPath.row] = 1
            if checkGif(asset: asset){
                selectedGifs[indexPath.row] = asset
            }else if asset.mediaType == .video {
                selectedVideos[indexPath.row] = asset
            } else {
                selectedImages[indexPath.row] = asset
            }
        }

        previewGallery.reloadItems(at: [indexPath])
    }
    
    func checkGif(asset: PHAsset) -> Bool{
        if let identifier = asset.value(forKey: "uniformTypeIdentifier") as? String
        {
            if identifier == kUTTypeGIF as String
            {
                return true;
            }
        }
        return false;
    }
    
    // MARK: UICollectionViewDataSource
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(allPhotos == nil)
        {
            return 0
        }
        else
        {
            return allPhotos.count
        }

    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ALPhotoCollectionCell", for: indexPath) as! ALPhotoCollectionCell
        
//        cell.selectedIcon.isHidden = true
        cell.videoIcon.isHidden = true
        cell.selectedIcon.isHidden = true
        if selectedRows[indexPath.row] == 1 {
            cell.selectedIcon.isHidden = false
        }

        let asset = allPhotos.object(at: indexPath.item)
        if asset.mediaType == .video {
            cell.videoIcon.isHidden = false
        }
        let thumbnailSize:CGSize = CGSize(width: 200, height: 200)
        option.isSynchronous = true
        PHCachingImageManager.default().requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: option, resultHandler: { image, _ in
            cell.imgPreview.image = image
        })
        if checkGif(asset: asset){
            //show GIF
            gifData(asset: asset, options: option, completionHandler: {
                data, error in
                if let gifData = data {
                    cell.imgPreview.image = UIImage.animatedImage(withAnimatedGIFData: gifData)
                }else{
                    NSLog("Cannot show gif while selecting multiple medias \(error ?? "")")
                }
            })
        }

        cell.imgPreview.backgroundColor = UIColor.white

        return cell
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    // MARK: UICollectionViewDelegateFlowLayout
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CollectionViewEnvironment.Spacing.lineitem
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CollectionViewEnvironment.Spacing.interitem
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return CollectionViewEnvironment.Spacing.inset
    }
}
