//
//  StartJobTvCell.swift
//  Job
//
//  Created by Saleh Sultan on 5/21/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
//

import UIKit

class StartJobTvCell: UITableViewCell {

    @IBOutlet weak var projectNolbl: UILabel!
    @IBOutlet weak var jobNamelbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        let imgView = UIImageView(image: UIImage(named: "CellBgImg"))
        imgView.frame = self.frame
        self.backgroundView = imgView
        self.accessoryType = .disclosureIndicator
        
        let selImgView = UIImageView(image: UIImage(named: "CellBgSelected"))
        selImgView.frame = self.frame
        self.selectedBackgroundView = selImgView
        self.selectionStyle = .blue
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateCell(template: TemplateModel) {
        self.backgroundColor = UIColor.clear
        self.jobNamelbl.text = (template.templateName)! as String
        self.jobNamelbl.sizeToFit()
        self.projectNolbl.text = "Project : \((template.projectNumber)! as String)"
    }
}
