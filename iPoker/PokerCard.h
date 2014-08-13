//  PokerCard.h

typedef enum {
    CardSuitDiamond = 0,
    CardSuitHeart,
    CardSuitClub,
    CardSuitSpade
} PokerCardSuit;

typedef enum {
    CardRankA = 1,
    CardRank2,
    CardRank3,
    CardRank4,
    CardRank5,
    CardRank6,
    CardRank7,
    CardRank8,
    CardRank9,
    CardRank10,
    CardRankJ,
    CardRankQ,
    CardRankK,
    CardRankJokerSmall,
    CardRankJokerBig
} PokerCardRank;

#import <Foundation/Foundation.h>

@class PokerDeck;

@interface PokerCard : NSObject

// ID of card
@property (nonatomic, strong) NSString *ID;
// Rank of card
@property (nonatomic) PokerCardRank rank;
// Suit of card
@property (nonatomic) PokerCardSuit suit;
// Face of card, YES for up, NO for down
// When a card is moved to a PokerDeck *deck, the faceUp value will be set to
// deck.faceUp
@property (nonatomic, getter = isFaceUp) BOOL faceUp;
// Deck it belongs to, must not be NULL
@property (nonatomic, weak) PokerDeck *deck;

- (void)flip;
- (NSComparisonResult)compare:(PokerCard *)otherCard;
- (NSString *)toJSONString;
+ (PokerCardSuit)cardSuitStart;
+ (PokerCardSuit)cardSuitEnd;
+ (PokerCardRank)cardRankStart;
+ (PokerCardRank)cardRankEnd;
@end
