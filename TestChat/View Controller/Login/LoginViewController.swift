
import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var firstNmeLastNAmeView: UIView!
    @IBOutlet weak var registerLoginSegment: UISegmentedControl!

    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var messagseController: ChatController?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.lightGray
      
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func changeSegmentStatment(_ sender: Any) {
        
        switch registerLoginSegment.selectedSegmentIndex {
        case 0:
            loginButton.setTitle("Register", for: .normal)
            firstNmeLastNAmeView.isHidden = false
            forgotPasswordButton.isHidden = true
        case 1:
            loginButton.setTitle("Login", for: .normal)
            firstNmeLastNAmeView.isHidden = true
            forgotPasswordButton.isHidden = false
        default:
            break
        }
    }
    @IBAction func registerButtonClick(_ sender: Any) {
        registerNewUser()
    }
    
    @IBAction func resretPasswordButtonClick(_ sender: Any) {
        let resetVC = self.storyboard?.instantiateViewController(withIdentifier: "ResetPasswordController") as! ResetPasswordController
        self.present(resetVC, animated: true, completion: nil)
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func hideKeyboard(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func registerNewUser() {
    
         registerLoginSegment.selectedSegmentIndex == 1 ? loginUser() : registerUser()
    }
    
    func loginUser() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return  }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, err) in
            
            if err != nil {
                self.present(self.allertControllerWithOneButton(message: err!.localizedDescription), animated: true, completion: nil)
                return
            }
            self.messagseController?.isUserLogin()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func registerUser() {
        
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = firstNameTextField.text, let lastName = lastNameTextField.text else { return  }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            if error != nil {
                
                self.present(self.allertControllerWithOneButton(message: error!.localizedDescription), animated: true, completion: nil)
                return
            }
            
            guard let uid = user?.uid else { return }
            
            let value = ["name": name, "email": email,"lastName" : lastName, "aboutMe": "", "uid": uid]
            self.registerUserIntoFirebase(uid: uid, value: value as [String : AnyObject] )
        }
    }
    
    private func registerUserIntoFirebase(uid: String, value: [String: AnyObject]) {
        
        let ref = Database.database().reference()
        let user = ref.child("users").child(uid)
        user.updateChildValues(value, withCompletionBlock: { (err, dref) in
            if err != nil {
                return
            }
            let user = User(dic: value)
            self.messagseController?.setupNAvigationBar(user: user)
            self.dismiss(animated: true, completion: nil)
        })
    }
}
