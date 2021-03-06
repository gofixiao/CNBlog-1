//
//  OnlineInfoDetailViewController.swift
//  CNBlogsClient
//
//  Created by 王焕强 on 15/6/4.
//  Copyright (c) 2015年 &#29579;&#28949;&#24378;. All rights reserved.
//

import UIKit
import DTCoreText

class OnlineInfoDetailViewController: UIViewController, DTLazyImageViewDelegate, DTAttributedTextContentViewDelegate {
    
    //数据变量
    var onlineInfoDetailVM: OnlineInfoDetailViewModel = OnlineInfoDetailViewModel()

    // 控件变量
    @IBOutlet weak var onlineInfoTitleLabel: UILabel!
    @IBOutlet weak var onlineInfoAuthorLabel: UILabel!
    @IBOutlet weak var onlineInfoPublishTimeLabel: UILabel!
    @IBOutlet weak var onlineInfoOfflineBarBtn: UIBarButtonItem!
    @IBOutlet weak var onlineInfoContextATextView: DTAttributedTextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //  设置标题、作者、发表时间
        onlineInfoTitleLabel.text       = onlineInfoDetailVM.onlineInfo.title
        onlineInfoAuthorLabel.text      = onlineInfoDetailVM.onlineInfo.author
        onlineInfoPublishTimeLabel.text = onlineInfoDetailVM.onlineInfo.publishTime.dateToStringByBaseFormat()
        
        self.onlineInfoDetailVM.gainOnlineInfoListFromNetwork()
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.endWaitOfflineOnlineInfoContent()
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - 网络操作的界面操作
    /**
    开始 等待网络数据时的 指示器
    */
    func waitOfflineOnlineInfoContent() {
        self.pleaseWait()
    }
    
    /**
    结束 等待网络数据时的 指示器
    */
    func endWaitOfflineOnlineInfoContent() {
        self.clearAllNotice()
    }
    
    /**
    网络操作成功时的操作
    */
    func gainOnlineInfoInfoSuccess() {
//        self.OnlineInfoContentWebView.loadHTMLString(self.onlineInfoDetailVM.OnlineInfoInfo.content, baseURL: nil)
        let htmlData:NSData = self.onlineInfoDetailVM.onlineInfo.content.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
        let attributedString: NSAttributedString = NSAttributedString(HTMLData: htmlData, options: self.setAttributedOption() as [NSObject : AnyObject], documentAttributes: nil)
        
        self.onlineInfoContextATextView.attributedString = attributedString;
        self.onlineInfoContextATextView.textDelegate = self
        self.onlineInfoContextATextView.shouldDrawImages = false
        self.onlineInfoContextATextView.shouldDrawLinks = false
        self.onlineInfoContextATextView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    }
    
    // 主要用于设置 图片的最大尺寸
    func setAttributedOption() -> NSMutableDictionary {
        let maxImageSize: CGSize = CGSizeMake(self.view.bounds.size.width - 20.0, self.view.bounds.size.height - 20.0)

        NSMutableDictionary(dictionaryLiteral: ("name", "lnj"), ("age", 30))
        
        // TODO: 可能会错误
        let options: NSMutableDictionary = NSMutableDictionary(dictionaryLiteral: (NSTextSizeMultiplierDocumentOption, NSNumber(float: 1.0)), (DTMaxImageSize, NSValue(CGSize: maxImageSize)))
        
        return options
    }
    
    /**
    网络操作失败时，弹出topAlert指示
    */
    func showGainOnlineInfoInfoFailure() {
        TopAlert().createFailureTopAlert("获取新闻失败", parentView: self.view)
    }

    // MARK: - 数据离线
    @IBAction func OnlineInfoOffline(sender: AnyObject) {
        self.onlineInfoDetailVM.infoOffline()
    }
    
    /**
    新闻离线成功时的提示
    */
    func showOfflineOnlineInfoSuccess() {
        TopAlert().createBaseTopAlert(MozAlertTypeSuccess, alertInfo: "离线成功", parentView: self.view)
    }
    
