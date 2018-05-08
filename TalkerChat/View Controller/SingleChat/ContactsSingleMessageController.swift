
import UIKit
import FirebaseDatabase
import FirebaseAuth
import NVActivityIndicatorView

class ContactsSingleMessageController: UIViewController {

    var userArray = [User]()
    var filteredUsers = [User]()
    var messagesViewComtroller: ChatController?
    var activityIndicator: NVActivityIndicatorView?
    var searchController:UISearchController!
    
    private var currentUserUid: String! {
        return Auth.auth().currentUser?.uid
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var offset = UIOffset()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.separatorColor = UIColor.clear
        setupNavigationBar()
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Contacts".localized
        searchController = UISearchController(searchResultsController: nil);
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.placeholder = "Search".localized
        self.textByCenterSearchController(searchController: searchController, space: 50)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        activityIndicator = NVActivityIndicatorView.init(frame: CGRect.init(x: self.view.frame.width/2, y: self.view.frame.height/2, width: 30.0, height: 30.0), type: .ballClipRotatePulse, color:  #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), padding: 0.0)
        self.view.addSubview(activityIndicator!)
        
        FirebaseInternetConnection.isConnectedToInternet { (isConnect) in
            self.activityIndicator?.startAnimating()
            if isConnect {
                  self.getAllUser()
            } else {
                  self.activityIndicator?.stopAnimating()
            }
        }
    }
    
    func setupNavigationBar() {
        
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.003921568627, green: 0.7450980392, blue: 0.9411764706, alpha: 1)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 21, weight: UIFont.Weight.bold), NSAttributedStringKey.foregroundColor: UIColor.white]
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.backgroundColor = #colorLiteral(red: 0.003921568627, green: 0.7450980392, blue: 0.9411764706, alpha: 1)
        searchController.searchBar.tintColor = .white
        if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textfield.textAlignment = .center
            if let glassIconView = textfield.leftView as? UIImageView {
                glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
                glassIconView.tintColor = .white
            }
            textfield.textColor = UIColor.white
            textfield.placeholder = "Search"
            let textFieldInsideSearchBarLabel = textfield.value(forKey: "placeholderLabel") as? UILabel
            textFieldInsideSearchBarLabel?.textColor = UIColor.white
            
            if let backgroundview = textfield.subviews.first {
                backgroundview.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
                backgroundview.layer.cornerRadius = 18
                backgroundview.clipsToBounds = true
            }
        }
        offset = UIOffset(horizontal:( searchController.searchBar.frame.width / 2) - 60 , vertical: 0)
        searchController.searchBar.setPositionAdjustment(offset, for: .search)
    }
    
    func getAllUser() {
        userArray.removeAll()
        let ref = Database.database().reference().child("users")
        ref .observe(.childAdded, with: { (snapshot) in
            if let users = snapshot.value as? [String: AnyObject] {
                let user = User.init(dic: users)
                user.userId = snapshot.key
                if Auth.auth().currentUser?.uid != user.userId {
                    self.userArray.append(user)
                }
            }
            DispatchQueue.main.async(execute: {
                self.activityIndicator?.stopAnimating()
                self.tableView.reloadData()
            })
        }, withCancel: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            self.activityIndicator?.stopAnimating()
        })
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
        cell.selectionStyle = .none
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
        return 72
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
