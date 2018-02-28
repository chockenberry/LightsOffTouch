
#import <UIKit/UIKit.h>

@class LightsOffTouchAppDelegate, LOInfoView, LOButtonView, LOController;

@interface LOView : UIView {
    LightsOffTouchAppDelegate *controller;
    LOInfoView *infoView;
    NSMutableDictionary *buttonNamesToViews;
    UILabel *levelTextLabel;
}

// API
- (id)initWithFrame:(CGRect)frame controller:(LightsOffTouchAppDelegate *)viewController;
- (NSDictionary *)buttonNamesToViews;
- (void)pressButtonView:(LOButtonView *)buttonView;
- (void)showInfo;
- (void)hideInfo;
- (void)reset;
- (void)skipToNextLevel;
- (void)skipToPreviousLevel;

@end
