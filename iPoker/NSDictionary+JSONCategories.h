//  NSDictionary+JSONCategories.h



#import <Foundation/Foundation.h>

@interface NSDictionary (JSONCategories)
+ (NSDictionary *)dictionaryWithString:(NSString *)string;
- (NSString *)toJSONString;
- (NSData *)toJSONData;
@end
