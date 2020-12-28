//
//  MyFriendsTableViewCell.swift
//  SlateOfficial
//
//  Created by Timmy Van Cauwenberge on 12/14/20.
//

import UIKit

class MyFriendsTableViewCell: UITableViewCell {
    
    //MARK: IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    
    var indexPath: IndexPath!
    

    override func awakeFromNib() {
           super.awakeFromNib()
       }

       override func setSelected(_ selected: Bool, animated: Bool) {
           super.setSelected(selected, animated: animated)
       }
       
       
       func configure(user: User) {
           
           fullNameLabel.text = user.fullName
           setAvatar(avatarLink: user.avatarLink)
       }
    
//    func generateCellWith(user: User, indexPath: IndexPath) {
//        
//        self.indexPath = indexPath
//        
//        self.fullNameLabel.text = user.fullName
//        
//        if user.avatarLink != "" {
//            
//            imageFromData(pictureData: user.avatarLink) { (avatarImage) in
//                
//                if avatarImage != nil {
//                    
//                    self.avatarImageView.image = avatarImage!.circleMasked
//                }
//            }
//        }
//        
//    }
       
       private func setAvatar(avatarLink: String) {
           
           if avatarLink != "" {
               FileStorage.downloadImage(imageUrl: avatarLink) { (avatarImage) in
                   self.avatarImageView.image = avatarImage?.circleMasked
               }
           } else {
               self.avatarImageView.image = UIImage(named: "avatar")
           }
       }

   }
