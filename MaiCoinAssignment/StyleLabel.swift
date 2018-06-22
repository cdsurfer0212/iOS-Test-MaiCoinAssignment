//
//  StyleLabel.swift
//  MaiCoinAssignment
//
//  Created by Sean Zeng on 2018/6/24.
//  Copyright © 2018 Sean Zeng. All rights reserved.
//

import UIKit

class StyleLabel: UILabel {

    public var edgeInsets: UIEdgeInsets?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textAlignment = .center
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        textAlignment = .center
    }
    
    override open var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        if let insets = edgeInsets {
            size.width += insets.left + insets.right
            size.height += insets.top + insets.bottom
        }
        return size
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, edgeInsets ?? UIEdgeInsets.zero))
    }

}
