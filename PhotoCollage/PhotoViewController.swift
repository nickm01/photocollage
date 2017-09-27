import UIKit

class PhotoViewController: UIViewController {
    
    let photoService = PhotoService()
    let cellReuseId = "cell"
    let pagingCount = 10

    var maxIndex = 0
    var photoCollectionView: UICollectionView!
    var cellCount = 0
    var batchUpdating = false
    
    var urls: [URL?] = []
    var images: [UIImage?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets.zero
        layout.minimumLineSpacing = 0
        layout.itemSize = self.view.frame.size // CGSize(width: 50, height: 50)
        layout.scrollDirection = .horizontal
        
        photoCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        photoCollectionView.register(PhotoCell.self, forCellWithReuseIdentifier: cellReuseId)
        
        photoCollectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(photoCollectionView)
        photoCollectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        photoCollectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        photoCollectionView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        photoCollectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        photoCollectionView.isPagingEnabled = true
        
        self.loadMore()
    }
    
    func loadMoreIfNeeded() {
        if !self.batchUpdating && self.maxIndex > self.cellCount - (self.pagingCount / 2) {
            self.loadMore()
        }
    }
    
    func loadMore() {
        let startingIndex = self.cellCount
        let startingUrlsIndex = self.urls.count
        self.urls += Array(repeating: nil, count: self.pagingCount)
        self.images += Array(repeating: nil, count: self.pagingCount)

        print("loadMoreUrls starting Index = \(self.cellCount)")

        self.insertCells(startingIndex: startingIndex)
        self.fetchUrls(startingIndex: startingUrlsIndex)
    
    }
    
    func insertCells(startingIndex: Int) {
        self.photoCollectionView.performBatchUpdates({
            self.batchUpdating = true
            self.cellCount += self.pagingCount
            print("range: \(startingIndex) \(startingIndex + self.pagingCount) count:\(self.urls.count)")
            let indexPaths = Array(startingIndex..<startingIndex + self.pagingCount).map{
                return IndexPath(row: $0, section: 0)
            }
            self.photoCollectionView.insertItems(at: indexPaths)
        }, completion: {[unowned self] success in
            self.batchUpdating = false
            self.loadMoreIfNeeded()
        })
    }
    
    func fetchUrls(startingIndex: Int) {
        PhotoService.shared.fetchPhotoURLs(callback: {[unowned self] urls in
            print("fetch URLs complete: \(startingIndex) count:\(self.urls.count)")
            urls.enumerated().forEach { (index: Int, url: URL) in
                let mainIndex = startingIndex + index
                self.urls[mainIndex] = url
                if let pendingCell = self.photoCollectionView.cellForItem(at: IndexPath(row: mainIndex, section:0)) as? PhotoCell {
                    self.configureAndStoreImage(cell: pendingCell, storedImage: self.images[mainIndex], url: url, index: index)
                }
            }
            print("- Empty URLS:\(self.urls.filter{$0 == nil}.count)")
        })
    }
    
    func configureAndStoreImage(cell: PhotoCell, storedImage: UIImage?, url: URL, index: Int) {
        cell.configure(storedImage: storedImage, url: url, callback: {[unowned self] image in
            self.images[index] = image
        })
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.loadMoreIfNeeded()
    }
}

extension PhotoViewController: UICollectionViewDelegate {
}

extension PhotoViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.cellCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseId, for: indexPath) as! PhotoCell
        let index = indexPath.row
        
        if index < self.urls.count, let url = self.urls[index] {
            self.configureAndStoreImage(cell: cell, storedImage: self.images[index], url: url, index: index)
        }

        if index > self.maxIndex {
            self.maxIndex = index
            print("max:\(self.maxIndex)")
        }

        self.loadMoreIfNeeded()
        return cell
    }
}

