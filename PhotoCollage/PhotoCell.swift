import UIKit

class PhotoCell: UICollectionViewCell {
    
    var url: URL?
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let downloadingView: UIActivityIndicatorView = {
        let downloadingView = UIActivityIndicatorView(frame: CGRect.zero)
        downloadingView.translatesAutoresizingMaskIntoConstraints = false
        return downloadingView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.blue
        addViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addViews() {
        self.addSubview(self.downloadingView)
        downloadingView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        downloadingView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        downloadingView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        downloadingView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        self.downloadingView.startAnimating()
        
        
        self.addSubview(self.imageView)
        imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
    
    override func prepareForReuse() {
        self.imageView.image = nil
        self.downloadingView.startAnimating()
        self.url = nil
    }
    
    func setImage(_ image: UIImage) {
        self.imageView.image = image
        self.downloadingView.stopAnimating()
    }
    
    func setImageIfNotOldRequest(image: UIImage, url: URL) {
        if self.url == url {
            self.setImage(image)
        }
    }
    
    func configure(storedImage: UIImage?, url: URL, callback: @escaping (UIImage) -> ()) {
        self.url = url
        guard let image = storedImage else {
            PhotoService.shared.fetchImageDataFromURL(url: url, callback: {[unowned self] data in
                if let image = UIImage(data: data) {
                    callback(image)
                    self.setImageIfNotOldRequest(image: image, url: url)
                }
            })
            return
        }
        self.setImage(image)
    }
}
