//  PokerDeck.h

#import <Foundation/Foundation.h>
@class PokerCard;
@class PokerPlayer;

@interface PokerDeck : NSObject

// ID of the deck
@property (nonatomic, strong) NSString *ID;
// Deck's default value for poker's faceUp attribute
@property (nonatomic, getter = isFaceUp) BOOL faceUp;
// Player the deck belongs to, if player is set to NULL, this deck
// is public to all players
@property (nonatomic, weak) PokerPlayer *player;

- (void)shuffle;
- (void)sort;
- (PokerCard *)getCardAtIndex:(NSInteger)index;
- (BOOL)insertCard:(PokerCard *)card atIndex:(NSInteger)index;
- (PokerCard *)removeCardAtIndex:(NSInteger)index;
- (void)removeCard:(PokerCard *)card;
- (NSString *)toJSONString;
- (BOOL)isEmpty;
- (PokerCard *)removeCardAtTag:(NSInteger)tag;
@end
