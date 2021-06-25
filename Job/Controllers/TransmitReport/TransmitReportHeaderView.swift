//
//  TransmitReportHeaderView.swift
//  Job
//
//  Created by Saleh Sultan on 7/16/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
//

import UIKit


protocol SectionHeaderViewDelegate {
    func sectionHeaderView(sectionHeaderView: TransmitReportHeaderView, sectionOpened: Int)
    func sectionHeaderView(sectionHeaderView: TransmitReportHeaderView, sectionClosed: Int)
}

class TransmitReportHeaderView: UITableViewHeaderFooterView {

    var section: Int?
    @IBOutlet var titlelbl: UILabel!
    @IBOutlet var statuslbl: UILabel!
    @IBOutlet var uploadProgress: UIProgressView!
    var isViewingDetails:Bool = false
    var delegate: SectionHeaderViewDelegate?
    
    @objc func toggleOpen() {
        self.isViewingDetails = !self.isViewingDetails
        if self.isViewingDetails {
            self.delegate?.sectionHeaderView(sectionHeaderView: self, sectionOpened: self.section!)
        } else {
            self.delegate?.sectionHeaderView(sectionHeaderView: self, sectionClosed: self.section!)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleOpen))
        self.addGestureRecognizer(tapGesture)
    }
}
