//
//  IBDesignableButton.swift
//  RSSIMeasure_iOS
//
//  Created by 司嶋川 on 2018/05/09.
//  Copyright © 2018年 ISDL. All rights reserved.
//

import UIKit

class IBDesignableButton: UIButton {
    // 基準とする画面横幅
    let baseScreenWidth : CGFloat = 320.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        changeFontSize()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        changeFontSize()
    }
    
    /**
     画面比率に応じて、フォントサイズを変更します
     */
    private func changeFontSize() {
        self.titleLabel?.font = UIFont(name: (titleLabel?.font.fontName)!, size: (self.titleLabel?.font.pointSize)! * getScreenRatio())!
    }
    
    
    /**
     baseScreenWidthと、画面の横幅との比率を返します
     - returns: 画面比率
     */
    private func getScreenRatio() -> CGFloat {
        return UIScreen.main.bounds.size.width / baseScreenWidth
    }
}
