
import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var buttomConstraint: NSLayoutConstraint!
    
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
        setUpNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        if isLogin {
            isLogin = false
        } else {
            self.navigationController?.isNavigationBarHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkTypeDevice()
        configurationForView()
        emailTextField.changeColor(textForPlaceHoder: "Email")
        passwordTextField.changeColor(textForPlaceHoder: "Password")
    }
    
    private func checkTypeDevice() {
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
            buttomConstraint.constant = 300
        } else {
            buttomConstraint.constant = 78
        }
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
    
    func setUpNotification()  {
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
        let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! UInt
        checkTypeDevice()
        let options = UIViewAnimationOptions(rawValue: curve << 16)
        
        UIView.animate(withDuration: duration, delay: 0, options: options,
                       animations: {
                        self.view.layoutIfNeeded()
                        
        },
                       completion: nil
        )
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
        let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! UInt
        buttomConstraint.constant = keyboardHeight
        let options = UIViewAnimationOptions(rawValue: curve << 16)
        UIView.animate(withDuration: duration, delay: 0, options: options,
                       animations: {
                        self.view.layoutIfNeeded()
                        
        },
                       completion: nil
        )
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
