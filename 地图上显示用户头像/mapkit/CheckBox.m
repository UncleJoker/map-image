//
//  CheckBox.m
//  
//
//  Created by zje on 8/26/15.
//
//

#import "CheckBox.h"

@implementation CheckBox
@synthesize label,icon,delegate,paramCode,paramValue;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        icon                  = [[UIImageView alloc] initWithFrame:CGRectMake(4, 8, 20, 20)];
        [self setChecked:NO];
        [self addSubview:icon];
        label                 = [[UILabel alloc] initWithFrame:CGRectMake(icon.frame.size.width + 7, 0, frame.size.width-icon.frame.size.width - 10, frame.size.height)];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment   = NSTextAlignmentCenter;
        [self addSubview:label];
        [self addTarget:self action:@selector(clicked) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}
// 是否选择
-(BOOL)isChecked{
    return checked;
}

-(void)setChecked:(BOOL)flag{
    // 设置flag等于checked
    if (flag != checked) {
        checked = flag;
    }
    
    if (checked) {
        
        [icon setImage:[UIImage imageNamed:@"checkbox_pressed"]];
    }else{
        
        [icon setImage:[UIImage imageNamed:@"checkbox_normal"]];
    }
}

-(void)clicked
{
    [self setChecked:!checked];
    if (delegate != nil) {
        SEL sel = NSSelectorFromString(@"checkButtonClicked");
        if ([delegate respondsToSelector:sel]) {
            [delegate performSelector:sel withObject:nil afterDelay:0.0];
        }
    }
}

-(void)setValue:(NSString *)Value withCode:(NSString *)Code{
    NSCharacterSet *space = [NSCharacterSet whitespaceCharacterSet];
    NSString *trimmValue  = [Value stringByTrimmingCharactersInSet:space];
    NSString *trimmCode   = [Code stringByTrimmingCharactersInSet:space];
    if (trimmCode.length == 0 && trimmValue.length == 0) {
        return;
    }else{
        self.label.text = Value;
        self.paramCode  = Code;
        self.paramValue = Value;
    }
}

-(NSString *)getCode{
    return paramCode;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
