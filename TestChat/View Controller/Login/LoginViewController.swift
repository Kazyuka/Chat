
import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var singUpButton: UIButton!
    
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    var messagseController: ChatController?
    
    var isLogin = false
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isLogin {
            isLogin = false
        } else {
            self.navigationController?.isNavigationBarHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurationForView()
    }
    
    private func configurationForView() {
        forgotPasswordButton.setTitle("Forgot password".localized, for: .normal)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tapGesture)
        loginButton.layer.cornerRadius = 24
        loginButton.clipsToBounds = true
    }
    
    @IBAction func registerButtonClick(_ sender: Any) {
        let registerVC =  self.storyboard?.instantiateViewController(withIdentifier: "RegisterController") as! RegisterController
        self.navigationController?.pushViewController(registerVC, animated: true)
    }
    
    @IBAction func resretPasswordButtonClick(_ sender: Any) {
        let resetVC = self.storyboard?.instantiateViewController(withIdentifier: "ResetPasswordController") as! ResetPasswordController
        self.navigationController?.pushViewController(resetVC, animated: true)
    }
    
    @objc func hideKeyboard(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func loginUserButtonClick(_ sender: Any) {
        self.loginUser()
    }
    
    private func loginUser() {
        
        guard let email = emailTextField.text, let password = passwordTextField.text else { return  }
        Auth.auth().signIn(withEmail: email, password: password) { (user, err) in
            
            if err != nil {
                self.present(self.allertControllerWithOneButton(message: err!.localizedDescription), animated: true, completion: nil)
                return
            }
            self.isLogin = true
        
            let chatVC =  self.storyboard?.instantiateViewController(withIdentifier: "TabController") as! TabController
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
}
