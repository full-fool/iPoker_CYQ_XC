//  PokerDeck.m

#import "PokerDeck.h"
#import "PokerCard.h"
#import "PokerPlayer.h"
#import "NSMutableArray+NSMutableArrayAdditions.h"
#import "NSDictionary+JSONCategories.h"

@interface PokerDeck()

// Cards in the deck
@property (nonatomic, strong) NSMutableArray *cards;

@end

@implementation PokerDeck

- (id)init
{
    self = [super init];
    
    if (self) {
        self.faceUp = NO;
    }
    
    return self;
}

// Lazy init
- (NSMutableArray *)cards
{
    if (!_cards) _cards = [[NSMutableArray alloc] init];
    return _cards;
}

// Shuffle the cards in the deck - randomly order the cards.
- (void)shuffle
{
    [self.cards shuffle];
}
// Sort cards in a PRE-DEFINED order,
// A < 2 < 3 < ... < 10 < J < Q < K < JokerSmall < JokerBig,
// then spade < heart < club < diamond.
// Will support palyer-defined order rule in the future.
- (void)sort
{
    [self.cards sortUsingSelector:@selector(compare:)];
}
// Get a card at given index, return object in the cards array using
// the same index. Except that when index is -1 will return the last
// object in the array.
// If illegal index is given, retuen NULL.
- (PokerCard *)getCardAtIndex:(NSInteger)index
{
    if (index == -1)
        return [self.cards lastObject];
    if (index >= 0 && index < [self.cards count])
        return [self.cards objectAtIndex:index];
    return NULL;
}
// Insert card at index into the deck, the same rountine as getCardAtIndex:,
// return YES on successful insertion, NO on failed one.
- (BOOL)insertCard:(PokerCard *)card atIndex:(NSInteger)index;
{
    card.deck = self;
    card.faceUp = self.faceUp;
    if (index == -1)
        [self.cards insertObject:card atIndex:[self.cards count]];
    else if (index >= 0 && index <= [self.cards count])
        [self.cards insertObject:card atIndex:index];
    else return NO;
    // success
    return YES;
}
// Remove a card at given index, the same rountine as getCardAtIndex:,
// but will remove the card from the cards array as a side-effect.
// return NULL when illegal index is given.
- (PokerCard *)removeCardAtIndex:(NSInteger)index
{
    PokerCard *card = [self getCardAtIndex:index];
    [self removeCard:card];
    return card;
}

// Remove card, if no such card, do nothing. If remove successes, set card.deck
// to nil.
- (void)removeCard:(PokerCard *)card
{
    card.deck = nil;
    [self.cards removeObject:card];
}

/// Change information of this card to JSON format
- (NSString *)toJSONString
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:self.ID forKey:@"ID"];
    [dict setValue:[NSNumber numberWithBool:self.faceUp] forKey:@"faceUp"];
    [dict setValue:self.player.ID forKey:@"playerID"];
    return [dict toJSONString];
}

/// Return YES if there is no card in the deck
- (BOOL)isEmpty
{
    return [self.cards count] == 0;
}

@end
