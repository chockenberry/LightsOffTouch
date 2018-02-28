#import <UIKit/UIKit.h>
#import <UIKit/UIView.h>

typedef enum {
    LOButtonGlowLeft,
    LOButtonGlowRight
} LOButtonGlowType;

@interface LOButtonGlowView : UIView {
    BOOL pressed;
    LOButtonGlowType type;
}

// API
- (void)setButtonType:(LOButtonGlowType)buttonType;

@end
