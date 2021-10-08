//
//  View.m
//  计算器
//
//  Created by 张佳乔 on 2021/9/27.
//

#import "View.h"
//#include <stdio.h>
//#include <string.h>

#define calculatorWidth [UIScreen mainScreen].bounds.size.width
#define calculatorHeight [UIScreen mainScreen].bounds.size.height

@implementation View

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    self.backgroundColor = [UIColor blackColor];
    
    self.search = 0;
    self.buttonArray = [[NSArray alloc] initWithObjects:@"AC", @"(", @")", @"/", @"7", @"8", @"9", @"*", @"4", @"5", @"6", @"-", @"1", @"2", @"3", @"+", @"0", @".", @"=", nil];
    self.showString = [[NSMutableString alloc] init];
    
    self.showLabel = [[UILabel alloc] init];
    self.showLabel.textColor = [UIColor whiteColor];
    self.showLabel.font = [UIFont systemFontOfSize:66];
    self.showLabel.textAlignment = NSTextAlignmentRight;
    self.showLabel.numberOfLines = 0;
    [self addSubview:self.showLabel];
    [self.showLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(0);
        make.left.equalTo(self).offset(0);
        make.width.offset(calculatorWidth);
        make.height.offset(300);
    }];
    
    self.allFlag = 1;
    
    NSInteger sum = 0;
    for (int i = 0; i < 5; i++) {
        for (int j = 0; j < 4; j++) {
            self.button = [UIButton buttonWithType:UIButtonTypeCustom];
            if (i == 0 && j != 3) {
                self.button.backgroundColor = [UIColor systemGray2Color];
            } else if (j == 3) {
                self.button.backgroundColor = [UIColor orangeColor];
            } else {
                self.button.backgroundColor = [UIColor grayColor];
            }
            [self.button setTitle:self.buttonArray[sum] forState:UIControlStateNormal];
            self.button.titleLabel.font = [UIFont systemFontOfSize:38];
            self.button.layer.cornerRadius = 43;
            self.button.tag = 1000 + sum;
            [self.button addTarget:self action:@selector(pressButton:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.button];
            if (i == 4 && j == 0) {
                [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self).offset(300 + (calculatorHeight - 300) / 5 * i);
                    make.left.equalTo(self).offset(10 + calculatorWidth / 4 * j );
                    make.height.offset(calculatorWidth / 4 - 20);
                    make.width.offset((calculatorWidth / 4 - 10) * 2);
                }];
                j++;
                sum++;
                continue;
            }
            [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self).offset(300 + (calculatorHeight - 300) / 5 * i);
                make.left.equalTo(self).offset(10 + calculatorWidth / 4 * j );
                make.width.and.height.offset(calculatorWidth / 4 - 20);
            }];
            sum++;
        }
    }
    
    return self;
}

- (void)pressButton:(UIButton*)button {
    if (button.tag == 1000) {
        self.showString = [[NSMutableString alloc] init];
        self.showLabel.text = self.showString;
        self.search = 0;
        self.allFlag = 1;
    } else if (button.tag == 1018) {
        [self.showString appendString:@"="];
        self.allFlag = 1;
        [self endShow];
    } else {
        if (self.allFlag) {
            self.allFlag = 0;
            self.showString = [[NSMutableString alloc] init];
            self.search = 0;
        }
        [self.showString appendString:self.buttonArray[button.tag - 1000]];
        self.showLabel.text = self.showString;
    }
}

