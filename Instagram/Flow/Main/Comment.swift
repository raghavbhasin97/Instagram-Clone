import UIKit

class Comment: BaseViewController {

    let cellId = "CommentCell"
    var post: Post? {
        didSet {
            if let post = post {
                post.comments.forEach { (_,v) in
                    if let val = v as? [String: Any] {
                        let newComment = CommentItem(data: val)
                        commentsList.append(newComment)
                    }
                    commentsList = commentsList.sorted(by: { (c1, c2) -> Bool in
                        return c1.time < c2.time
                    })
                }
                commentsTable.reloadData()
            }
        }
    }
    
    var commentsList: [CommentItem] = []
    
    lazy var commentsTable: UITableView = {
        let table = UITableView()
        table.backgroundColor = .white
        table.delegate = self
        table.dataSource = self
        table.showsVerticalScrollIndicator = false
        table.keyboardDismissMode = .onDrag
        table.separatorStyle = .none
        return table
    }()
    
    lazy var commentText: UITextField = {
        let field = UITextField()
        field.autocorrectionType = .no
        field.placeholder = "Enter your comment"
        field.addTarget(self, action: #selector(shouldEnable), for: .editingChanged)
        field.delegate = self
        return field
    }()
    
    lazy var submit: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(submitComment), for: .touchUpInside)
        button.isEnabled = false
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    lazy var containerView: UIView = {
        let container = UIView()
        container.backgroundColor = .white
        container.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        
        container.addSubview(submit)
        container.addConstraintsWithFormat(format: "H:[v0(50)]-12-|", views: submit)
        container.addConstraintsWithFormat(format: "V:|[v0]|", views: submit)
        
        container.addSubview(commentText)
        commentText.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 12).isActive = true
        commentText.rightAnchor.constraint(equalTo: submit.leftAnchor, constant: 4).isActive = true
        container.addConstraintsWithFormat(format: "V:|[v0]|", views: commentText)
        let line: UIView = {
            let view = UIView()
            view.backgroundColor = .black
            return view
        }()
        
        container.addSubview(line)
        container.addConstraintsWithFormat(format: "H:|[v0]|", views: line)
        line.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        line.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        return container
    }()
    
    @objc fileprivate func shouldEnable() {
        
        let comment = commentText.text!

        if comment.isEmpty {
            submit.setTitleColor(.black, for: .normal)
            submit.isEnabled = false
        } else {
            submit.setTitleColor(.blueInstagram, for: .normal)
            submit.isEnabled = true
        }
    }
    
    override func setup() {
        navigationItem.title = "Comments"
        view.backgroundColor = .white
        commentsTable.register(CommentCell.self, forCellReuseIdentifier: cellId)
        view.addSubview(commentsTable)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: commentsTable)
        view.addConstraintsWithFormat(format: "V:|[v0]|", views: commentsTable)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        tabBarController?.tabBar.isHidden = true
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    override var inputAccessoryView: UIView? {
        get {

            return containerView
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func submitComment() {
        let comment = commentText.text
        if let post = post {
            commentText.text = ""
            shouldEnable()
            let data = postComment(comment: comment!, id: post.id, uid: post.uid)
            let newComment = CommentItem(data: data)
            commentsTable.beginUpdates()
            commentsList.append(newComment)
            commentsTable.insertRows(at: [IndexPath(row: commentsList.count - 1, section: 0)], with: .automatic)
            post.comments[UUID().uuidString] = data
            commentsTable.endUpdates()
        }
    }
}

extension Comment: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! CommentCell
        cell.comment = commentsList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //Full frame - padding - size of profile - profile padding
        let width: CGFloat = view.frame.width - 16 - 50 - 8
        let expectedHeight = heightForCommentView(comment: commentsList[indexPath.row], width: width) + 5
        return max(60.0, expectedHeight)
    }

}

extension Comment: UITextFieldDelegate {
    
}
