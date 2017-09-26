import Foundation

class PhotoService: PhotoServiceProtocol {
    
    static let sharedInstance = TestPhotoService()
    
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
                    let photoURLs: [URL] = self.deserializePhotoDataToMediumStrings(data: usableData).map{URL(string: $0)!}
                    DispatchQueue.main.async {
                        callback(photoURLs)
                    }
                }
            }
        }
        task.resume()
    }
    
    private func deserializePhotoDataToMediumStrings(data: Data) -> [String] {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [Any] {
                let photoURLStrings: [String] = json.map{element in
                    if let jsonElement = element as? [String: Any],
                        let userJson = jsonElement["user"] as? [String: Any],
                        let profileImageJson = userJson["profile_image"] as? [String: Any],
                        let mediumUrl = profileImageJson["medium"] as? String {
                        return mediumUrl
                    } else {
                        return "https://cdn.browshot.com/static/images/not-found.png"
                    }
                }
                return photoURLStrings
            } else {
                return []
            }
        } catch {
            print("error")
            return []
        }
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