- (void)endShow {
    
    //转成char*
    const char *str = [self.showString UTF8String];
    NSInteger length = (int)strlen(str);
    
    if (Compare(str[0]) == 3) {
        self.showString = [[NSMutableString alloc] initWithString:@"输入错误"];
        self.showLabel.text = self.showString;
        return;
    }
    
    NSInteger x = 0;
    NSInteger flag = -1;
    NSInteger i = 0;
    
    //存储转化完成的结果
    NSMutableArray *allArray = [[NSMutableArray alloc] init];
    
    while (i < length) {
        if (Compare(str[i]) == -1) {
            x = x * 10 + (str[i++] - '0');
            flag = 1;
        } else {
            if (flag == 1) {
                [allArray addObject:[NSString stringWithFormat:@"%ld", x]];
                x = 0;
                flag = -1;
            }
            [allArray addObject:[NSString stringWithFormat:@"%c", str[i]]];
            i++;
        }
    }
    
    //判断多余的'.'
    //计算可变数组的长度
    NSInteger newLength = 0;
    while (![allArray[newLength] isEqualToString:@"="]) {
        newLength++;
    }
    i = 0;
    NSInteger sum = 0;
    while (i < newLength) {
        if ([allArray[i] isEqualToString:@"."]) {
            sum++;
        }
        if (OCCompare(allArray[i]) == 1 || OCCompare(allArray[i]) == 2) {
            sum = 0;
        }
        if (sum > 1) {
            self.showString = [[NSMutableString alloc] initWithString:@"输入错误"];
            self.showLabel.text = self.showString;
            return;
        }
        i++;
    }
    
    //将字符串转成OC的数组
    NSMutableArray *floatArray = [[NSMutableArray alloc] init];
    floatArray = changeFloat(allArray);
    
    //判断，改变search值
    [self checkErrors:floatArray];
    
    if (self.search) {
        self.showString = [[NSMutableString alloc] initWithString:@"输入错误"];
        self.showLabel.text = self.showString;
    } else {
        //中转后
        NSMutableArray *behindArray = [[NSMutableArray alloc] init];
        behindArray = changeBehind(floatArray);
        
        //计算得到的值
        float num = endCalculation(behindArray);
        
        float cool = (num - (int)num) * 1000000;
        
        if (!cool) {
            int a = (int)num;
            self.showString = [[NSMutableString alloc] initWithFormat:@"%d", a];
            self.showLabel.text = self.showString;
        } else {
            self.showString = [[NSMutableString alloc] initWithFormat:@"%f", num];
            while ([[self.showString substringFromIndex:self.showString.length - 1] isEqualToString: @"0"]) {
                [self.showString deleteCharactersInRange:NSMakeRange(self.showString.length - 1, 1)];
            }
            self.showLabel.text = self.showString;
        }
    }
}

- (void)checkErrors:(NSMutableArray *)floatArray {
    //计算可变数组的长度
    NSInteger length = 0;
    while (![floatArray[length] isEqualToString:@"="]) {
        length++;
    }
    
    //判断第一个是不是运算符
    if (OCCompare(floatArray[0]) == 1 || OCCompare(floatArray[0]) == 2) {
        self.search = 1;
        return;
    }
    
    //分母不为0
    NSInteger i = 0;
    while (i < length - 1) {
        if ([floatArray[i] isEqualToString:@"/"] && [floatArray[i + 1] isEqualToString:@"0"]) {
            self.search = 1;
            return;
        }
        i++;
    }
    
    //括号匹配
    NSMutableArray *symbolArray = [[NSMutableArray alloc] init];
    NSInteger symbolTop = -1;
    
    for (int i = 0; i < length; i++) {
        if ([floatArray[i] isEqualToString:@"("]) {
            [symbolArray addObject:@"("];
            symbolTop++;
        } else if ([floatArray[i] isEqualToString:@")"] && symbolTop != -1) {
            [symbolArray removeLastObject];
            symbolTop--;
        } else if ([floatArray[i] isEqualToString:@")"] && symbolTop == -1) {
            self.search = 1;
        } else if ([floatArray[i] isEqualToString:@"("] && [floatArray[i + 1] isEqualToString:@")"]) {
            self.search = 1;
            return;
        }
    }
    if (symbolTop != -1) {
        self.search = 1;
        return;
    }
    
    //运算符
    for (int i = 0; i < length - 1; i++) {
        if (OCCompare(floatArray[i]) < 4 && OCCompare(floatArray[i]) && OCCompare(floatArray[i + 1]) < 4 && OCCompare(floatArray[i + 1])) {
            self.search = 1;
            return;
        }
    }
}

//C的比较
int Compare(char str) {
    if (str == '=') {
        return 0;
    } else if (str == '+' || str == '-') {
        return 1;
    } else if (str == '*' || str == '/') {
        return 2;
    } else if (str == '(' || str == ')') {
        return 0;
    } else if (str == '.') {
        return 3;
    } else {
        return -1; //字母或者数字
    }
}

//给符号计算
float Calculation(NSMutableArray *transArray) {
    NSString *ch = [transArray lastObject];
    [transArray removeLastObject];
    
    float a = [[transArray lastObject] floatValue];
    [transArray removeLastObject];
    float b = [[transArray lastObject] floatValue];
    [transArray removeLastObject];
    
    if ([ch isEqualToString:@"+"]) {
        return a + b;
    } else if ([ch isEqualToString:@"-"]) {
        return a - b;
    } else if ([ch isEqualToString:@"*"]) {
        return a * b;
    } else if ([ch isEqualToString:@"/"]) {
        return a / b;
    } else { //有不能识别的符号
        return 0;
    }
}

