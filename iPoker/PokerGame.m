//  PokerGame.m

#import "PokerGame.h"
#import "NSDictionary+JSONCategories.h"
#import "ServerManager.h"
#import "ClientManager.h"
#import "AppDelegate.h"

@interface PokerGame()
@property (strong, nonatomic) ClientManager *clientManager;
@property (strong, nonatomic) ServerManager *serverManager;
@property (nonatomic) NSUInteger deckCount;
@end

@implementation PokerGame

// Init the game with dCount decks, note that dCount is the number of
// the decks to draw from, it actually specifies the number of cards used in the game. e.g
// if dCount is 2, then the total number of cards in the game is 54*2 = 108.
- (id)initAsServer:(BOOL)isServer toHost:(NSString *)host
{
    self = [super init];
    if (self) {
        // TODO: Do things if is server or client
        if (isServer) {
            self.isServer = YES;
            self.serverManager = [[ServerManager alloc] init];
            [self.serverManager serverInitWithGame:self];
            [self.serverManager serverListen];
        } else {
            self.isServer = NO;
        }
        
        self.clientManager = [[ClientManager alloc] init];
        [self.clientManager clientInitWithGame:self];
        BOOL result = [self.clientManager clientConnectToHost:host];
        assert(result);
        
        [self reset];
    }
    return self;
}

/// Begin the game and send init message, only server can begin the game
- (void)begin
{
    // Send Init message
    NSString *msg;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSMutableArray *decks = [[NSMutableArray alloc] init],
                   *cards = [[NSMutableArray alloc] init],
                   *players = [[NSMutableArray alloc] init];
    
    //NSLog(@"in begin, the baseDeck ID is %@", self.baseDeck.ID);
    for (PokerDeck *deck in [self.decks allValues]) {
        [decks addObject:[deck toJSONString]];
    }
    for (PokerPlayer *player in [self.players allValues]) {
        [players addObject:[player toJSONString]];
    }
    for (PokerCard *card in [self.cards allValues]) {
        [cards addObject:[card toJSONString]];
    }
    
    [dict setValue:self.baseDeck.ID forKey:@"baseDeck"];
    [dict setValue:players forKey:@"players"];
    [dict setValue:decks forKey:@"decks"];
    [dict setValue:cards forKey:@"cards"];
    [dict setValue:@"init" forKey:@"action"];
    
    msg = [dict toJSONString];
    NSLog(@"Game:begin: \n%@", msg);
//    NSLog(@"Game begin, players %@ the end", players[0]);
    [self.serverManager serverBroadcast:msg];
}

/// Reset the game, only reset the information of BaseDeck
- (void)reset
{
    self.cards = [[NSMutableDictionary alloc] init];
    self.players = [[NSMutableDictionary alloc] init];
    self.decks = [[NSMutableDictionary alloc] init];
    self.eventQueue = [[NSMutableArray alloc] init];
    AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    [self joinGameWithName:appDelegate.nickName];
    // Send a request to server to join the game
   
    
    //[self joinGameWithName:self.player.name];
    //NSLog(@"in reset, the play name is %@", self.player.name);
    //only client needs to join game, server does not need to
    if (self.isServer) {
        // If is server, init a lot of thing.
        // If is client, much fewer thing will be initialized, even the player is not initialized.
        // Before the begining of the game, the server will send to each client a player ID, then
        // client can initialize the player object, and after that client must respond with a ACK
        // message plus the player's name.
        // After a while, server will send game entity initialization message to each client, including
        // the players, decks, cards inforamtion. Clients use this information to build a initial game
        // status.
        
        self.baseDeck = [self allocDeck];
        self.baseDeck.faceUp = NO;
        self.deckCount = 1;
        
        // Init baseDeck
        for (NSUInteger i = 0; i < self.deckCount; i++) {
            for (PokerCardRank rank = [PokerCard cardRankStart]; rank <= CardRankK; rank++) {
                for (PokerCardSuit suit = [PokerCard cardSuitStart]; suit <= [PokerCard cardSuitEnd]; suit++) {
                    PokerCard *card = [self allocCard];
                    card.suit = suit;
                    card.rank = rank;
                    card.tag = -1;
                    [self.baseDeck insertCard:card atIndex:-1];
                }
            }
        }
        
        // Init small and big joker
        PokerCard *joker1 = [self allocCard];
        joker1.suit = CardSuitSpade;
        joker1.rank = CardRankJokerSmall;
        [self.baseDeck insertCard:joker1 atIndex:-1];
        
        PokerCard *joker2 = [self allocCard];
        joker2.suit = CardSuitSpade;
        joker2.rank = CardRankJokerBig;
        [self.baseDeck insertCard:joker2 atIndex:-1];
        NSLog(@"Base deck init");
    }

    
}

