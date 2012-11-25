//
//  UIFont+Additionals.m
//  learnEverything
//
//  Created by Yuanfeng on 12-06-25.
//  Copyright (c) 2012 ____Yuanfeng Gao___. All rights reserved.
//

#import "UIFont+Additionals.h"

@implementation UIFont (Additionals)

+ (UIFont*)regularChineseFontWithSize:(CGFloat)size
{
    return [UIFont systemFontOfSize:size];//[UIFont fontWithName:@"MyriadPro-Regular" size:size]; //@"FZZhiYi-M12S" //TODO
}

@end
