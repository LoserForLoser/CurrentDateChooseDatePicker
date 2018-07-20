//
//  ChooseDatePickerView.h
//  MotherPlanet
//
//  Created by Coder on 2018/6/4.
//  Copyright © 2018年 Geek Zoo Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChooseDatePickerViewDelegate <NSObject>

- (void)finishSelectDate:(NSDate *)date;

@end

@interface ChooseDatePickerView : UIView

@property (nonatomic, assign) id data;

@property (nonatomic, weak) id <ChooseDatePickerViewDelegate>delegate;

- (void)show;

- (void)hide;

@end
