//
//  NavigationInstTVCell.swift
//  Job V2
//
//  Created by Saleh Sultan on 12/13/16.
/*
 Copyright (c) 2019. Davaco, Inc. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import UIKit

class NavigationInstTVCell: UITableViewCell {

    @IBOutlet weak var summaryTitle: UILabel!
    @IBOutlet weak var astericklbl: UILabel!
    @IBOutlet weak var cameraIcon: UIImageView!
    @IBOutlet weak var photoCountlbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        photoCountlbl.layer.cornerRadius = 8
        photoCountlbl.clipsToBounds = true
        
        let imgView = UIImageView(image: UIImage(named: "CellBgImg"))
        imgView.frame = self.frame
        self.backgroundView = imgView
        
        let selImgView = UIImageView(image: UIImage(named: "CellBgSelected"))
        selImgView.frame = self.frame
        self.selectedBackgroundView = selImgView
        self.selectionStyle = .blue
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.photoCountlbl.backgroundColor = Utility.UIColorFromRGB(Constants.PHOTO_COUNTER_RED_COLOR)
    }

}
