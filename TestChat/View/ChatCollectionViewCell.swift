
import UIKit
import FirebaseAuth
class ChatCollectionViewCell: UICollectionViewCell {
    var message: Message? {
        didSet {
            dataForCell()
        }
    }
    func dataForCell()  {
        messageText.text = message?.text
        
        if Auth.auth().currentUser?.uid == message?.fromIdUser {
            bubleView.backgroundColor = UIColor.lightGray
            messageText.textColor = UIColor.black
            imageUser.isHidden = true
            bubleLeftAchor?.isActive = false
            bubleRightAchor?.isActive = true
        } else {
            bubleView.backgroundColor = UIColor.blue
            bubleLeftAchor?.isActive = true
            bubleRightAchor?.isActive = false
            imageUser.isHidden = false
        }
        let const = (message?.text?.width(withConstrainedHeight: 2000, font: UIFont.boldSystemFont(ofSize: 14)))! <= 40 ? 50 : (message?.text?.width(withConstrainedHeight: 2000, font: UIFont.boldSystemFont(ofSize: 14)))! + 20
        bubleWidthAchor?.constant = const
    }
    var bubleWidthAchor: NSLayoutConstraint?
    var bubleRightAchor: NSLayoutConstraint?
    var bubleLeftAchor: NSLayoutConstraint?
    
    lazy var messageText: UITextView = {
        var tv = UITextView()
        tv.text = "sadasd Ssfdsf sdfsdfsd sdf dsfsdfsadhgjghj gj fgjghjfdf df tydfty dfg dfy fydfy dfyf dgyd fydfy afsdfsdf"
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.isScrollEnabled = false
        tv.backgroundColor = UIColor.clear
        tv.textColor = UIColor.white
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    lazy var bubleView: UIView = {
        var bv = UIView()
        bv.backgroundColor = UIColor.blue
        bv.translatesAutoresizingMaskIntoConstraints = false
        bv.layer.cornerRadius = 12
        bv.layer.masksToBounds = true
        return bv
    }()
    
    lazy var imageUser: UIImageView = {
        var bv = UIImageView()
        bv.backgroundColor = UIColor.blue
        bv.translatesAutoresizingMaskIntoConstraints = false
        bv.layer.cornerRadius = 12
        bv.layer.masksToBounds = true
        bv.contentMode = .scaleAspectFill
        return bv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Shat user")
    }
    
    func configureCell() {
        
        addSubview(bubleView)
        addSubview(messageText)
        addSubview(imageUser)
        
        imageUser.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        imageUser.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        imageUser.widthAnchor.constraint(equalToConstant: 35).isActive = true
        imageUser.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        bubleRightAchor = bubleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubleRightAchor?.isActive = true
        
        bubleLeftAchor = bubleView.leftAnchor.constraint(equalTo: self.imageUser.rightAnchor, constant: 8)
        bubleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubleWidthAchor = bubleView.widthAnchor.constraint(equalToConstant: 200)
        bubleWidthAchor?.isActive = true
        bubleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        messageText.leftAnchor.constraint(equalTo: bubleView.leftAnchor, constant: 8).isActive = true
        messageText.rightAnchor.constraint(equalTo: bubleView.rightAnchor).isActive = true
        messageText.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        messageText.widthAnchor.constraint(equalToConstant: 200).isActive = true
        messageText.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
}
