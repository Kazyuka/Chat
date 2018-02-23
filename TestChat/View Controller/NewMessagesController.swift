
import UIKit
import FirebaseDatabase
import FirebaseAuth
class NewMessagesController: UITableViewController {
    let cellId = "cell"
    
    var userArray = [User]()
    var messagesViewComtroller: MessagesViewConroller?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(closeConreoller))
        self.tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        getAllUser()
    }
    
    func getAllUser() {
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let users = snapshot.value as? [String: AnyObject] {
                let user = User.init(dic: users)
                user.userId = snapshot.key
                if Auth.auth().currentUser?.uid != user.userId {
                     self.userArray.append(user)
                }
            }
            self.tableView.reloadData()
        }, withCancel: nil)
    }
    
    @objc func closeConreoller() {
        self.dismiss(animated: true, completion: nil)
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        cell.user = userArray[indexPath.row]
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            let user = self.userArray[indexPath.row]
            self.messagesViewComtroller?.goToChat(user: user)
        }
    }
}