/// Called when player moves card, this will send a message to server
- (void)moveCard:(PokerCard *)card toDeck:(PokerDeck *)deck atIndex:(NSInteger)index
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:@"moveCard" forKey:@"action"];
    NSLog(@"in moveCard to Deck, the playerID is %@", self.player.ID);
    [dict setValue:self.player.ID forKey:@"playerID"];
    [dict setValue:card.ID forKey:@"cardID"];
    [dict setValue:deck.ID forKey:@"deckID"];
    [dict setValue:[NSNumber numberWithInteger:index] forKey:@"index"];
    NSString *msg = [dict toJSONString];
    
    [self.clientManager clientSend:msg];
}
/// Called when player moves cards, this will send a message to server
- (void)moveCards:(NSMutableArray *)cards toDeck:(PokerDeck *)deck atIndex:(NSInteger)index
{
    NSMutableArray *jsoncards = [[NSMutableArray alloc]init];
    for(PokerCard *card in cards)
    {
        [jsoncards addObject:[card toJSONString]];
    }
    //NSLog(@"in movecards, the player ID is \n %@", self.player.ID);
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:@"moveCards" forKey:@"action"];
    [dict setValue:self.player.ID forKey:@"playerID"];
    [dict setValue:jsoncards forKey:@"cards"];
    [dict setValue:deck.ID forKey:@"deckID"];
    [dict setValue:[NSNumber numberWithInteger:index] forKey:@"index"];
    NSString *msg = [dict toJSONString];
//    NSLog(@"in move cards, the final message is :\n %@", msg);
    
    [self.clientManager clientSend:msg];
}
/// Called when player wants to pass
- (void)pass
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:@"pass" forKey:@"action"];
    [dict setValue:self.player.ID forKey:@"playerID"];
    NSString *msg = [dict toJSONString];
    
    [self.clientManager clientSend:msg];
}

/// Called when player sorts a deck
-(void)shuffle:(PokerDeck *)deck
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:@"shuffle" forKey:@"action"];
    [dict setValue:deck.ID forKey:@"deckID"];
    NSString *msg = [dict toJSONString];
    
    [self.clientManager clientSend:msg];
}
/// Called when player shuffle a deck
-(void)sort:(PokerDeck *)deck
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:@"sort" forKey:@"action"];
    [dict setValue:deck.ID forKey:@"deckID"];
    NSString *msg = [dict toJSONString];
    
    [self.clientManager clientSend:msg];
}
/// Called when the serverManager received a message.
/// Check if the action said in the message is valid, if it returns YES, this message is valid,
/// server can broadcast it to others.
- (BOOL)isValidMove:(NSString *)message
{
    NSDictionary *dict = [NSDictionary dictionaryWithString:message];
    NSString *action = [dict valueForKey:@"action"];
    assert([action isEqualToString:@"moveCard"]);
    
    NSString *cardID = [dict valueForKey:@"cardID"];
    NSString *srcDeckID = [dict valueForKey:@"srcDeckID"];
    
    PokerCard *card = [self getCardWithId:cardID];
    if ([card.deck.ID isEqualToString:srcDeckID]) {
        return YES;
    } else {
        return NO;
    }
}

/// When server received message with action otherThan allocPID, call this function
- (void)didServerReceiveMessage:(NSString *)message
{
    NSDictionary *dict = [NSDictionary dictionaryWithString:message];
    NSString *action = [dict valueForKey:@"action"];
    
    if ([action isEqualToString:@"moveCard"]) {
        // If moveCard is not valid
        //if (![self isValidMove:message])
        //    return;
    }
    [self.serverManager serverBroadcast:message];
}

