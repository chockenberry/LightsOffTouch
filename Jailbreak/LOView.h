#import <UIKit/UIKit.h>
#import <UIKit/UIView.h>

@class LOInfoView, LOButtonView, LOController, UITextLabel;

@interface LOView : UIView {
    LOController *controller;
    LOInfoView *infoView;
    NSMutableDictionary *buttonNamesToViews;
    UITextLabel *levelTextLabel;
}

// API
- (id)initWithFrame:(CGRect)frame controller:(LOController *)viewController;
- (NSDictionary *)buttonNamesToViews;
- (void)pressButtonView:(LOButtonView *)buttonView;
- (void)showInfo;
- (void)hideInfo;
- (void)reset;
- (void)skipToNextLevel;
- (void)skipToPreviousLevel;

@end
