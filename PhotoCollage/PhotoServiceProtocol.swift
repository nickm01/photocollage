import Foundation

protocol PhotoServiceProtocol {
    static var shared: PhotoServiceProtocol { get }
    func fetchPhotoURLs(callback: @escaping ([URL]) -> ())
    func fetchImageDataFromURL(url: URL, callback: @escaping (Data) -> ())
}
