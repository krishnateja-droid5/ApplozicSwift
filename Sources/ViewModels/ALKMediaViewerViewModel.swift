//
//  ALKMediaViewerViewModel.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 28/08/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import AVFoundation

protocol ALKMediaViewerViewModelDelegate: class {
    func reloadView()
}

final class ALKMediaViewerViewModel: NSObject, Localizable {
    
    var configuration: ALKConfiguration!
    
    private var savingImagesuccessBlock: (() -> ())?
    private var savingImagefailBlock: ((Error) -> ())?

    fileprivate var downloadImageSuccessBlock: (() -> ())?
    fileprivate var downloadImageFailBlock: ((String) -> ())?

    fileprivate lazy var loadingFailErrorMessage: String = {
        let text = localizedString(forKey: "DownloadOriginalImageFail", withDefaultValue: SystemMessage.Warning.DownloadOriginalImageFail, config: configuration)
        return text
    }()

    fileprivate var messages: [ALKMessageViewModel]
    fileprivate var currentIndex: Int {
        didSet {
            delegate?.reloadView()
        }
    }
    fileprivate var isFirstIndexAudioVideo = false
    weak var delegate: ALKMediaViewerViewModelDelegate?

    init(messages: [ALKMessageViewModel], currentIndex: Int, configuration: ALKConfiguration) {
        self.messages = messages
        self.currentIndex = currentIndex
        super.init()
        checkCurrent(index: currentIndex)
    }


    func saveImage(image: UIImage?, successBlock: @escaping () -> (), failBlock: @escaping (Error) -> ()) {

        self.savingImagesuccessBlock   = successBlock
        self.savingImagefailBlock      = failBlock

        guard let image = image else {
            failBlock(NSError(domain: "IMAGE_NOT_AVAILABLE", code: 0 , userInfo: nil))
            return
        }

        UIImageWriteToSavedPhotosAlbum(image, self, #selector(ALKMediaViewerViewModel.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error, let failBlock = savingImagefailBlock {
            failBlock(error)
        } else if let successBlock = savingImagesuccessBlock {
            successBlock()
        }
    }

    func getTotalCount() -> Int {
        return messages.count
    }

    func getMessageForCurrentIndex() -> ALKMessageViewModel? {
        return getMessageFor(index: currentIndex)
    }

    func getTitle() -> String {
        return "\(currentIndex+1) of \(getTotalCount())"
    }

    func updateCurrentIndex(by incr: Int) {
        let newIndex = currentIndex + incr
        guard newIndex >= 0 && newIndex < messages.count else { return }
        currentIndex = newIndex
    }

    func getURLFor(name: String) -> URL{
        let docDirPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docDirPath.appendingPathComponent(name)
    }

    func getThumbnail(filePath: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: filePath , options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            return UIImage(cgImage: cgImage)

        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }

    func isAutoPlayTrueForCurrentIndex() -> Bool{
        return isFirstIndexAudioVideo
    }

    func currentIndexAudioVideoPlayed() {
        isFirstIndexAudioVideo = false
    }

    private func getMessageFor(index: Int) -> ALKMessageViewModel? {
        guard index < messages.count else { return nil}
        return messages[index]
    }

    private func checkCurrent(index: Int) {
        guard index < messages.count, (messages[currentIndex].messageType == .video || messages[currentIndex].messageType == .voice) else { return }
        isFirstIndexAudioVideo = true
    }
}
