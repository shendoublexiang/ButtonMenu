//
//  BundleTools.m
//  ButtonMenu
//
//  Created by sherry on 16/5/26.
//  Copyright © 2016年 sherry. All rights reserved.
//

#import "BundleTools.h"

@implementation BundleTools

+ (NSBundle *)getBundle{
    
    return [NSBundle bundleWithPath: [[NSBundle mainBundle] pathForResource: BUNDLE_NAME ofType: @"bundle"]];
}

+ (NSString *)getBundlePath: (NSString *) imageName{
    
    NSBundle *myBundle = [BundleTools getBundle];
    
    if (myBundle && imageName) {
        
        return [[myBundle resourcePath] stringByAppendingPathComponent: imageName];
    }
    
    return nil;
}

@end


