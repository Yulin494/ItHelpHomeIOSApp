//
//  MainTableViewCell.swift
//  ItHelpHome
//
//  Created by imac on 2025/9/24.
//

import UIKit

class MainTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lbText: UILabel!
    @IBOutlet weak var imgRight: UIImageView!
    @IBOutlet weak var imgLeft: UIImageView!
    @IBOutlet weak var vView: UIView!
    @IBOutlet weak var bubbleLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var bubbleTrailingConstraint: NSLayoutConstraint!
    
    static let identifile = "MainTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        vView.layer.cornerRadius = 15
        imgLeft.layer.cornerRadius = 20
        imgRight.layer.cornerRadius = 20
        
        lbText.numberOfLines = 0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    /// 負責接收資料，並更新 Cell 的所有 UI，如果是使用者的話，讓vView靠左，反之則相反
    /// - Parameter message: 傳入訊息
    func configure(with message: Message) {
        lbText.text = message.text
        
        if message.sender == .user {
            imgLeft.isHidden = true
            imgRight.isHidden = false
            
            imgRight.image = UIImage(named: "me")
            vView.backgroundColor = .systemBlue
            lbText.textColor = .white
            
            bubbleLeadingConstraint.isActive = false
            bubbleTrailingConstraint.isActive = true
            
        } else {
            imgLeft.isHidden = false
            imgRight.isHidden = true
            imgLeft.image = UIImage(named: "security")
            
            vView.backgroundColor = UIColor(white: 0.25, alpha: 1.0)
            lbText.textColor = .white
            
            bubbleLeadingConstraint.isActive = true
            bubbleTrailingConstraint.isActive = false
        }
    }
}
