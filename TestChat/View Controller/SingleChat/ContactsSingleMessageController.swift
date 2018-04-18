
import UIKit
import FirebaseDatabase
import FirebaseAuth
class ContactsSingleMessageController: UIViewController {
    
    var userArray = [User]()
    var filteredUsers = [User]()
    var messagesViewComtroller: ChatController?
    var searchController:UISearchController!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        userArray.removeAll()
        getAllUser()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController = UISearchController(searchResultsController: nil);
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.placeholder = "Search"
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
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
    
  private  func findUsers(text: String) {
        filteredUsers.removeAll()
        Database.database().reference().child("users").queryOrdered(byChild: "name").queryStarting(atValue: text).queryEnding(atValue: text+"\u{f8ff}").observe(.value, with: { (snap) in
    
            for u in snap.value as! NSDictionary {
                let userValue = u.value as! Dictionary<String, AnyObject>
                let us = User.init(dic: userValue)
                self.filteredUsers.append(us)
            }
            self.tableView.reloadData()
        }) { (error) in }
    }
}


extension ContactsSingleMessageController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredUsers.count
        } else {
            return userArray.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserCell
        
        if searchController.isActive && searchController.searchBar.text != "" {
            cell.user = filteredUsers[indexPath.row]
        } else {
            cell.user = userArray[indexPath.row]
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let user = self.userArray[indexPath.row]
        let chatLogController =  self.storyboard?.instantiateViewController(withIdentifier: "ChatSingleController") as! ChatSingleController
        chatLogController.user = user
        self.navigationController?.pushViewController(chatLogController, animated: true)
    }
}

extension ContactsSingleMessageController: UISearchResultsUpdating {
    @available(iOS 8.0, *)
    public func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text{
            findUsers(text: searchText)
            tableView.reloadData()
        }
    }
}

extension ContactsSingleMessageController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.searchController.isActive = false
        self.tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
}
