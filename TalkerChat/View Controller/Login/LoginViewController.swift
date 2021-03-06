
import UIKit
import FirebaseAuth
import FirebaseDatabase
import NVActivityIndicatorView

class LoginViewController: UIViewController {
    
    @IBOutlet weak var buttomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var singUplabel: UILabel!
    
    @IBOutlet weak var singUpButton: UIButton!
    
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var notHaveAccountLabel: UILabel!
    
    var messagseController: ChatController?
    
    var activityIndicator: NVActivityIndicatorView?
    
    var isLogin = false
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.navigationBar.backItem?.title = ""
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
        emailTextField.changeColor(textForPlaceHoder: "Email".localized, size: 16.0)
        passwordTextField.changeColor(textForPlaceHoder: "Password".localized, size: 16.0)
        loginButton.setTitle("SIGN IN".localized, for: .normal)
        notHaveAccountLabel.text = "Do not have an account?".localized
        singUpButton.setTitle("Sing Up!".localized, for: .normal)
        activityIndicator = NVActivityIndicatorView.init(frame: CGRect.init(x: self.view.frame.width/2, y: self.view.frame.height/2, width: 30.0, height: 30.0), type: .ballClipRotatePulse, color:  #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), padding: 0.0)
        activityIndicator?.center = self.view.center
        self.view.addSubview(activityIndicator!)
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
        activityIndicator?.startAnimating()
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            self.activityIndicator?.stopAnimating()
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (user, err) in
            
            if err != nil {
                self.activityIndicator?.stopAnimating()
                self.present(self.allertControllerWithOneButton(message: err!.localizedDescription), animated: true, completion: nil)
                return
            }
            
            guard let uid = Auth.auth().currentUser?.uid else {
                return
            }
            
            let value = ["deviceId": AppDelegate.DEVICEID] as? [String: AnyObject]
            let ref = Database.database().reference().child("users").child(uid)
            ref.updateChildValues(value!)
            
            self.isLogin = true
            self.activityIndicator?.stopAnimating()
            let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "TabController") as! TabController
    
            self.present(chatVC, animated: true, completion: nil)
        }
    }
}
