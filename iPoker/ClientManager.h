//  ClientManager.h


#import <Foundation/Foundation.h>
#import "AsyncSocket.h"
#import "PokerGame.h"

@interface ClientManager : NSObject
{
    /// Client socket, communicates with server
    AsyncSocket *clientSocket;
}

- (void)clientInitWithGame:(PokerGame *)game;
- (BOOL)clientConnectToHost:(NSString *)host;
- (void)clientSend:(NSString *)dataString;
- (void)clientDisconnect;

@end
