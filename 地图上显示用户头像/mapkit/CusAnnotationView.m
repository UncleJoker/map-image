//
//  CusAnnotationView.m
//  mapkit
//
//  Created by zje on 15/9/8.
//  Copyright (c) 2015年 eamon. All rights reserved.
//

#import "CusAnnotationView.h"
#import "CustomCalloutView.h"

// 宏定义 尺寸
// 设置标签的宽和高
#define kWidth          60.f
#define kHeight         60.f

#define kHoriMargin     5.f
#define kVertMargin     5.f

#define kPortraitWidth  50.f
#define kPortraitHeight 50.f

// 设置弹出气泡的宽和高Callout
#define kCalloutWidth   200.0
#define kCalloutHeight  70.0

@implementation CusAnnotationView

// 自动生成getter和setter
@synthesize calloutView;
@synthesize portraitImageView   = _portraitImageView;


#pragma mark - Handle Action
// 聊天按钮响应事件
- (void)btnAction
{
    //    CLLocationCoordinate2D coorinate = [self.annotation coordinate];
    //    NSLog(@"coordinate = {%f, %f}", coorinate.latitude, coorinate.longitude);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"将会跳转到聊天界面" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    
}

// 昵称按钮响应事件
- (void)nameAction
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"将会跳转到用户资料界面" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    
}

// 旅程单按钮响应事件
- (void)travelButtonAction
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"将会跳转到旅程单界面" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    
}


#pragma mark - Override

- (UIImage *)portrait
{
    return self.portraitImageView.image;
}

- (void)setPortrait:(UIImage *)portrait
{
    self.portraitImageView.image = portrait;
}

- (void)setSelected:(BOOL)selected
{
    [self setSelected:selected animated:YES];
}

// 选择annonation执行的方法
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.selected == selected)
    {
        return;
    }
    
    if (selected)
    {
        if (self.calloutView == nil)
        {
            /* Construct custom callout. */
            // 创建气泡
            self.calloutView              = [[CustomCalloutView alloc] initWithFrame:CGRectMake(0, 0, kCalloutWidth, kCalloutHeight)];
            //            self.calloutView.alpha = 0.5;
            self.calloutView.center       = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + self.calloutOffset.x,
                                                        -CGRectGetHeight(self.calloutView.bounds) / 2.f + self.calloutOffset.y);
            
            
            // 聊天按钮,点击之后跳转到聊天界面
            self.btn      = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            _btn.frame                    = CGRectMake(10, 10, 40, 40);
            [_btn setTitle:@"聊天" forState:UIControlStateNormal];
            [_btn setBackgroundColor:[UIColor whiteColor]];
            [_btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
            
            // 设置按钮为圆
            //            _btn.layer.masksToBounds = YES;
            //            [_btn.layer setCornerRadius:CGRectGetHeight(self.btn.bounds) / 2];
            //            _btn.layer.borderColor = [[UIColor blackColor] CGColor];
            
            
            // 设置btn按钮的响应事件
            [_btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
            [self.calloutView addSubview:_btn];
            
            // 用户昵称按钮,点击之后跳转到用户资料界面
            UIButton *name                = [UIButton buttonWithType:(UIButtonTypeRoundedRect)];
            name.frame                    = CGRectMake(60, 8, 100, 20);
            [name setTitle:@"用户昵称" forState:UIControlStateNormal];
            name.titleLabel.textAlignment = NSTextAlignmentCenter;
            [name setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
            [name addTarget:self action:@selector(nameAction) forControlEvents:(UIControlEventTouchUpInside)];
            [self.calloutView addSubview:name];
            
            // 旅程单按钮,点击查看详细旅程单
            self.travelButton                      = [UIButton buttonWithType:(UIButtonTypeRoundedRect)];
            _travelButton.frame                    = CGRectMake(60, CGRectGetMinY(name.frame) + CGRectGetHeight(name.frame) + 3, 100, 20);
            [_travelButton setTitle:@"旅程单" forState:(UIControlStateNormal)];
            _travelButton.titleLabel.textAlignment = NSTextAlignmentCenter;
            [_travelButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
            [_travelButton addTarget:self action:@selector(travelButtonAction) forControlEvents:(UIControlEventTouchUpInside)];
            
            [self.calloutView addSubview:_travelButton];
            
        }
        // 设置动画效果
        CABasicAnimation *basicAnimation = [CABasicAnimation animation];
        // 缩放
        basicAnimation.keyPath      = @"transform.scale";
        basicAnimation.fromValue    = @0.1;
        basicAnimation.toValue      = @1.0;
        basicAnimation.duration     = 0.2f;
        // 添加动画效果
        [self.calloutView.layer addAnimation:basicAnimation forKey:@"key"];

        // 将calloutView添加到地图上
        [self addSubview:self.calloutView];
    }
    else
    {
        [self.calloutView removeFromSuperview];
    }
    
    [super setSelected:selected animated:YES];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL inside = [super pointInside:point withEvent:event];
    /* Points that lie outside the receiver’s bounds are never reported as hits,
     even if they actually lie within one of the receiver’s subviews.
     This can occur if the current view’s clipsToBounds property is set to NO and the affected subview extends beyond the view’s bounds.
     */
    if (!inside && self.selected)
    {
        inside = [self.calloutView pointInside:[self convertPoint:point toView:self.calloutView] withEvent:event];
    }
    
    return inside;
}

#pragma mark - Life Cycle
// 初始化自定义标签
- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self ) {
        self.bounds            = CGRectMake(0.f, 0.f, kWidth, kHeight);
        self.backgroundColor   = [UIColor clearColor];
        
        
        /* Create portrait image view and add to view hierarchy. */
        // 添加用户头像
        self.portraitImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kHoriMargin, kVertMargin, kPortraitWidth, kPortraitHeight)];
        
        // 设置头像为圆
        [self.portraitImageView.layer setCornerRadius:CGRectGetHeight([self.portraitImageView bounds]) / 2];
        self.portraitImageView.layer.masksToBounds = YES;
        self.portraitImageView.layer.borderWidth = 1;
        self.portraitImageView.layer.borderColor = [[UIColor blackColor] CGColor];
        
        [self animation];
        
        [self addSubview:self.portraitImageView];
    }
    return self;
}


// 设置动画效果方法
- (void)animation
{
    // 设置动画效果
    CABasicAnimation *basicAnimation = [CABasicAnimation animation];
    // 透明度
    basicAnimation.keyPath   = @"opacity";
    // 从哪个值变化到哪个值
    basicAnimation.fromValue = @0.0;
    basicAnimation.toValue   = @1.0;
    basicAnimation.duration  = arc4random() % 4;
    // 添加动画效果
    [self.layer addAnimation:basicAnimation forKey:@"key"];
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
