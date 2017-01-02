/******************* hello.m ***********************/
#import <Foundation/Foundation.h>

@interface HelloWorld : NSObject
- (void) hello;
@end

@implementation HelloWorld
- (void) hello {
    NSLog(@"hello world!");
}
@end

int main(void) {
    HelloWorld *hw = [[HelloWorld alloc] init];
    [hw hello];
    [hw release];
}
/******************* end ***********************/

// need GNUStep
// gcc $(gnustep-config --objc-flags) hello.m $(gnustep-config --base-libs)
