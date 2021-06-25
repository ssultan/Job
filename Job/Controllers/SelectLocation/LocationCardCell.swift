//
//  LocationCardCell.swift
//  Job V2
//
//  Created by Saleh Sultan on 9/7/16.
/*
 Copyright (c) 2019. Davaco, Inc. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import UIKit

class LocationCardCell: UITableViewCell {

    @IBOutlet weak var streetViewBtn: UIButton!
    @IBOutlet weak var mapDirLocation: UIButton!
    @IBOutlet weak var storeNolbl: UILabel!
    @IBOutlet weak var addresslbl: UILabel!
    @IBOutlet weak var cityStZiplbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
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
    }
}
