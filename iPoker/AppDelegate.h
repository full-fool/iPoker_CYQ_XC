//
//  AppDelegate.h
//  iPoker
//
//  Created by 崔 逸卿 on 14-8-13.
//  Copyright (c) 2014年 pku. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    NSString *nickName;
    NSString *IPAddress;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) NSString  *nickName;
@property (nonatomic, retain) NSString  *IPAddress;
@end
