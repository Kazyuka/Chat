
import UIKit
import FirebaseAuth
import SDWebImage
import FirebaseDatabase
import AVKit
@objc protocol ChatCollectionViewCellDelegate {
    func tapToImage(gesture: UIImageView)
    func playVideo(video: NSURL)
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
      
        if message?.videoUrl != nil {
            playButton.isHidden = false
        } else {
            playButton.isHidden = true
        }
        
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
            bubleView.backgroundColor = #colorLiteral(red: 0.003921568627, green: 0.7450980392, blue: 0.9411764706, alpha: 1)
            messageText.textColor = UIColor.white
            
            bubleLeftAchor?.isActive = false
            bubleRightAchor?.isActive = true
            imageUser.isHidden = true
        } else {
            bubleView.backgroundColor = #colorLiteral(red: 0.9019607843, green: 0.9058823529, blue: 0.9215686275, alpha: 1)
            messageText.textColor = UIColor.black
            bubleLeftAchor?.isActive = true
            bubleRightAchor?.isActive = false
            
            if let fromId = message?.fromIdUser {
               
                let refUser = Database.database().reference().child("users").child(fromId)
                refUser.observeSingleEvent(of: .value, with: { (snap) in
                    
                    if let data = snap.value as? [String  : AnyObject] {
                        
                        let user = User.init(dic: data)
                       
                        if let im = user.imageProfile {
                            let url = NSURL.init(string: im)
                            self.imageUser.sd_setImage(with: url! as URL)
                        } else {
                            
                            self.imageUser.sd_setImage(with: NSURL() as URL, placeholderImage: UIImage.init(named: "userImage.png"), options: .cacheMemoryOnly, progress: { (y, r, ur) in
                            }, completed: nil)
                        }
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
    
    lazy var playButton: UIButton = {
        var button = UIButton(type: .system)
        var image = UIImage.init(named: "play")
        button.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        
        if message?.videoUrl != nil {
             return
        }
        let view = sender.view as? UIImageView
        self.delegate?.tapToImage(gesture: view!)
    }
    
    @objc func playVideo() {
      
        if let videoUrlString = message?.videoUrl, let url = NSURL.init(string: videoUrlString){
        
            self.delegate?.playVideo(video: url)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }

    func configureCell() {
        
        addSubview(bubleView)
        addSubview(messageText)
        addSubview(imageUser)
        addSubview(messageImageView)
        
        bubleView.addSubview(messageImageView)
        bubleView.addSubview(playButton)
  
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapToImageInsideCell(_:)))
        gesture.numberOfTapsRequired = 1
        messageImageView.addGestureRecognizer(gesture)
    
        playButton.centerXAnchor.constraint(equalTo: bubleView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: bubleView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
  
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
