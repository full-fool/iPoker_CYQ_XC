//  PokerGame.h


#import <Foundation/Foundation.h>
#import "PokerCard.h"
#import "PokerDeck.h"
#import "PokerPlayer.h"

@interface PokerGame : NSObject

/// ID of the game
@property (nonatomic, strong) NSString *ID;
/// Cards in the game, key-ed by card's id
@property (nonatomic, strong) NSMutableDictionary *cards;
/// Decks in the game, key-ed by deck id
@property (nonatomic, strong) NSMutableDictionary *decks;
/// Players in the game, key-ed by player's id
@property (nonatomic, strong) NSMutableDictionary *players;
/// Base deck - 底牌堆
@property (nonatomic, strong) PokerDeck *baseDeck;
/// Is a server or client
@property (nonatomic) BOOL isServer;
/// Player who plays the game
@property (nonatomic, strong) PokerPlayer *player;
/// Events queue, every time a player action message is received, the action will be
/// added in to this queue. This queue will be empty if no any events.
@property (nonatomic, strong) NSMutableArray *eventQueue;

- (id)initAsServer:(BOOL)isServer toHost:(NSString *)host;

/// Methods to get game entities
- (PokerCard *)getCardWithId:(NSString *)ID;
- (PokerDeck *)getDeckWithId:(NSString *)ID;
- (PokerPlayer *)getPlayerWithId:(NSString *)ID;

/// Methods to act in a game
- (void)moveCard:(PokerCard *)card toDeck:(PokerDeck *)deck atIndex:(NSInteger)index;
- (void)moveCards:(NSMutableArray *)cards toDeck:(PokerDeck *)deck atIndex:(NSInteger)index;
- (void)pass;
- (void)begin;
- (void)reset;
- (void)joinGameWithName:(NSString *)name;
- (void)shuffle:(PokerDeck *)deck;
- (void)sort:(PokerDeck *)deck;

/// Methods called by server/client manager
- (void)didServerReceiveMessage:(NSString *)message;
- (void)didClientReceiveMessage:(NSString *)message;
- (PokerPlayer *)allocPlayer;

/// Connection callbacks and others
- (void)didInitWithDictionary:(NSDictionary *)entities;
- (void)didAllocPID:(NSString *)message;
- (void)didPlayer:(PokerPlayer *)player moveCard:(PokerCard *)card toDeck:(PokerDeck *)deck atIndex:(NSInteger)index;
- (void)didPlayer:(PokerPlayer *)player shuffleDeck:(PokerDeck *)deck;
- (void)didPlayer:(PokerPlayer *)player sortDeck:(PokerDeck *)deck;
- (PokerCard *)allocCard;
- (PokerDeck *)allocDeck;
- (NSUInteger)nCard;
- (NSUInteger)nDeck;
- (NSUInteger)nPlayer;
- (void)shutConnection;

@end
