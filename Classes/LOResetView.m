
#import <UIKit/UIKit.h>

#import "LOResetView.h"

#import "LOController.h"

@implementation LOResetView


#pragma mark UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    pressed = YES;
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    pressed = NO;
    [self setNeedsDisplay];
    
    [[self superview] reset];
}

#pragma mark UIView

- (void)drawRect:(CGRect)rect;
{
    if (!pressed) {
        static UIImage *resetImage;
        if (!resetImage)
            resetImage = [[UIImage imageNamed:@"lo-button-reset.png"] retain];
        [resetImage drawInRect:rect];
    } else {
        static UIImage *resetPressedImage;
        if (!resetPressedImage)
            resetPressedImage = [[UIImage imageNamed:@"lo-button-reset-press.png"] retain];
        [resetPressedImage drawInRect:rect];
    }
}

@end
