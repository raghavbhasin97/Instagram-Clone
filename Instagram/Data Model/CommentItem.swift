import Foundation

struct CommentItem {
    var profile: String
    var username: String
    var comment: String
    var time: TimeInterval
    
    init(data: [String: Any]) {
        self.username = data["username"] as! String
        self.profile = data["profile"] as! String
        self.comment = data["comment"] as! String
        self.time = data["time"] as! TimeInterval
    }
}
