//  NSMutableArray+NSMutableArrayAdditions.m

#import "NSMutableArray+NSMutableArrayAdditions.h"

@implementation NSMutableArray (NSMutableArrayAdditions)

// Shuffle elements randomly
- (void)shuffle
{
    NSUInteger count = [self count];
    for (NSUInteger i = 0; i < count; i++) {
        NSUInteger nElements = count - i;
        NSUInteger n = arc4random() % nElements + i;
        [self exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

@end
