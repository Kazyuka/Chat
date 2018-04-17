
import UIKit
import FirebaseAuth
import SDWebImage
import FirebaseDatabase

@objc protocol ChatCollectionViewCellDelegate {
    func tapToImage(gesture: UIImageView)
}
class ChatCollectionViewCell: UICollectionViewCell {
   
    var const: CGFloat = 200
    weak var delegate: ChatCollectionViewCellDelegate?
    var message: Message? {
        didSet {
            dataForCell()
        }
    }
    func dataForCell()  {
        messageText.text = message?.text
        let uid = Auth.auth().currentUser?.uid
      
        if let messageImage = message?.imageUrl {
            let url = NSURL.init(string: messageImage)
            messageImageView.sd_setImage(with: url as! URL)
            messageImageView.isHidden = false
            messageText.isHidden = true
        } else {
            messageImageView.isHidden = true
            messageText.isHidden = false
        }
        
        if uid == message?.fromIdUser {
            bubleView.backgroundColor = UIColor.lightGray
            messageText.textColor = UIColor.black
            
            bubleLeftAchor?.isActive = false
            bubleRightAchor?.isActive = true
            imageUser.isHidden = true
        } else {
            bubleView.backgroundColor = UIColor.blue
            messageText.textColor = UIColor.white
            bubleLeftAchor?.isActive = true
            bubleRightAchor?.isActive = false
            
            if let fromId = message?.fromIdUser {
               
                let refUser = Database.database().reference().child("users").child(fromId)
                refUser.observeSingleEvent(of: .value, with: { (snap) in
                    
                    if let data = snap.value as? [String  : AnyObject] {
                        
                        let user = User.init(dic: data)
                        let url = NSURL.init(string: user.imageProfile!)
                        self.imageUser.sd_setImage(with: url as! URL)
                        self.imageUser.isHidden = false
                    }
                })
            }
        }

        if let messageText =  message!.text {
            let widthTextConst = (messageText.width(withConstrainedHeight: 2000, font: UIFont.boldSystemFont(ofSize: 14))) <= 40 ? 50 : (message?.text?.width(withConstrainedHeight: 2000, font: UIFont.boldSystemFont(ofSize: 14)))! + 20
            bubleWidthAchor?.constant = widthTextConst
        } else {
             bubleWidthAchor?.constant = const
        }
    }
    var bubleWidthAchor: NSLayoutConstraint?
    var bubleRightAchor: NSLayoutConstraint?
    var bubleLeftAchor: NSLayoutConstraint?
    
    lazy var messageText: UITextView = {
        var tv = UITextView()
        tv.text = "u"
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
        bv.translatesAutoresizingMaskIntoConstraints = false
        bv.layer.cornerRadius = 12
        bv.layer.masksToBounds = true
        bv.contentMode = .scaleAspectFill
        return bv
    }()
    
    lazy var messageImageView: UIImageView = {
        var bv = UIImageView()
        bv.translatesAutoresizingMaskIntoConstraints = false
        bv.layer.cornerRadius = 16
        bv.layer.masksToBounds = true
        bv.contentMode = .scaleAspectFill
        bv.isUserInteractionEnabled = true
        return bv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureCell()
    }
    @objc func tapToImageInsideCell(_ sender: UITapGestureRecognizer) {
        let view = sender.view as? UIImageView
        self.delegate?.tapToImage(gesture: view!)
    }

    func configureCell() {
        
        addSubview(bubleView)
        addSubview(messageText)
        addSubview(imageUser)
        addSubview(messageImageView)
        
        bubleView.addSubview(messageImageView)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapToImageInsideCell(_:)))
        gesture.numberOfTapsRequired = 1
        messageImageView.addGestureRecognizer(gesture)
    
        
        messageImageView.leftAnchor.constraint(equalTo: bubleView.leftAnchor).isActive = true
        messageImageView.rightAnchor.constraint(equalTo: bubleView.rightAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubleView.topAnchor).isActive = true
        messageImageView.bottomAnchor.constraint(equalTo: bubleView.bottomAnchor).isActive = true
        
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
