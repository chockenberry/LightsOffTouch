
#import "LOInfoView.h"

#import "LOController.h"

@implementation LOInfoView

#pragma mark UIView

- (void)drawRect:(CGRect)rect;
{
    static UIImage *infoImage;
    if (!infoImage)
        infoImage = [[UIImage imageNamed:@"lo-background-info.png"] retain];
    [infoImage drawInRect:rect];
}

@end
