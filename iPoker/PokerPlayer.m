//  PokerPlayer.m


#import "PokerPlayer.h"
#import "PokerCard.h"
#import "PokerDeck.h"
#import "NSDictionary+JSONCategories.h"

@implementation PokerPlayer

/// Lazy init
- (NSMutableArray *)selectedCards {
    if (!_selectedCards) _selectedCards = [[NSMutableArray alloc] init];
    return _selectedCards;
}

/// Select a card, card will be added to selectedCards.
- (void)selectCard:(PokerCard *)card
{
    [self.selectedCards addObject:card];
}
/// Move a card to deck at index. First remove the card from its original deck,
/// then move it to the destination deck, card.deck and card.faceUp will be
/// changed according to the destination deck.
- (void)moveCard:(PokerCard *)card ToDeck:(PokerDeck *)deck atIndex:(NSInteger)index
{
    [card.deck removeCard:card];
    [deck insertCard:card atIndex:index];
}

/// Change information of this card to JSON format
- (NSString *)toJSONString
{
    NSMutableArray *selectedCardsIDs = [[NSMutableArray alloc] init];
    NSMutableArray *decksIDs = [[NSMutableArray alloc] init];
    for (PokerCard *card in self.selectedCards)
    {
        [selectedCardsIDs addObject:card.ID];
    }
    for (PokerDeck *deck in self.decks)
    {
        [decksIDs addObject:deck.ID];
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:self.ID forKey:@"ID"];
    [dict setValue:selectedCardsIDs forKey:@"selectedCards"];
    [dict setValue:decksIDs forKey:@"decks"];
    [dict setValue:self.pocket.ID forKey:@"pocket"];
    return [dict toJSONString];
}

@end
