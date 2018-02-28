
#import "LOInfoButtonView.h"

#import "LOController.h"
#import "LOView.h"

@implementation LOInfoButtonView


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
    
    [[self superview] showInfo];
}

#pragma mark UIView

- (void)drawRect:(CGRect)rect;
{
    if (!pressed) {
        static UIImage *infoButtonImage;
        if (!infoButtonImage)
            infoButtonImage = [[UIImage imageNamed:@"lo-button-info.png"] retain];
        [infoButtonImage drawInRect:rect];
    } else {
        static UIImage *infoButtonPressedImage;
        if (!infoButtonPressedImage)
            infoButtonPressedImage = [[UIImage imageNamed:@"lo-button-info-press.png"] retain];
        [infoButtonPressedImage drawInRect:rect];
    }
}

@end
