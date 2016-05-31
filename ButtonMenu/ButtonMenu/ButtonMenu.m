//
//  ButtonMenu.m
//  ButtonMenu
//
//  Created by sherry on 16/5/26.
//  Copyright © 2016年 sherry. All rights reserved.
//

#import "ButtonMenu.h"
#import "BundleTools.h"

#define LOGOWIDTH 64
#define LOGOHEIGHT 64

//用于标注按钮最终移动位置的枚举
typedef NS_ENUM (NSUInteger, SDLocationTag) {
    
    SDLocationTag_Top = 1,
    SDLocationTag_Left,
    SDLocationTag_Bottom,
    SDLocationTag_Right
};

@interface ButtonMenu ()
{
    UIImageView * _buttonViewImage;//浮动按钮的图标
    UIView * _buttonViewMune;//弹出的目录
    
    UIButton * _userBtn;
    UIButton * _packageBtn;
    UIButton * _helpBtn;
    
    BOOL _isShowMenu;//是否展示菜单
    BOOL _isLeftView;//是否在左半边
    BOOL _isLogoMoving;//logo 是否在移动
    
    SDLocationTag _locationTag;
    float X;
    float Y;
    
    BOOL _isFirst;//是否第一次存储
    float _height;
    float _SD_Y;
}
@end

@implementation ButtonMenu

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, 68, 68)];
    
    if (self) {
        
        _isLeftView = frame.origin.x <= [self superview].frame.size.width / 2;
        
        [self createUI];
        
        [self setNotificationOfDeviceOrientation];
    }
    
    return self;
}

//创建 UI
- (void)createUI{
    
    _isShowMenu = NO;
    
    X = self.center.x;
    Y = self.center.y;
    
    _buttonViewImage = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, LOGOWIDTH, LOGOHEIGHT)];
    
    [self setButtonImageWithIsChick:NO];
    
    //创建目录条
    _buttonViewMune = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 68)];
    
    [_buttonViewMune setClipsToBounds:YES];
    
    [_buttonViewMune setHidden:YES];
    
    UIImageView * menuImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 308, 68)];
    
    UIImage * image = [UIImage imageWithContentsOfFile:[BundleTools getBundlePath:@"fillet"]];
    
    [menuImage setImage:image];
    
    [_buttonViewMune addSubview:menuImage];

    [self addSubview:_buttonViewMune];
    [self addSubview:_buttonViewImage];
    
    [self addButtonForMenu];
    
}

//设置屏幕旋转的通知
- (void)setNotificationOfDeviceOrientation{
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
}

//根据按钮是否被点击设置其图片
- (void)setButtonImageWithIsChick:(BOOL)isChick{
    
    NSString * picName = nil;
    
    if (!isChick) {
        picName = [BundleTools getBundlePath:@"teamtop_logo"];
    } else {
        if (_isLeftView) {
            picName = [BundleTools getBundlePath:@"left"];
        } else {
            picName = [BundleTools getBundlePath:@"right"];
        }
    }

    UIImage * image = [UIImage imageWithContentsOfFile:picName];
    
    [_buttonViewImage setImage:image];
    
}

#pragma mark 触摸事件
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    _isLogoMoving = NO;//logo 没有移动
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if (_isShowMenu) {
        
        return;
        
    }
    
    _isLogoMoving = YES;//logo 在移动
    
    UITouch * touch = [touches anyObject];
    
    CGPoint move = [touch locationInView:[self superview]];
    
    //防止移动出界
    if (move.x - LOGOWIDTH/2 < 0.f ||
        move.x + LOGOWIDTH/2 > [self superview].frame.size.width ||
        move.y - LOGOHEIGHT/2 < 20.f ||
        move.y + LOGOHEIGHT/2 > [self superview].frame.size.height)
    {
        return;
    }
    
    [self setCenter:move];

    _isLeftView = self.frame.origin.x < ([self superview].frame.size.width - LOGOWIDTH / 2) / 2;
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
 
    if (_isLogoMoving == NO) {
        
        //如果没有显示
        [self setButtonImageWithIsChick:!_isShowMenu];
    }
    
    if (!_isLogoMoving) {
        
        _isShowMenu = !_isShowMenu;
        
        [self showMenu:_isShowMenu time:0.3];
        
        return;
    }
    
    [self computeOfLocation:^{
        
        [self setButtonImageWithIsChick:NO];
        
        _isLogoMoving = NO;
    }];
}

