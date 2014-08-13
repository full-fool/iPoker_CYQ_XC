//  PokerCard.m

#import "PokerCard.h"
#import "PokerDeck.h"
#import "NSDictionary+JSONCategories.h"

@implementation PokerCard

// Flip a poker card by updating the faceUp attribute.If faceUp is YES, set to NO,
// vice versa. You can also directly set the faceUp attribute if you need to set it
// explitly.
- (void)flip
{
    self.faceUp = !self.faceUp;
}

// Compare one card with another, first compare suit, then compare rank
- (NSComparisonResult)compare:(PokerCard *)otherCard
{
    if (self.suit == otherCard.suit) {
        if (self.rank < otherCard.rank)
            return NSOrderedAscending;
        else if (self.rank == otherCard.rank)
            return NSOrderedSame;
        else return NSOrderedDescending;
    } else {
        if (self.suit < otherCard.suit)
            return NSOrderedAscending;
        else return NSOrderedDescending;
    }
}

/// Change information of this card to JSON format
- (NSString *)toJSONString
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setValue:self.ID forKey:@"ID"];
    [dict setValue:[NSNumber numberWithInt:self.rank] forKey:@"rank"];
    [dict setValue:[NSNumber numberWithInt:self.suit] forKey:@"suit"];
    [dict setValue:[NSNumber numberWithBool:self.faceUp] forKey:@"faceUp"];
    [dict setValue:self.deck.ID forKey:@"deckID"];
    return [dict toJSONString];
}

// Below is some helpers for card suit and rank iteration
+ (PokerCardSuit)cardSuitStart { return CardSuitDiamond; }
+ (PokerCardSuit)cardSuitEnd { return CardSuitSpade; }
+ (PokerCardRank)cardRankStart { return CardRankA; }
+ (PokerCardRank)cardRankEnd { return CardRankJokerBig; }

@end
