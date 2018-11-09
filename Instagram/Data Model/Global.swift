import UIKit
import Firebase

let cache = NSCache<AnyObject, UIImage>()
var posts: [Post] = []

public func loadPosts(completion: (() -> Void)? = nil) {
    let uid = UserDefaults.standard.object(forKey: "uid") as! String
    Database.database().reference().child("posts").child(uid).queryOrdered(byChild: "created").observeSingleEvent(of: .value, with: { (snap) in
        posts = []
        if snap.value is NSNull {
            fetchFollowersPosts(uid: uid, completion: completion)
            return
        }
        let data = snap.value as! [String: Any]
        data.forEach({ (key, val) in
            let value = val as! [String: Any]
            let post = Post(uid: uid, id: key, dictionary: value)
            posts.append(post)
        })
        fetchFollowersPosts(uid: uid, completion: completion)
    })
}

private func fetchFollowersPosts(uid: String, completion: (() -> Void)? = nil) {
    Database.database().reference().child("users").child(uid).child("usersFollowed").observeSingleEvent(of: .value, with: { (snap) in
        guard let dat = snap.value as? [String: Any] else {
            completion?()
            return
        }
        dat.forEach({ (otherUID,_) in   Database.database().reference().child("posts").child(otherUID).observeSingleEvent(of: .value, with: { (snap) in
            if snap.value is NSNull {
                completion?()
                return
            }
            let data = snap.value as! [String: Any]
            data.forEach({ (id, val) in
                let value = val as! [String: Any]
                let post = Post(uid: otherUID, id: id, dictionary: value)
                posts.append(post)
            })
            completion?()
        })
        })
    })
}


public func incrementUserIntegerMetaDataByOne(child: String, key: String, completion: (() -> Void)? = nil) {
    Database.database().reference().child("users").child(child).observeSingleEvent(of: .value, with: { (snap) in
        let dict = snap.value as! [String: Any]
        let previous = dict[key] as! Int
        Database.database().reference().child("users").child(child).updateChildValues([key : previous + 1])
        completion?()
    })
}

public func decreseUserIntegerMetaDataByOne(child: String, key: String, completion: (() -> Void)? = nil) {
    Database.database().reference().child("users").child(child).observeSingleEvent(of: .value, with: { (snap) in
        let dict = snap.value as! [String: Any]
        let previous = dict[key] as! Int
        let newValue = max(0, previous - 1)
        Database.database().reference().child("users").child(child).updateChildValues([key : newValue])
        completion?()
    })
}

public func follow(currentUser: String, otherUser: String) {
    Database.database().reference().child("users").child(currentUser).child("usersFollowed").updateChildValues([otherUser: 1])
        incrementUserIntegerMetaDataByOne(child: currentUser, key: "following")
    Database.database().reference().child("users").child(otherUser).child("usersFollowing").updateChildValues([currentUser: 1])
        incrementUserIntegerMetaDataByOne(child: otherUser, key: "followers")
}

public func unfollow(currentUser: String, otherUser: String) {
    Database.database().reference().child("users").child(currentUser).child("usersFollowed").child(otherUser).removeValue()
        decreseUserIntegerMetaDataByOne(child: currentUser, key: "following")
    Database.database().reference().child("users").child(otherUser).child("usersFollowing").child(currentUser).removeValue()
        decreseUserIntegerMetaDataByOne(child: otherUser, key: "followers")
}


public func getTimeElapsed(_ time: TimeInterval) -> String{
    let diff = Date().timeIntervalSince1970 - time
    if diff < 60 {
        return String.init(format: "%.0f seconds ago", diff)
    } else if diff < 3600 {
        return String.init(format: "%.0f minutes ago", diff/60)
    } else if diff < 86400 {
        return String.init(format: "%.0f hours ago", diff/3600)
    } else if diff < 604800 {
        return String.init(format: "%.0f days ago", diff/86400)
    } else if diff < 2.628e+6 {
        return String.init(format: "%.0f weeks ago", diff/604800)
    } else if diff < 3.154e+7 {
        return String.init(format: "%.0f months ago", diff/2.628e+6)
    }
    return String.init(format: "%.0f years ago", diff/3.154e+7)
}


func heightForView(post: Post, width: CGFloat) -> CGFloat{
    let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
    label.numberOfLines = 0
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    let attributedText = NSMutableAttributedString(string: post.username + " ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
    attributedText.append(NSAttributedString(string: post.post , attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]))
    attributedText.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 4)]))
    attributedText.append(NSAttributedString(string: getTimeElapsed(post.created), attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13), NSAttributedString.Key.foregroundColor: UIColor.gray]))
    label.attributedText = attributedText
    label.sizeToFit()
    
    return label.frame.height
}

func heightForCommentView(comment: CommentItem, width: CGFloat) -> CGFloat{
    let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
    label.numberOfLines = 0
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    let attributedText = NSMutableAttributedString(string: comment.username + " ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
    attributedText.append(NSAttributedString(string: comment.comment, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13), NSAttributedString.Key.foregroundColor: UIColor.black]))
    label.attributedText = attributedText
    label.sizeToFit()
    
    return label.frame.height
}



func postComment(comment: String, id: String, uid: String) -> [String: Any]{
      let username = UserDefaults.standard.object(forKey: "username") as! String
      let profile = UserDefaults.standard.object(forKey: "profile") as! String
    let data: [String: Any] = ["profile" : profile, "username": username, "comment": comment, "time": Date().timeIntervalSince1970]

    Database.database().reference().child("posts").child(uid).child(id).child("comments").childByAutoId().updateChildValues(data)
    return data
}


func like(id: String, uid: String) {
    let current = UserDefaults.standard.object(forKey: "uid") as! String
    Database.database().reference().child("posts").child(uid).child(id).child("likes").updateChildValues([current : 1])
}


func dislike(id: String, uid: String) {
   let current = UserDefaults.standard.object(forKey: "uid") as! String
Database.database().reference().child("posts").child(uid).child(id).child("likes").child(current).removeValue()
}



func bookmark(id: String, uid: String) {
    let current = UserDefaults.standard.object(forKey: "uid") as! String
    Database.database().reference().child("posts").child(uid).child(id).child("bookmarks").updateChildValues([current : 1])
}


func unbookmark(id: String, uid: String) {
    let current = UserDefaults.standard.object(forKey: "uid") as! String
    Database.database().reference().child("posts").child(uid).child(id).child("bookmarks").child(current).removeValue()
}
