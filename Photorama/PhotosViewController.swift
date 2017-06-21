//
//  Copyright © 2015 Big Nerd Ranch
//

import UIKit

class PhotosViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var store: PhotoStore!
    let photoDataSource = PhotoDataSource()
    let imageProcessor = ImageProcessor()
    let processingQueue = OperationQueue()
    let thumbnailStore = ThumbnailStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = photoDataSource
        collectionView.delegate = self
        
        updateDataSource()
        
        store.fetchInterestingPhotos {
            (photosResult) in
            
            self.updateDataSource()
        }
    }
    
    private func updateDataSource() {
        self.store.fetchAllPhotos {
            (photosResult) in
    
            switch photosResult {
            case let .success(photos):
                self.photoDataSource.photos = photos
            case .failure(_):
                self.photoDataSource.photos.removeAll()
            }
            self.collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        
        let photo = photoDataSource.photos[indexPath.row]
        
        if let photoID = photo.photoID as NSString?,
            let thumbnail = thumbnailStore.thumbnail(forKey: photoID),
            let cell = cell as? PhotoCollectionViewCell {
            cell.update(with: thumbnail)
            return
        }
        
        // Download the image data, which could take some time
        store.fetchImage(for: photo) { (result) -> Void in
                
            // The index path for the photo might have changed between the
            // time the request started and finished, so find the most
            // recent index path
            
            // (Note: You will have an error on the next line; you will fix it shortly)
            guard let photoIndex = self.photoDataSource.photos.index(of: photo),
                case let .success(image) = result else {
                    return
            }
            let photoIndexPath = IndexPath(item: photoIndex, section: 0)
            
            self.processingQueue.addOperation {
                let maxSize = CGSize(width: 200, height: 200)
                let scaleAction = ImageProcessor.Action.scale(maxSize: maxSize)
                let faceFuzzAction = ImageProcessor.Action.pixellateFaces
                let actions = [scaleAction, faceFuzzAction]
                
                let thumbnail:UIImage
                do {
                    thumbnail = try self.imageProcessor.perform(actions, on: image)
                } catch {
                    print("Error: unable to generate filtered thumbnail for \(photo): \(error)")
                    thumbnail = image
                    
                }
                
                OperationQueue.main.addOperation {
                    if let photoID = photo.photoID as NSString? {
                        self.thumbnailStore.setThumbnail(image: thumbnail, forKey: photoID)
                    }
                    
                    // When the request finishes, only update the cell if it's still visible
                    if let cell = self.collectionView.cellForItem(at: photoIndexPath)
                        as? PhotoCollectionViewCell {
                        cell.update(with: thumbnail)
                    }
                }

            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showPhoto"?:
            if let selectedIndexPath =
                collectionView.indexPathsForSelectedItems?.first {
                
                let photo = photoDataSource.photos[selectedIndexPath.row]
                
                let destinationVC =
                    segue.destination as! PhotoInfoViewController
                destinationVC.photo = photo
                destinationVC.store = store
            }
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }
}