#pragma mark 是否弹出目录及自动附着边界
//是否弹出
- (void)showMenu:(BOOL)isShow time:(float)time{
    
    self.userInteractionEnabled = NO;//弹出后关闭触摸事件
    
    [self setButtonX];
    
    if (isShow) {
        //弹出
        [_buttonViewMune setHidden:NO];
        //在左边
        if (self.frame.origin.x == 0) {
            
            [UIView animateWithDuration:time animations:^{
                
                [_buttonViewMune setFrame:CGRectMake(0, 0, 308, 68)];
                
                [self setFrame:CGRectMake(X - 34, Y - 34, 308, 68)];
                
            } completion:^(BOOL finished) {
                
                self.userInteractionEnabled = YES;
                
            }];

        } else {
            
            [UIView animateWithDuration:time animations:^{
                
                [_buttonViewMune setFrame:CGRectMake(0, 0, 308, 68)];
                
                [self setFrame:CGRectMake(X - 34 - 240, Y - 34, 308, 68)];
                
                [_buttonViewImage setFrame:CGRectMake( 242, 2, LOGOWIDTH, LOGOHEIGHT)];
                
            } completion:^(BOOL finished) {
                
                self.userInteractionEnabled = YES;
            }];
 
        }
    } else {//关闭
        
        [self setButtonImageWithIsChick:NO];
        
        if (self.frame.origin.x == 0) {
            
            [UIView animateWithDuration:time animations:^{
                
                [_buttonViewMune setFrame:CGRectMake(0, 0, 0, 68)];
                
                [self setFrame:CGRectMake(X - 34, Y - 34, 68, 68)];
                
            } completion:^(BOOL finished) {
                
                    self.userInteractionEnabled = YES;
                    [_buttonViewMune setHidden:YES];
                
            }];

        } else {
            
                [UIView animateWithDuration:time animations:^{
                    
                    [_buttonViewMune setFrame:CGRectMake(34, 0, 0, 68)];

                    [self setFrame:CGRectMake(X - 34, Y - 34, 68, 68)];
                        
                    [_buttonViewImage setFrame:CGRectMake(2, 2, LOGOWIDTH, LOGOHEIGHT)];
                
            } completion:^(BOOL finished) {
                
                    self.userInteractionEnabled = YES;
                    [_buttonViewMune setHidden:YES];
                
            }];

        }
    }
}
//自动附着边界
- (void)computeOfLocation:(void(^)())complete{
    
    float x = self.center.x;
    float y = self.center.y;
    float w = self.frame.size.width;
    float h = self.frame.size.height;
    
    CGPoint s = CGPointZero;
    s.x = x;
    s.y = y;
    
    float superWidth = [self superview].frame.size.width;
    float superHeight = [self  superview].frame.size.height;
    
    //判断在哪边(仅仅判断左右就可以)
    if (x < superWidth / 2) {
        
        _locationTag = SDLocationTag_Left;
        _isLeftView = YES;
        
    } else {
        
        _locationTag = SDLocationTag_Right;
        _isLeftView = NO;
    }
    
    switch (_locationTag) {
        case SDLocationTag_Top:
            s.y = 0 + w/2 + 20;
            break;
        case SDLocationTag_Left:
            s.x = 0 + h/2;
            break;
        case SDLocationTag_Bottom:
            s.y = superHeight - h / 2;
            break;
        case SDLocationTag_Right:
            s.x = superWidth - w / 2;
            break;
    }
    
    X = s.x;
    Y = s.y;
    
    [UIView animateWithDuration:0.1
                     animations:^{
                         
        [self setCenter:s];
                         
    }
                     completion:^(BOOL finished) {
        complete();
                         
    }];
}

#pragma mark 在目录条上添加按钮
- (void)addButtonForMenu{
    _userBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_userBtn setImage:[UIImage imageWithContentsOfFile:[BundleTools getBundlePath:@"user"]] forState:UIControlStateNormal];
    [_userBtn addTarget:self action:@selector(chickWithButton:) forControlEvents:UIControlEventTouchDown];
    [_buttonViewMune addSubview:_userBtn];
    
    _packageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_packageBtn setImage:[UIImage imageWithContentsOfFile:[BundleTools getBundlePath:@"package"]] forState:UIControlStateNormal];
    [_packageBtn addTarget:self action:@selector(chickWithButton:) forControlEvents:UIControlEventTouchDown];
    [_buttonViewMune addSubview:_packageBtn];
    
    _helpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_helpBtn setImage:[UIImage imageWithContentsOfFile:[BundleTools getBundlePath:@"help"]] forState:UIControlStateNormal];
    [_helpBtn addTarget:self action:@selector(chickWithButton:) forControlEvents:UIControlEventTouchDown];
    [_buttonViewMune addSubview:_helpBtn];
}

- (void)setButtonX{
    
    float S = 0;
    
    if (_isLeftView) {
        S = 68;
    } else {
        S = 15;
    }
    
    [_userBtn setFrame:CGRectMake(S + 15, 15, 30, 40)];
    [_packageBtn setFrame:CGRectMake(S + 95, 15, 30, 40)];
    [_helpBtn setFrame:CGRectMake(S + 175, 15, 30, 40)];
}

#pragma mark 按钮的点击事件
- (void)chickWithButton:(UIButton *)btn{
    if (btn == _userBtn) {
        NSLog(@"用户");
    } else if (btn == _packageBtn) {
        NSLog(@"礼包");
    } else if (btn == _helpBtn) {
        NSLog(@"帮助");
    }
}

#pragma mark 屏幕旋转的通知
- (void)deviceOrientationDidChange:(NSNotification *)notification{
    
    [self showMenu:NO time:0.3];
    
    //存储基础高
    if (!_isFirst) {
        _isFirst = !_isFirst;
        
        _height = [self superview].frame.size.height;
    }
    //储存Y对应的比例
    _SD_Y = _height / [self superview].frame.size.height;
    
    [self setNewOriginForView];
}

- (void)setNewOriginForView{
    //更改 Y 坐标
    Y = Y / _SD_Y;

    _height = [self superview].frame.size.height;

    //在右边时更改 X 坐标
    if (!_isLeftView) {

        X = [self superview].frame.size.width - 34;
        
    }
    //防止出界
    if ((Y + 34) > _height) {
        Y = _height - 34;
    }
    
    [self setCenter:CGPointMake(X, Y)];
    
}
@end
