import Foundation

class Post: NSObject {
    var image: String
    var created: TimeInterval
    var post: String
    var username: String
    var profile: String
    var id: String
    var uid: String
    var comments: [String: Any]
    var likes: [String: Any]
    var bookmarks: [String: Any]
    var additionalImages: [String: String]
    
    init(uid: String, id: String, dictionary: [String: Any]) {
        self.image = dictionary["image"] as! String
        self.created = dictionary["created"] as! TimeInterval
        self.post = dictionary["post"] as! String
        self.username = dictionary["username"] as! String
        self.profile = dictionary["profile"] as! String
        self.comments = dictionary["comments"] as? [String: Any] ?? [:]
        self.likes = dictionary["likes"] as? [String: Any] ?? [:]
        self.bookmarks = dictionary["bookmarks"] as? [String: Any] ?? [:]
        self.additionalImages =  dictionary["additionalImages"] as? [String: String] ?? [:]
        self.id = id
        self.uid = uid
    }
    
    override var description: String {
        get {
            return self.post
        }
    }
}

