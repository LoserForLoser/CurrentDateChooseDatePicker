//
//  ChooseDatePickerView.m
//  MotherPlanet
//
//  Created by Coder on 2018/6/4.
//  Copyright © 2018年 Geek Zoo Studio. All rights reserved.
//

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenRect [UIScreen mainScreen].bounds

#import "ChooseDatePickerView.h"

@interface ChooseDatePickerView ()<UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate>

{
    NSInteger yearIndex;
    NSInteger monthIndex;
    NSInteger dayIndex;
}

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIView *basicView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *datePicker;

@property (nonatomic, strong) NSDateComponents *comp;
@property (nonatomic, strong) NSMutableArray *yearArray;
@property (nonatomic, strong) NSMutableArray *monthArray;
@property (nonatomic, strong) NSMutableArray *dayArray;

@end

@implementation ChooseDatePickerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self = [[NSBundle mainBundle] loadNibNamed:@"ChooseDatePickerView" owner:self options:nil].lastObject;
    } return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleLabel.text = @"选择生日";
    
    NSCalendar *calendar = [[NSCalendar alloc]
                            initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    // 定义一个时间字段的旗标，指定将会获取指定年、月、日、时、分、秒的信息
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour |  NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday;
    // 获取不同时间字段的信息
    self.comp = [calendar components: unitFlags fromDate:[NSDate date]];
    
    yearIndex = [self.yearArray indexOfObject:[NSString stringWithFormat:@"%ld年", self.comp.year]];
    monthIndex = [self.monthArray indexOfObject:[NSString stringWithFormat:@"%02ld月", self.comp.month]];
    dayIndex = [self.dayArray indexOfObject:[NSString stringWithFormat:@"%02ld日", self.comp.day]];
    
    [self selectActionToPickerView:self.datePicker row:yearIndex inComponent:0];
    [self selectActionToPickerView:self.datePicker row:monthIndex inComponent:1];
    [self selectActionToPickerView:self.datePicker row:dayIndex inComponent:2];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
}

#pragma mark - Date Data

- (void)setData:(id)data {
    _data = data;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:[dateFormatter stringFromDate:data]];
    NSDate *dataToDate = date;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dataToComp = [gregorian components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:dataToDate];
    
    yearIndex = [self.yearArray indexOfObject:[NSString stringWithFormat:@"%ld年", dataToComp.year]];
    monthIndex = [self.monthArray indexOfObject:[NSString stringWithFormat:@"%02ld月", dataToComp.month]];
    dayIndex = [self.dayArray indexOfObject:[NSString stringWithFormat:@"%02ld日", dataToComp.day]];
    
    [self selectActionToPickerView:self.datePicker row:yearIndex inComponent:0];
    [self selectActionToPickerView:self.datePicker row:monthIndex inComponent:1];
    [self selectActionToPickerView:self.datePicker row:dayIndex inComponent:2];
}

- (NSMutableArray *)yearArray {
    if (_yearArray == nil) {
        _yearArray = [NSMutableArray array];
        for (int year = 1950; year <= self.comp.year; year++) {
            NSString *str = [NSString stringWithFormat:@"%d年", year];
            [_yearArray addObject:str];
        }
    }
    return _yearArray;
}

- (NSMutableArray *)monthArray {
    if (_monthArray == nil) {
        _monthArray = [NSMutableArray array];
        for (int month = 1; month <= 12; month++) {
            NSString *str = [NSString stringWithFormat:@"%02d月", month];
            [_monthArray addObject:str];
        }
    }
    return _monthArray;
}

- (NSMutableArray *)dayArray {
    if (_dayArray == nil) {
        _dayArray = [NSMutableArray array];
        for (int day = 1; day <= 31; day++) {
            NSString *str = [NSString stringWithFormat:@"%02d日", day];
            [_dayArray addObject:str];
        }
    }
    return _dayArray;
}

#pragma mark UIPickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return self.yearArray.count;
    } else if(component == 1) {
        // 如果是今年返回当前已过月分数
        if ([self.yearArray[yearIndex] isEqualToString:self.yearArray.lastObject]) {
            return self.comp.month;
        }
        return self.monthArray.count;
    } else {
        // 如果是今年今月返回当前已过天数
        if ([self.yearArray[yearIndex] isEqualToString:self.yearArray.lastObject] && self.comp.month - 1 == monthIndex) {
            return self.comp.day;
        }
        switch (monthIndex + 1) {
            case 2:{
                NSString *pickerYear = ((UILabel *)[self.datePicker viewForRow:yearIndex forComponent:0]).text;
                // 需要考虑闰年闰月情况
                if ([self isleapYear:[pickerYear integerValue]]) {
                    return 29;
                } else {
                    return 28;
                }
            }
            case 4:
            case 6:
            case 9:
            case 11:
                return 30;
            default:
                return 31;
        }
    }
}

#pragma mark - UIPickerView Delegate

