import Foundation

class PhotoService: PhotoServiceProtocol {
    
    static let sharedInstance = PhotoService()
    static var shared: PhotoServiceProtocol { return sharedInstance }
    
    let unsplashClientId = "c9b97043ba3f66181d31a05b5de431316a79b3d38f6fb847a20382dedcc03269"
    
    var page = 0
    
    func createPhotoServiceUrl() -> URL {
        page += 1
        return URL(string: "https://api.unsplash.com/photos/?client_id=\(self.unsplashClientId)&page=\(page)")!
    }
    
    func fetchPhotoURLs(callback: @escaping ([URL]) -> ()) {
        let task = URLSession.shared.dataTask(with: self.createPhotoServiceUrl()) { (data, response, error) in
            if error != nil {
                print(error!)
            } else {
                if let usableData = data {
                    let photoURLs = PhotoMeta.decodeToUrls(data: usableData)
                    DispatchQueue.main.async {
                        callback(photoURLs)
                    }
                }
            }
        }
        task.resume()
    }
    
    func fetchImageDataFromURL(url: URL, callback: @escaping (Data) -> ()) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!)
            } else {
                let imageId = String(Array(String(describing: url))[36...40])
                print("image-fetch \(imageId)")
                let randomSeconds = Int(arc4random_uniform(20))/4
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(randomSeconds), execute: {
                    callback(data!)
                })
            }
        }.resume()
    }
}

