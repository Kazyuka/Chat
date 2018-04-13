
import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {
    var messagseController: MessagesViewConroller?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.lightGray
        view.addSubview(inputContainerView)
        view.addSubview(registerButton)
        view.addSubview(loginSegmentViewControl)
        view.addSubview(imageTopView)
        setInputContainerView()
        setRegisterButton()
        setImageView()
        setupLoginRegiterSegmentVC()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tapGesture)
    }
    
    lazy var inputContainerView: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var userNameTextField: UITextField = {
        var name = UITextField()
        name.placeholder = "User Name"
        name.translatesAutoresizingMaskIntoConstraints = false
        return name
    }()
    
    lazy var emailTextField: UITextField = {
        var name = UITextField()
        name.placeholder = "Email"
        name.text = "R@gmail.ru"
        name.translatesAutoresizingMaskIntoConstraints = false
        return name
    }()
    
    lazy var passwordTextField: UITextField = {
        var name = UITextField()
        name.placeholder = "Password"
        name.text = "111111"
        name.translatesAutoresizingMaskIntoConstraints = false
        return name
    }()
    
    lazy var registerButton: UIButton = {
       var button = UIButton(type: .system)
        button.backgroundColor = UIColor.blue
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.setTitle("Register", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(registerNewUser), for: .touchUpInside)
       return button
    }()
    
    lazy var nameSeparetaView: UIView = {
        var button = UIView()
        button.backgroundColor = UIColor.blue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var imageTopView: UIImageView = {
        var im = UIImageView.init(image: UIImage.init(named: "bart.png"))
        im.translatesAutoresizingMaskIntoConstraints = false
        im.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(tapToImage)))
        im.isUserInteractionEnabled = true
        return im
    }()
    
    lazy var emailSeparetaView: UIView = {
        var button = UIView()
        button.backgroundColor = UIColor.blue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var loginSegmentViewControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(changeSegmentState), for: .valueChanged)
        return sc
    } ()
    
    func  setImageView() {
        imageTopView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageTopView.bottomAnchor.constraint(equalTo: loginSegmentViewControl.topAnchor, constant: -40).isActive = true
        imageTopView.widthAnchor.constraint(equalToConstant: 90).isActive = true
        imageTopView.heightAnchor.constraint(equalToConstant: 90).isActive = true
    }
    
    func setupLoginRegiterSegmentVC() {
        loginSegmentViewControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginSegmentViewControl.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: -10).isActive = true
        loginSegmentViewControl.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        loginSegmentViewControl.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    func setRegisterButton() {
        registerButton.topAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: 24).isActive = true
        registerButton.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        registerButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    var inputConteinerViewHeightConstr: NSLayoutConstraint?
    var nameTextFieldHeightConstr: NSLayoutConstraint?
    var emailTextFieldHeightConstr: NSLayoutConstraint?
    var passwordTextFieldHeightConstr: NSLayoutConstraint?
    
    func setInputContainerView() {
        
        inputContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -25).isActive = true
        inputConteinerViewHeightConstr = inputContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputConteinerViewHeightConstr?.isActive = true
        inputContainerView.addSubview(userNameTextField)
        inputContainerView.addSubview(nameSeparetaView)
        inputContainerView.addSubview(emailTextField)
        inputContainerView.addSubview(emailSeparetaView)
        inputContainerView.addSubview(passwordTextField)
        
        userNameTextField.topAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: 1).isActive = true
        userNameTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 10).isActive = true
        userNameTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        nameTextFieldHeightConstr = userNameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightConstr?.isActive = true
        
        nameSeparetaView.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        nameSeparetaView.topAnchor.constraint(equalTo: userNameTextField.bottomAnchor).isActive = true
        nameSeparetaView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        nameSeparetaView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        emailTextField.topAnchor.constraint(equalTo: nameSeparetaView.bottomAnchor, constant: 1).isActive = true
        emailTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 10).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        emailTextFieldHeightConstr =  emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightConstr?.isActive = true
        
        emailSeparetaView.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        emailSeparetaView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparetaView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        emailSeparetaView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        passwordTextField.topAnchor.constraint(equalTo: emailSeparetaView.bottomAnchor, constant: 1).isActive = true
        passwordTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 10).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        passwordTextFieldHeightConstr = passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightConstr?.isActive = true
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
