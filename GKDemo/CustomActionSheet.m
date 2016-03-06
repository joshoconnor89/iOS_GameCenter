//
//  CustomActionSheet.m
//
//  Created by Gabriel Theodoropoulos
//  Copyright (c) 2014 Gabriel Theodoropoulos. All rights reserved.
//

#import "CustomActionSheet.h"

@interface CustomActionSheet()

@property (nonatomic, strong) UIActionSheet *actionSheet;

@property (nonatomic, strong) void(^completionHandler)(NSString *, NSInteger);

@end


@implementation CustomActionSheet

-(id)initWithTitle:(NSString *)title delegate:(id<UIActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...{
    
    self = [super init];
    if (self) {
        _actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                   delegate:self
                                          cancelButtonTitle:nil
                                     destructiveButtonTitle:destructiveButtonTitle
                                          otherButtonTitles:nil];
        
        va_list arguments;
        va_start(arguments, otherButtonTitles);
        NSString *currentButtonTitle = otherButtonTitles;
        while (currentButtonTitle != nil) {
            [_actionSheet addButtonWithTitle:currentButtonTitle];
            currentButtonTitle = va_arg(arguments, NSString *);
        }
        va_end(arguments);
        
        
        [_actionSheet addButtonWithTitle:cancelButtonTitle];
        [_actionSheet setCancelButtonIndex:_actionSheet.numberOfButtons - 1];

    }
    
    return self;
}


#pragma mark - Public method implementation

-(void)showInView:(UIView *)view withCompletionHandler:(void (^)(NSString *, int))handler{
    _completionHandler = handler;
    
    [_actionSheet showInView:view];
}


#pragma mark - UIActionSheet Delegate method implementation

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *buttonTitle = [_actionSheet buttonTitleAtIndex:buttonIndex];
    
    _completionHandler(buttonTitle, buttonIndex);
}

@end
