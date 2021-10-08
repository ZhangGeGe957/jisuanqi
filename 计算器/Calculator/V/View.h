//
//  View.h
//  计算器
//
//  Created by 张佳乔 on 2021/9/27.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"

NS_ASSUME_NONNULL_BEGIN

@interface View : UIView

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *showLabel;
@property (nonatomic, copy) NSArray *buttonArray;
@property (nonatomic, strong) NSMutableString *showString;
@property (nonatomic, assign) NSInteger allFlag;
@property (nonatomic, assign) NSInteger search;

@end

NS_ASSUME_NONNULL_END
