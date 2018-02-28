
#import "LOGlareView.h"

#import "LOController.h"

@implementation LOGlareView

#pragma mark UIView

- (void)drawRect:(CGRect)rect;
{
    static UIImage *buttonGlareImage;
    if (!buttonGlareImage)
        buttonGlareImage = [[UIImage imageNamed:@"lo-button-glare.png"] retain];
    [buttonGlareImage drawInRect:rect];
}

@end
