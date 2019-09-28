//
//  ATableViewCell.swift
//  NoSwipeDeleteConflictPageVC
//
//  Created by songgeb on 2019/9/28.
//  Copyright © 2019 Songgeb. All rights reserved.
//

import UIKit

class ATableViewCell: UITableViewCell {
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .default, reuseIdentifier: reuseIdentifier)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
      // Configure the view for the selected state
  }
}
