//  ServerManager.h

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"
#import "PokerGame.h"

@interface ServerManager : NSObject
{
    /// Server socket, listens to clients' incoming connection
    AsyncSocket *serverListenSocket;
    /// Server sockets, communicates with connected clients
    NSMutableArray *serverConnectedSockets;
}

- (void)serverInitWithGame:(PokerGame *)game;
- (void)serverListen;
- (void)serverBroadcast:(NSString *)dataString;
- (void)serverSend:(NSString *)dataString toPlayer:(NSString *)playerID;
- (void)serverDisconnectWithClients;

@end
