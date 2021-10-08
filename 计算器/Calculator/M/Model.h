//
//  Model.h
//  计算器
//
//  Created by 张佳乔 on 2021/9/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Model : NSObject

@property (nonatomic, strong) NSMutableString *showString;

- (void)modelInit;
- (NSMutableArray*)middleChangeBehind:(NSMutableString*)string;

@end

NS_ASSUME_NONNULL_END
