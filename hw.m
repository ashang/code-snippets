#import <Foundation/Foundation.h>

int main (void)
{
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  NSLog(@"Hello, World!");

  [pool drain];
  return 0;
}
// need GNUStep
// gcc $(gnustep-config --objc-flags) hw.m $(gnustep-config --base-libs)
