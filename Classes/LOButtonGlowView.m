
#import "LOButtonGlowView.h"

#import "LOController.h"

@implementation LOButtonGlowView


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
    
    (type == LOButtonGlowLeft) ? [[self superview] skipToPreviousLevel] : [[self superview] skipToNextLevel];
}

#pragma mark UIView

- (void)drawRect:(CGRect)rect;
{
    if (pressed) {
        static UIImage *buttonGlowImage;
        if (!buttonGlowImage)
            buttonGlowImage = [[UIImage imageNamed:@"lo-glowpress.png"] retain];
        [buttonGlowImage drawInRect:rect];
    }
}


#pragma mark API

- (void)setButtonType:(LOButtonGlowType)buttonType;
{
    type = buttonType;
}

@end
