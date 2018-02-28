
#import "LODoneButtonView.h"

#import "LOController.h"
#import "LOView.h"

@implementation LODoneButtonView


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
    
    [[[self superview] superview] hideInfo];
}

#pragma mark UIView

- (void)drawRect:(CGRect)rect;
{
    if (!pressed) {
        static UIImage *doneButtonImage;
        if (!doneButtonImage)
            doneButtonImage = [[UIImage imageNamed:@"lo-button-done.png"] retain];
        [doneButtonImage drawInRect:rect];
    } else {
        static UIImage *doneButtonPressedImage;
        if (!doneButtonPressedImage)
            doneButtonPressedImage = [[UIImage imageNamed:@"lo-button-done-press.png"] retain];
        [doneButtonPressedImage drawInRect:rect];
    }
}

@end
