import Foundation

class TestPhotoService: PhotoServiceProtocol {
    static let sharedInstance = TestPhotoService()
    static var shared: PhotoServiceProtocol {
        return sharedInstance
    }

    func fetchPhotoURLs(callback: @escaping ([URL]) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            let randomTime = Int(arc4random_uniform(3))
            sleep(UInt32(randomTime))
            let firstBatchPhotoURLs:[URL] = [
                URL(string:"https://res.cloudinary.com/demo/image/upload/w_200/lady.jpg")!,
                URL(string:"https://2.bp.blogspot.com/-TIVjrZoRo5w/TlfpWuPSNNI/AAAAAAAAAMU/IEYVDKHjlcA/s1600/brandon1.jpg")!,
                URL(string:"https://lh6.ggpht.com/xUs1_N-QMCcFOQNG3is8BCyIjjgA2flDCVP9MY3cC6ZdFRkS4MIkReJUKKQuYp6qmQ=h900")!,
                URL(string:"https://ichef.bbci.co.uk/news/320/media/images/73505000/jpg/_73505007_152602014.jpg")!,
                URL(string:"https://cdn.vox-cdn.com/thumbor/rRVbiu0-67h_fpesGzNMTvu3T04=/0x0:5616x3744/920x613/filters:focal(0x0:5616x3744)/cdn.vox-cdn.com/uploads/chorus_image/image/49596913/GettyImages-125827288.0.jpg")!
            ]
//            let firstBatchPhotoURLs:[URL] = [
//                URL(string:"https://res.cloudinary.com/demo/image/upload/w_200/lady.jpg")!,
//                URL(string:"https://2.bp.blogspot.com/-TIVjrZoRo5w/TlfpWuPSNNI/AAAAAAAAAMU/IEYVDKHjlcA/s1600/brandon1.jpg")!,
//            ]
            let photoURLs = firstBatchPhotoURLs + firstBatchPhotoURLs // + firstBatchPhotoURLs + firstBatchPhotoURLs + firstBatchPhotoURLs
            DispatchQueue.main.async {
                callback(photoURLs)
            }
        }
    }
    
    func fetchImageDataFromURL(url: URL, callback: @escaping (Data) -> ()) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!)
            } else {
                // let imageId = String(Array(String(describing: url))[36...40])
                // print("image-fetch \(imageId)")
                let randomSeconds = 0 //Int(arc4random_uniform(20))/4
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(randomSeconds), execute: {
                    callback(data!)
                })
            }
            }.resume()
    }
}

