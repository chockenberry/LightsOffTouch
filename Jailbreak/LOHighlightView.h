#import <UIKit/UIKit.h>
#import <UIKit/UIView.h>

@class LOButtonView;

@interface LOHighlightView : UIView {
    LOButtonView *buttonView;
}
- (id)initWithFrame:(CGRect)frame buttonView:(LOButtonView *)button;
@end
