//
//  CusAnnotationView.h
//  mapkit
//
//  Created by zje on 15/9/8.
//  Copyright (c) 2015年 eamon. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface CusAnnotationView : MKAnnotationView

// 头像
@property (nonatomic, strong) UIImage          *portrait;
// 气泡
@property (nonatomic, strong) UIView           *calloutView;
// 切换显示方式按钮
@property (nonatomic, strong) UIButton         *changeButton;

// 用户头像
@property (nonatomic, strong) UIImageView      *portraitImageView;
// 用户昵称按钮
@property (nonatomic,strong ) UIButton         *nameButton;
// 旅程单按钮
@property (nonatomic,strong ) UIButton         *travelButton;
// 聊天按钮
@property (nonatomic,strong ) UIButton         *btn;

@end