// 滚动UIPickerView就会调用
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        yearIndex = row;
        // 重新加载确保是当前年月时不出现多余可选范围
        [pickerView reloadComponent:1];
        [pickerView reloadComponent:2];
        // 选择年份时月日超出今日日期则自动滚到今天
        if ([self.yearArray[row] isEqualToString:self.yearArray.lastObject]) {
            if (self.comp.month - 1 < monthIndex) {
                monthIndex = self.comp.month - 1;
                [self selectActionToPickerView:pickerView row:monthIndex inComponent:1];
                
                dayIndex = self.comp.day - 1;
                [self selectActionToPickerView:pickerView row:dayIndex inComponent:2];
            }
            
            if (self.comp.month - 1 == monthIndex && self.comp.day - 1 < dayIndex) {
                dayIndex = self.comp.day - 1;
                [self selectActionToPickerView:pickerView row:dayIndex inComponent:2];
            }
        }
    } else if (component == 1) {
        monthIndex = row;
        // 重新加载确保是当前年月时不出现多余可选范围
        [pickerView reloadComponent:2];
        if (monthIndex + 1 == 4 || monthIndex + 1 == 6 || monthIndex + 1 == 9 || monthIndex + 1 == 11) {
            if (dayIndex + 1 == 31) {
                dayIndex--;
            }
        } else if (monthIndex + 1 == 2) {
            if (dayIndex + 1 > 28) {
                dayIndex = 27;
            }
        }
        // 选择月份时月日超出今日日期则自动滚到今天
        NSString *pickerYear = ((UILabel *)[pickerView viewForRow:yearIndex forComponent:0]).text;
        if ([pickerYear isEqualToString:self.yearArray.lastObject] && self.comp.month - 1 < monthIndex) {
            monthIndex = self.comp.month - 1;
            dayIndex = self.comp.day - 1;
            [self selectActionToPickerView:pickerView row:monthIndex inComponent:1];
            [self selectActionToPickerView:pickerView row:dayIndex inComponent:2];
        }
        
        [pickerView selectRow:dayIndex inComponent:2 animated:YES];
    } else {
        dayIndex = row;
        // 选择日期时超出今日日期则自动滚到今天
        NSString *pickerYear = ((UILabel *)[pickerView viewForRow:yearIndex forComponent:0]).text;
        NSString *pickerMonth = ((UILabel *)[pickerView viewForRow:monthIndex forComponent:1]).text;
        if ([pickerYear isEqualToString:self.yearArray.lastObject] && [pickerMonth isEqualToString:self.monthArray[self.comp.month - 1]] && self.comp.day - 1 < dayIndex) {
            dayIndex = self.comp.day - 1;
            [self selectActionToPickerView:pickerView row:dayIndex inComponent:2];
        }
        [pickerView selectRow:dayIndex inComponent:2 animated:YES];
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    //设置文字的属性
    UILabel *genderLabel = [[UILabel alloc] init];
    genderLabel.textAlignment = NSTextAlignmentCenter;
    if (component == 0) {
        genderLabel.text = self.yearArray[row];
    } else if (component == 1) {
        genderLabel.text = self.monthArray[row];
    } else {
        genderLabel.text = self.dayArray[row];
    }
    return genderLabel;
}

- (void)selectActionToPickerView:(UIPickerView *)pickerView row:(NSInteger)row inComponent:(NSInteger)inComponent {
    [pickerView selectRow:row inComponent:inComponent animated:YES];
    [self pickerView:pickerView didSelectRow:row inComponent:inComponent];
}

- (BOOL)isleapYear:(NSInteger)year {
    if ((year % 400) == 0) {
        return YES;
    } else if (((year % 100) != 0) && ((year % 4) == 0)) {
        return YES;
    }
    return NO;
}

#pragma mark - Animated

- (void)show {
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [self showActionAnimated];
}

- (void)hide {
    [self hideActionAnimated];
}

- (void)showActionAnimated {
    CATransform3D translate = CATransform3DMakeTranslation(0, kScreenHeight, 0); //平移
    self.basicView.layer.transform = translate;
    self.backButton.alpha = 0;
    
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:1.0 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        self.backButton.alpha = 0.5;
        self.basicView.layer.transform = CATransform3DIdentity;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideActionAnimated {
    CATransform3D translate = CATransform3DMakeTranslation(0, kScreenHeight, 0); //平移
    self.basicView.layer.transform = CATransform3DIdentity;
    self.backButton.alpha = 0.5;
    
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:1.0 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        self.backButton.alpha = 0;
        self.basicView.layer.transform = translate;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - Action

- (IBAction)cancelAction:(UIButton *)sender {
    [self hide];
}

- (IBAction)confirmAction:(UIButton *)sender {
    NSString *pickerYear = ((UILabel *)[self.datePicker viewForRow:yearIndex forComponent:0]).text;
    NSString *pickerMonth = ((UILabel *)[self.datePicker viewForRow:monthIndex forComponent:1]).text;
    NSString *pickerDay = ((UILabel *)[self.datePicker viewForRow:dayIndex forComponent:2]).text;
    NSString *timeStr = [NSString stringWithFormat:@"%@%@%@", pickerYear, pickerMonth, pickerDay];
    timeStr = [timeStr stringByReplacingOccurrencesOfString:@"年" withString:@"/"];
    timeStr = [timeStr stringByReplacingOccurrencesOfString:@"月" withString:@"/"];
    timeStr = [timeStr stringByReplacingOccurrencesOfString:@"日" withString:@""];
    NSLog(@"timeStr:%@", timeStr);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:8];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat: @"yyyy/M/d"];

    NSDate *finalDate = [formatter dateFromString:timeStr];
    if ([self.delegate respondsToSelector:@selector(finishSelectDate:)]) {
        [self.delegate finishSelectDate:finalDate];
    }
    [self hide];
}

@end
