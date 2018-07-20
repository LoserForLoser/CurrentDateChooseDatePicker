//
//  ViewController.m
//  ChooseDatePicker
//
//  Created by Coder on 2018/6/19.
//  Copyright © 2018年 Song. All rights reserved.
//

#import "ViewController.h"
#import "ChooseDatePickerView.h"

@interface ViewController () <ChooseDatePickerViewDelegate>

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) NSDate *selectDate;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setFrame:CGRectMake(0, 100, self.view.bounds.size.width, 100)];
    [self.button setTitle:@"2000-01-01" forState:UIControlStateNormal];
    [self.button setBackgroundColor:[UIColor blackColor]];
    [self.button addTarget:self action:@selector(setupChooseDatePickerView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
}

- (void)setupChooseDatePickerView:(UIButton *)sender {
    ChooseDatePickerView *chooseDataPicker = [[ChooseDatePickerView alloc] initWithFrame:self.view.bounds];
    chooseDataPicker.delegate = self;
    if (!self.selectDate) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *date = [dateFormatter dateFromString:self.button.titleLabel.text];
        self.selectDate = date;
    }
    chooseDataPicker.data = self.selectDate;
    [chooseDataPicker show];
}

#pragma mark - DatePickerViewDelegate

- (void)finishSelectDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    [self.button setTitle:[formatter stringFromDate:date] forState:UIControlStateNormal];
    self.selectDate = date;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
