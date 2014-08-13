//  PokerGame+PrivateMethods.h


#import "PokerGame.h"

@interface PokerGame (PrivateMethods)

- (void)didInitWithDictionary:(NSDictionary *)entities;

- (void)didAllocPID:(NSString *)message;

- (void)didPlayer:(PokerPlayer *)player MoveCard:(PokerCard *)card toDeck:(PokerDeck *)deck atIndex:(NSInteger)index;

- (void)joinGameWithName:(NSString *)name;

- (PokerCard *)allocCard;

- (PokerDeck *)allocDeck;

- (NSUInteger)nCard;

- (NSUInteger)nDeck;

- (NSUInteger)nPlayer;

- (void)shutConnection;
@end
