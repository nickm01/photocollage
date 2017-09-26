import Foundation

struct PhotoMeta: Codable {
    let user: User
    struct User: Codable {
        let profile_image: ProfileImage
        struct ProfileImage: Codable {
            let medium: String
        }
    }
    
    static func decodeToUrls(data: Data) -> [URL] {
        do {
            let decoder = JSONDecoder()
            let elements = try decoder.decode([PhotoMeta].self, from: data)
            print(elements.count)
            print(elements[0].user.profile_image.medium)
            let urls: [URL] = elements.map {
                return URL(string: $0.user.profile_image.medium)!
            }
            return urls
        } catch {
            print(error)
            return []
        }
    }
}