//OC的比较
NSInteger OCCompare(NSString *str) {
    if ([str isEqualToString:@"+"] || [str isEqualToString:@"-"]) {
        return 1;
    } else if ([str isEqualToString:@"*"] || [str isEqualToString:@"/"]) {
        return 2;
    } else if ([str isEqualToString:@"("] || [str isEqualToString:@")"]) {
        return 4;
    } else if ([str isEqualToString:@"="]) {
        return 3;
    } else {
        return 0;
    }
}

//中缀转后缀
NSMutableArray* changeBehind(NSMutableArray *changeArray) {

    //计算可变数组的长度
    NSInteger length = 0;
    while (![changeArray[length] isEqualToString:@"="]) {
        length++;
    }
    
    //后缀
    NSMutableArray *behindArray = [[NSMutableArray alloc] init];
    
    //符号
    NSMutableArray *symbolArray = [[NSMutableArray alloc] init];
    NSInteger symbolTop = -1;
    
    NSInteger i = 0;

    while (i <= length) {
        if ([changeArray[i] isEqualToString:@"("]) {  //左括号就直接存入操作符栈
            [symbolArray addObject:changeArray[i]];
            i++;
            symbolTop++;
        } else if ([changeArray[i] isEqualToString:@")"]) {  //右括号就将括号中的内容逐一弹出存入后缀栈
            while (![symbolArray[symbolTop] isEqualToString:@"("]) {
                [behindArray addObject:symbolArray[symbolTop--]];
                [symbolArray removeLastObject];
            }
            [symbolArray removeLastObject];
            symbolTop--;
            i++;
        } else if (!OCCompare(changeArray[i])) { //数字就直接存入后缀栈
            if ([changeArray[i] isEqualToString:@"="]) {
                break;
            }
            [behindArray addObject:changeArray[i]];
            i++;
        } else {   //遇到操作符
            if ([changeArray[i] isEqualToString:@"="]) {
                while (symbolTop != -1) {
                    [behindArray addObject:symbolArray[symbolTop--]];
                    [symbolArray removeLastObject];
                }
            }
            if (symbolTop == -1 || OCCompare(symbolArray[symbolTop]) < OCCompare(changeArray[i]) || OCCompare(symbolArray[symbolTop]) == 4) {
                //操作符栈为空或者字符串中的操作符优先级大于操作符栈顶操作符的优先级就将该操作符压入操作符栈中
                [symbolArray addObject:changeArray[i]];
                i++;
                symbolTop++;
            } else {
                [behindArray addObject:symbolArray[symbolTop]];
                [symbolArray removeLastObject];
                symbolTop--;
            }
        }
    }
    [behindArray addObject:@"="];
    
    return behindArray;
}

//计算结果
float endCalculation(NSMutableArray *newArray) {
    //计算可变数组的长度
    NSInteger length = 0;
    while (![newArray[length] isEqualToString:@"="]) {
        length++;
    }
    
    //计算栈
    NSMutableArray *endArray = [[NSMutableArray alloc] init];
    NSInteger endTop = -1;
    
    int i = 0;
    while (i < length) {
        if ([newArray[i] isEqualToString:@"="]) {
            break;
        }
        if (!OCCompare(newArray[i])) {
            [endArray addObject:newArray[i]];
            endTop++;
            i++;
        } else {
            NSMutableArray *transArray = [[NSMutableArray alloc] init];
            
            [transArray addObject:endArray[endTop]];
            endTop--;
            [endArray removeLastObject];
            
            [transArray addObject:endArray[endTop]];
            endTop--;
            [endArray removeLastObject];
            
            [transArray addObject:newArray[i]];
            i++;
            
            float num = Calculation(transArray);
            [endArray addObject:[NSString stringWithFormat:@"%f", num]];
            endTop++;
        }
    }
    
    return [endArray[0] floatValue];
}

//转化成浮点数
NSMutableArray* changeFloat(NSMutableArray *changeArray) {
    //计算可变数组的长度
    NSInteger length = 0;
    while (![changeArray[length] isEqualToString:@"="]) {
        length++;
    }
        
    NSInteger i = 0;
    while (i < length) {
        if ([changeArray[i] isEqualToString:@"."]) {
            changeArray[i - 1] = [changeArray[i - 1] stringByAppendingString:@"."];
            [changeArray removeObjectAtIndex:i];
            length--;
            changeArray[i - 1] = [changeArray[i - 1] stringByAppendingString:changeArray[i]];
            [changeArray removeObjectAtIndex:i];
            length--;
        } else {
            i++;
        }
    }
    
    return changeArray;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
