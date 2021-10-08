//
//  ViewController.m
//  计算器
//
//  Created by 张佳乔 on 2021/9/27.
//

#import "ViewController.h"
#import "Model.h"
#import "View.h"

#define calculatorWidth [UIScreen mainScreen].bounds.size.width
#define calculatorHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()

@property (nonatomic, strong) View *calculatorView;
@property (nonatomic, strong) Model *calculatorModel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addUI];
}

- (void)addUI {

    self.calculatorModel = [[Model alloc] init];
    [self.calculatorModel modelInit];
    
    self.calculatorView = [[View alloc] initWithFrame:CGRectMake(0, 0, calculatorWidth, calculatorHeight)];
    [self.view addSubview:self.calculatorView];
}

@end