/// When the clientManager received a message from the server (notice that server can be a client
/// at the same time), it will call this method to update the game status.
- (void)didClientReceiveMessage:(NSString *)message
{
    NSLog(@"in didclientreceivemessage, the message is %@, the end", message);
    [[self eventQueue] addObject:message];
}

/// Alloc a player, give it an auto-inc ID
- (PokerPlayer *)allocPlayer
{
    PokerPlayer *player = [[PokerPlayer alloc] init];
    PokerDeck *deck = [self allocDeck];
    player.pocket = deck;
    
    player.ID = [NSString stringWithFormat:@"player-%lu", (unsigned long)[self nPlayer]];
    [self.players setObject:player forKey:player.ID];
    
    return player;
}

- (PokerCard *)getCardWithId:(NSString *)ID
{
    return [self.cards valueForKey:ID];
}
- (PokerDeck *)getDeckWithId:(NSString *)ID
{
    return [self.decks valueForKey:ID];
}
- (PokerPlayer *)getPlayerWithId:(NSString *)ID
{
    return [self.players valueForKey:ID];
}

- (void)dealloc
{
    // Disconnect
    [self shutConnection];
}

// BELOW IS PRIVATE

/// When client received a message with action 'init'
- (void)didInitWithDictionary:(NSDictionary *)entities
{
    // Server cares nothing about initialization
    if (!self.isServer)
    {
        NSLog(@"in didinitwithdictionary");

        NSArray *decks = [entities valueForKey:@"decks"];
        NSArray *cards = [entities valueForKey:@"cards"];
        NSArray *players = [entities valueForKey:@"players"];
        NSString *baseDeckID = [entities valueForKey:@"baseDeck"];

        // init decks
        for (NSString *deckStr in decks)
        {
            NSDictionary *deck = [NSDictionary dictionaryWithString:deckStr];

            NSString *ID = [deck valueForKey:@"ID"];
            NSString *faceUp = [deck valueForKey:@"faceUp"];
            
            PokerDeck *newDeck = [[PokerDeck alloc]init];
            newDeck.ID = ID;
            newDeck.faceUp = [faceUp intValue] == 1 ? YES : NO;
            
            [self.decks setValue:newDeck forKey:newDeck.ID];
        }
        
        // init cards
        for (NSString *cardStr in cards)
        {
            NSDictionary *card = [NSDictionary dictionaryWithString:cardStr];

            NSString *ID = [card valueForKey:@"ID"];
            NSString *rank = [card valueForKey:@"rank"];
            NSString *suit = [card valueForKey:@"suit"];
            NSString *faceUp = [card valueForKey:@"faceUp"];
            NSString *deck = [card valueForKey:@"deckID"];
            
            PokerCard *newCard = [[PokerCard alloc]init];
            newCard.ID = ID;
            newCard.rank = [rank intValue];
            newCard.suit = [suit intValue];
            newCard.faceUp = [faceUp intValue] == 1 ? YES : NO;
            newCard.deck = [self.decks valueForKey:deck];
         
            [self.cards setValue:newCard forKey:newCard.ID];
        }

        // init players
        for (NSString *playerStr in players)
        {
            NSDictionary *player = [NSDictionary dictionaryWithString:playerStr];

            NSString *ID = [player valueForKey:@"ID"];
            
            NSString *name = [player valueForKey:@"name"];
            NSArray *selectedCardIDs = [player valueForKey:@"selectedCards"];
            NSArray *deckIDs = [player valueForKey:@"decks"];
            NSString *pocketID = [player valueForKey:@"pocket"];
            
            NSMutableArray *selectedCardObjects = [[NSMutableArray alloc]init];
            NSMutableArray *decksObjects = [[NSMutableArray alloc]init];
            for (NSString *cardID in selectedCardIDs)
            {
                [selectedCardObjects addObject:[self.cards valueForKey:cardID]];
            }
            for (NSString *deckID in deckIDs)
            {
                [decksObjects addObject:[self.decks valueForKey:deckID]];
            }
            PokerDeck *pocketDeck = [self.decks valueForKey:pocketID];
            
            // only append player when this player is not self
            if (ID != self.player.ID)
            {
                PokerPlayer *newPlayer = [[PokerPlayer alloc]init];
                newPlayer.ID = ID;
                newPlayer.name = name;
                newPlayer.selectedCards = selectedCardObjects;
                newPlayer.decks = decksObjects;
                newPlayer.pocket = pocketDeck;
                
                [self.players setValue:newPlayer forKey:newPlayer.ID];
            }
            else
            {
                self.player.name = name;
                self.player.selectedCards = selectedCardObjects;
                self.player.decks = decksObjects;
                self.player.pocket = pocketDeck;
            }
        }
        
        // update decks
        for (NSString *deckStr in decks)
        {
            NSDictionary *deck = [NSDictionary dictionaryWithString:deckStr];
            
            NSString *ID = [deck valueForKey:@"ID"];
            NSString *playerID = [deck valueForKey:@"playerID"];
            
            PokerDeck *deckObject = [self.decks valueForKey:ID];
            deckObject.player = [self.players valueForKey:playerID];
        }
        
        // init base deck
        self.baseDeck = [self.decks valueForKey:baseDeckID];
    }
}

