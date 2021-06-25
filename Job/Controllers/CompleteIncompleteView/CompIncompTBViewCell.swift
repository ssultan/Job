//
//  CompIncompTBViewCell.swift
//  Job V2
//
//  Created by Saleh Sultan on 12/1/16.
/*
 Copyright (c) 2019. Davaco, Inc. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import UIKit

class CompIncompTBViewCell: UITableViewCell {

    @IBOutlet weak var templateName: UILabel!
    @IBOutlet weak var projectNumber: UILabel!
    @IBOutlet weak var storeNumber: UILabel!
    @IBOutlet weak var checkBoxBt: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let imgView = UIImageView(image: UIImage(named: "CellBgImg"))
        imgView.frame = self.frame
        self.backgroundView = imgView
        self.accessoryType = .disclosureIndicator
        self.backgroundColor = .clear
        
        let selImgView = UIImageView(image: UIImage(named: "CellBgSelected"))
        selImgView.frame = self.frame
        self.selectedBackgroundView = selImgView
        self.selectionStyle = .blue
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func updateCell(instance:JobInstanceModel) {
        
        self.templateName.text = instance.templateName ?? "Unknown"
        self.projectNumber.text = "Proj Num: \(instance.projectNumber ?? "")"
        self.storeNumber.text = "Loc Num: \(instance.storeNumber ?? "")"
        
        // Change the color of the survey instance, if the survey received an error at the time of sending instance.
        if NSInteger(truncating: NSNumber(value: instance.errorCode)) == SendProcErrorCode.InsertFailed.rawValue ||
            NSInteger(truncating: NSNumber(value: instance.errorCode)) == SendProcErrorCode.InstDoesNotExistOrDeletedInServerDB.rawValue {
            self.templateName.textColor = .red
            self.projectNumber.textColor = .red
            self.storeNumber.textColor = .red
        }
        else if instance.template == nil || instance.location == nil  {
            self.templateName.textColor = .gray
            self.projectNumber.textColor = .gray
            self.storeNumber.textColor = .gray
        }
        else {
            self.templateName.textColor = .white
            self.projectNumber.textColor = .white
            self.storeNumber.textColor = .white
        }
        
        if instance.template == nil || instance.location == nil {
            self.checkBoxBt.isEnabled = false
        }
        else {
            self.checkBoxBt.isEnabled = true
        }
    }
}
