//
//  MenuViewModel.swift
//  CNBlogsClient
//
//  Created by 王焕强 on 15/5/31.
//  Copyright (c) 2015年 &#29579;&#28949;&#24378;. All rights reserved.
//

import UIKit

class MenuItem {
    var menuImageName:String = ""
    var menuTitle:String = ""
    var menuNextVC:UIViewController = UIViewController()
    
    init(imageName: String, title: String) {
        self.menuImageName = imageName
        self.menuTitle     = title
    }
}

class MenuViewModel: NSObject {
    var menuViewController: MenuViewController!
    var menuKeys = ["推荐阅读", "我的资讯", "设置"]
    var menuItems:Dictionary<String, [MenuItem]>!
    
    var bloggerSelf: Blogger = Blogger()
    
    override init() {
        super.init()
        
        self.setMenuItem()
        self.bloggerSelf = self.gainBloggerInfo()
    }
    
    // 设置菜单项
    func setMenuItem() {
        let newsItem        = MenuItem(imageName: "menuNews", title: "最新新闻")
        newsItem.menuNextVC = self.gainVCInStoryBoard("NewsViewController") as! NewsViewController
        
        let blogItem        = MenuItem(imageName: "menuBlog", title: "热门博客")
        blogItem.menuNextVC = self.gainVCInStoryBoard("BlogViewController") as! BlogViewController
        
        let myBlogItem      = MenuItem(imageName: "menuMyBlog", title: "我的博客")
        myBlogItem.menuNextVC = self.gainVCInStoryBoard("BlogOfBloggerViewController") as! BlogOfBloggerViewController        
        
        let myAttentionItem = MenuItem(imageName: "menuMyAttention", title: "我的关注人")
        myAttentionItem.menuNextVC = self.gainVCInStoryBoard("MyAttentionerViewController") as! MyAttentionerViewController
        
        let myOfflineInfo   = MenuItem(imageName: "menuMyOffline", title: "我的离线")
        myOfflineInfo.menuNextVC = self.gainVCInStoryBoard("OfflineInfoViewController") as! OfflineInfoViewController
        
        let settingItem     = MenuItem(imageName: "menuSetting", title: "设置")
        settingItem.menuNextVC = self.gainVCInStoryBoard("SettingTableViewController") as! SettingTableViewController
        
        menuItems = ["推荐阅读": [newsItem, blogItem],
            "我的资讯": [myBlogItem, myAttentionItem, myOfflineInfo],
            "设置": [settingItem]];
    }
    
    // 获取主StoryBoard里的视图
    func gainVCInStoryBoard(vcId: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(vcId) 
    }
    
    // 获取博主数据
    func gainBloggerInfo() ->Blogger {
        var blogger: Blogger = BloggerOwned()
        if blogger.isLoginSelf() {
            blogger = blogger.gainBloggerSelfInfo()
        }
        return blogger
    }
    
    // 获取博主头像
    func gainBloggerIcon() ->UIImage {
        var img = UIImage(named: "userIcon")
        if bloggerSelf.isLoginSelf() {
            img = bloggerSelf.gainIconFromDick()
        }
        return img!
    }
    
    // 获取博主名称
    func gainBloggerName() ->String {
        if bloggerSelf.isLoginSelf() {
            return bloggerSelf.bloggerName
        }else {
            return "尚未设置博主"
        }
    }
}
