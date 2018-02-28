
#import <UIKit/UIKit.h>

@class LOButtonView;

@interface LOHighlightView : UIView {
    LOButtonView *buttonView;
}
- (id)initWithFrame:(CGRect)frame buttonView:(LOButtonView *)button;
@end
