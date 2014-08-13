//  PokerPlayer.h


#import <Foundation/Foundation.h>
@class PokerCard;
@class PokerDeck;

@interface PokerPlayer : NSObject

// ID of the player
@property (nonatomic, strong) NSString *ID;
// Name of the player
@property (nonatomic, strong) NSString *name;
// Cards selected by player
@property (nonatomic, strong) NSMutableArray *selectedCards;
// Decks owned by player
@property (nonatomic, strong) NSMutableArray *decks;
// Pocket - 手牌
@property (nonatomic, weak) PokerDeck *pocket;

- (void)selectCard:(PokerCard *)card;
- (void)moveCard:(PokerCard *)card ToDeck:(PokerDeck *)deck atIndex:(NSInteger)index;
- (NSString *)toJSONString;

@end
