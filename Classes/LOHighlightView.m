
#import "LOHighlightView.h"

#import "LOButtonView.h"
#import "LOController.h"

@implementation LOHighlightView

#pragma mark API

- (id)initWithFrame:(CGRect)frame buttonView:(LOButtonView *)button;
{
    if (![super initWithFrame:frame])
        return nil;
    buttonView = button; // non-retained
    return self;
}


#pragma mark UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [buttonView touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [buttonView touchesEnded:touches withEvent:event];
}



#pragma mark UIView

- (void)drawRect:(CGRect)rect;
{
    static UIImage *buttonGlowImage;
    if (!buttonGlowImage)
        buttonGlowImage = [[UIImage imageNamed:@"lo-button-fullglow.png"] retain];
    [buttonGlowImage drawInRect:rect];
}

@end