    // MARK: - DTAttributedTextContentViewDelegate
    /**
    用来 跳转超链接
    */
    func attributedTextContentView(attributedTextContentView: DTAttributedTextContentView!, viewForLink url: NSURL!, identifier: String!, frame: CGRect) -> UIView! {
        let linkButton: DTLinkButton = DTLinkButton(frame: frame)
        linkButton.URL = url
        
        // get image with normal link text
        let normalImage: UIImage = attributedTextContentView.contentImageWithBounds(frame, options: DTCoreTextLayoutFrameDrawingOptions.Default)
        linkButton.setImage(normalImage, forState: UIControlState.Normal)
        
        // get image for highlighted link text
        let highlightImage: UIImage = attributedTextContentView.contentImageWithBounds(frame, options: DTCoreTextLayoutFrameDrawingOptions.DrawLinksHighlighted)
        linkButton.setImage(highlightImage, forState: UIControlState.Highlighted)

        linkButton.addTarget(self, action: "linkButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        return linkButton
    }

    @IBAction func linkButtonClicked(sender: DTLinkButton) {
        UIApplication.sharedApplication().openURL(sender.URL)
    }
    
    /**
    加载 html 中的图片
    */
    func attributedTextContentView(attributedTextContentView: DTAttributedTextContentView!, viewForAttachment attachment: DTTextAttachment!, frame: CGRect) -> UIView! {
        if attachment.isKindOfClass(DTImageTextAttachment.self) {
            let dtImageView: DTLazyImageView = DTLazyImageView(frame: frame)
            dtImageView.delegate = self
            // sets the image if there is one
            dtImageView.image = (attachment as! DTImageTextAttachment).image
            // url for deferred loading
            dtImageView.url = attachment.contentURL
            // if there is a hyperlink then add a link button on top of this image
            if (attachment.hyperLinkURL != nil) {
                dtImageView.userInteractionEnabled = true
                let linkButton: DTLinkButton = DTLinkButton(frame: frame)
                linkButton.URL = attachment.hyperLinkURL
                // adjusts it's bounds so that button is always large enough
                linkButton.minimumHitSize = CGSizeMake(25, 25)
                linkButton.GUID = attachment.hyperLinkGUID

                // demonstrate combination with long press
                let longPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "linkLongPressed:")
                linkButton.addGestureRecognizer(longPress)
                dtImageView.addSubview(linkButton)
            }
            return dtImageView
        }
        return nil
    }

    // 长按用 Safari 打开图片链接
    func linkLongPressed(gesture: UILongPressGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.Began {
            let button: DTLinkButton = gesture.view as! DTLinkButton
            button.highlighted = false
            
            button.URL.absoluteString.openURL()
          
//            if UIApplication.sharedApplication().canOpenURL(button.URL.absoluteURL!) {
//                UIApplication.sharedApplication().openURL(button.URL.absoluteURL!)
//            }
        }
    }
    
    // MARK: - DTLazyImageViewDelegate
    func lazyImageView(lazyImageView: DTLazyImageView!, didChangeImageSize size: CGSize) {
        let url: NSURL = lazyImageView.url
        let imageSize = size
        let pred: NSPredicate! = NSPredicate(format: "contentURL == %@", url)
        
        var didUpdate: Bool = false
        let textAttachmentsWithPredicates = self.onlineInfoContextATextView.attributedTextContentView.layoutFrame.textAttachmentsWithPredicate(pred) as! [DTTextAttachment]
        
        // update all attachments that matchin this URL (possibly multiple images with same size)
        for oneAttachment: DTTextAttachment in textAttachmentsWithPredicates {
            if CGSizeEqualToSize(oneAttachment.originalSize, CGSizeZero) {
                // update attachments that have no original size, that also sets the display size
                oneAttachment.originalSize = imageSize
                didUpdate = true
            }
        }
        
        if didUpdate {
            // layout might have changed due to image sizes
            self.onlineInfoContextATextView.relayoutText()
        }
    }
}