/// When client received a message with action 'allocPID'
/// Use PID and name to create a new player, notice that this player is not fully built,
/// we need init message sent from server to complete this process.
///*** note that client can only call it when the message is about itself
- (void)didAllocPID:(NSString *)message
{
    // Server cares nothing about intialization
    //if (self.isServer)
    //    return;
    NSDictionary *dict = [NSDictionary dictionaryWithString:message];
    NSString *name = [dict valueForKey:@"name"];
    NSString *PID = [dict valueForKey:@"PID"];
    //self.player = [[PokerPlayer alloc] init];
    //self.player.ID = PID;
    
    PokerPlayer *player = [[PokerPlayer alloc] init];
    player.ID = PID;
    player.name = name;
    self.player = player;
    NSLog(@"in didallocpid, the PID is %@", self.player.ID);
    [self.players setValue:player forKey:player.ID];
}

/// When client received a message with action 'moveCard'
- (void)didPlayer:(PokerPlayer *)player moveCard:(PokerCard *)card toDeck:(PokerDeck *)deck atIndex:(NSInteger)index
{
    [player moveCard:card ToDeck:deck atIndex:index];
}


/// When client received a message with action 'shuffle'
- (void)didPlayer:(PokerPlayer *)player shuffleDeck:(PokerDeck *)deck
{
    [deck shuffle];
}


/// When client received a message with action 'sort'
- (void)didPlayer:(PokerPlayer *)player sortDeck:(PokerDeck *)deck
{
    [deck sort];
}

/// Send a message to server, try to join the game
- (void)joinGameWithName:(NSString *)name
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:@"join" forKey:@"action"];
    [dict setValue:name forKey:@"name"];
    NSString *msg = [dict toJSONString];
    
    [self.clientManager clientSend:msg];
}

- (NSUInteger)nCard
{
    return [self.cards count];
}

- (NSUInteger)nDeck
{
    return [self.decks count];
}

- (NSUInteger)nPlayer
{
    return [self.players count];
}

/// Alloc a card, give it an auto-inc ID
- (PokerCard *)allocCard
{
    PokerCard *card = [[PokerCard alloc] init];
    card.ID = [NSString stringWithFormat:@"card-%lu", (unsigned long)[self nCard]];
    [self.cards setObject:card forKey:card.ID];
    
    return card;
}

/// Alloc a deck, give it an auto-inc ID
- (PokerDeck *)allocDeck
{
    PokerDeck *deck = [[PokerDeck alloc] init];
    deck.ID = [NSString stringWithFormat:@"deck-%lu", (unsigned long)[self nDeck]];
    [self.decks setObject:deck forKey:deck.ID];
    
    return deck;
}

/// Shutdown all connection
- (void)shutConnection
{
    if (self.isServer) {
        [self.serverManager serverDisconnectWithClients];
        NSLog(@"Server connection shut");
    }
    [self.clientManager clientDisconnect];
}
@end
