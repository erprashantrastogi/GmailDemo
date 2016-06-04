//
//  EmailListCell.swift
//  gmaildemo
//
//  Created by Prashant Rastogi on 04/06/16.
//  Copyright © 2016 Prashant Rastogi. All rights reserved.
//

import UIKit

class EmailListCell: UITableViewCell {

    @IBOutlet weak var viewOfCircle: UIView!
    @IBOutlet weak var lblSender: UILabel!
    @IBOutlet weak var lblSubject: UILabel!
    @IBOutlet weak var lblMsgDesc: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
