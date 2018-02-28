
#import <UIKit/UIKit.h>

@interface LOButtonView : UIView {
    BOOL lightOn;
    BOOL pressed;
}

- (void)setLightOn:(BOOL)isOn;
- (BOOL)isLightOn;
- (void)setPressed:(BOOL)isPressed;
- (BOOL)isPressed;

@end
