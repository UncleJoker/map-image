//
//  CheckBox.h
//
//
//  Created by zje on 8/26/15.
//
//

#import <UIKit/UIKit.h>

@interface CheckBox : UIControl{
    UILabel *label;
    UIImageView *icon;
    BOOL checked;
    id delegate;
    NSString *paramCode;
    NSString *paramValue;
}

@property (nonatomic,retain) id          delegate;
@property (nonatomic,retain) UILabel     *label;
@property (nonatomic,retain) UIImageView *icon;
@property (nonatomic,retain) NSString    *paramCode;
@property (nonatomic,retain) NSString    *paramValue;

-(BOOL)isChecked;
-(void)setChecked:(BOOL)flag;
//显示内容和实际Value
-(void)setValue:(NSString *)Value withCode:(NSString *)Code;
//返回实际Value
-(NSString *)getCode;


@end
