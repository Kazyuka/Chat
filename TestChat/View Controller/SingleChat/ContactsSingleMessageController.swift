
import UIKit
import FirebaseDatabase
import FirebaseAuth
class ContactsSingleMessageController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var userArray = [User]()
    var filteredUsers = [User]()
    var messagesViewComtroller: ChatController?
    var searchController:UISearchController!
    
    private var currentUserUid: String! {
        return Auth.auth().currentUser?.uid
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    let placeholderWidth = 200
    var offset = UIOffset()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       /* self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.3019607843, green: 0.7411764706, blue: 0.9294117647, alpha: 1)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        navigationController?.navigationBar.shadowImage = UIImage()*/
       /* searchBar.searchBarStyle = .minimal
     
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            
            if let glassIconView = textfield.leftView as? UIImageView {
                glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
                glassIconView.tintColor = .white
            }
            textfield.textColor = UIColor.white
            textfield.placeholder = "Search"
            let textFieldInsideSearchBarLabel = textfield.value(forKey: "placeholderLabel") as? UILabel
            textFieldInsideSearchBarLabel?.textColor = UIColor.white
            
            if let backgroundview = textfield.subviews.first {
                backgroundview.backgroundColor = #colorLiteral(red: 0.5137254902, green: 0.8196078431, blue: 0.9490196078, alpha: 1)
                backgroundview.layer.cornerRadius = 18
                backgroundview.clipsToBounds = true
            }
        }*/
        userArray.removeAll()
        getAllUser()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Contacts".localized
        searchController = UISearchController(searchResultsController: nil);
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.placeholder = "Search".localized
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
            if userArray.count != 0 {
                cell.user = userArray[indexPath.row]
            }
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
        let idGroup = self.currentUserUid + " " + user.uid!
        let reverseidGroup = user.uid! + " " + self.currentUserUid
        
        let refChatRom = Database.database().reference().child("chat-romm").child(idGroup)
        
        refChatRom.observeSingleEvent(of: .value) { (snap) in
            
            if snap.value is NSNull {
                
                let refChatRom2 = Database.database().reference().child("chat-romm").child(reverseidGroup)
                
                refChatRom2.observeSingleEvent(of: .value, with: { (snap) in
                    
                    if snap.value is NSNull  {
                        self.searchController.isActive = false
                        chatLogController.unicKyeForChatRoom = idGroup
                        self.navigationController?.pushViewController(chatLogController, animated: true)
                    } else {
                        self.searchController.isActive = false
                        chatLogController.unicKyeForChatRoom = reverseidGroup
                        self.navigationController?.pushViewController(chatLogController, animated: true)
                    }
                })
                
            } else {
                self.searchController.isActive = false
                chatLogController.unicKyeForChatRoom = idGroup
                self.navigationController?.pushViewController(chatLogController, animated: true)
            }
        }
    }
}

extension ContactsSingleMessageController: UISearchResultsUpdating {
    @available(iOS 8.0, *)
    public func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text {
            filteruserByFirstName(searchText: searchText)
            tableView.reloadData()
        }
    }
    
    func filteruserByFirstName(searchText:String) {
        
        filteredUsers = userArray.filter({ (room) -> Bool in
            let name = room.name.range(of: searchText, options: NSString.CompareOptions.caseInsensitive, range: nil, locale: nil)
            return name != nil
        })
        
        if filteredUsers.count == 0 {
            filterContentByLastName(searchText: searchText)
        }
    }
    
    func filterContentByLastName(searchText:String) {
        filteredUsers = userArray.filter({ (room) -> Bool in
            let name = room.lastName!.range(of: searchText, options: NSString.CompareOptions.caseInsensitive, range: nil, locale: nil)
            return name != nil
        })
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
