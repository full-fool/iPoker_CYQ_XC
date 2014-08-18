//  NSDictionary+JSONCategories.m



#import "NSDictionary+JSONCategories.h"

@implementation NSDictionary (JSONCategories)

/// Get NSDictionary from NSString
+ (NSDictionary *)dictionaryWithString:(NSString *)string
{
    __autoreleasing NSError *error = nil;
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *result =
        [NSJSONSerialization JSONObjectWithData:data
                                        options:NSJSONReadingMutableContainers error:&error];
    if (error != nil) return nil;
    return result;
}

/// Convert NSDictionary to NSData
- (NSData *)toJSONData
{
    __autoreleasing NSError *error = nil;
    NSData *result = [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}

/// Convert NSDictionary to NSString
- (NSString *)toJSONString
{
    NSData *data = [self toJSONData];
    if (data == nil) return nil;
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return result;
}

@end
