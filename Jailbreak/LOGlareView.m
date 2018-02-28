#import <UIKit/UIKit.h>
#import <UIKit/UIImage.h>
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Rendering.h>

#import "LOGlareView.h"

#import "LOController.h"

@implementation LOGlareView

#pragma mark UIView

- (void)drawRect:(CGRect)rect;
{
    static UIImage *buttonGlareImage;
    if (!buttonGlareImage)
        buttonGlareImage = [[UIImage applicationImageNamed:@"lo-button-glare.png"] retain];
    [buttonGlareImage draw1PartImageInRect:rect];
}

@end
