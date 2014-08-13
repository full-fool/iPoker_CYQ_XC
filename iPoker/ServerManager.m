//  ServerManager.m


#import "ServerManager.h"
#import "NSDictionary+JSONCategories.h"

#define SERVER_PORT 9999
#define READ_TIMEOUT -1

#define FORMAT(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]

@interface ServerManager()

@property (nonatomic) PokerGame *game;
@property NSMutableDictionary *playerSocketHashtable;

@end

@implementation ServerManager

/// Server initialization
- (void)serverInitWithGame:(PokerGame *)game
{
    self.game = game;
    self.playerSocketHashtable = [[NSMutableDictionary alloc]init];
    
    serverListenSocket = [[AsyncSocket alloc] initWithDelegate:self];
    [serverListenSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    
    serverConnectedSockets = [[NSMutableArray alloc] initWithCapacity:10];
}

/// Server starts to listen
- (void)serverListen
{
    NSError *error = nil;
    if ([serverListenSocket acceptOnPort:SERVER_PORT error:&error])
    {
        NSLog(@"Server established a listen socket on port %d", SERVER_PORT);
    }
    else
    {
        NSLog(@"Error starting server: %@", error);
        return;
    }
}

/// Server sends data to client
- (void)serverBroadcast:(NSString *)dataString
{
    NSLog(@"Server is broadcasting data...\n%@", dataString);
    NSString *outputDataString = [dataString stringByAppendingString:@"\r\n"];
    NSData *data = [outputDataString dataUsingEncoding: NSUTF8StringEncoding];
    for (AsyncSocket *sock in serverConnectedSockets)
    {
        [sock writeData:data withTimeout:-1 tag:0];
    }
}

/// Server sends data to a certain client
- (void)serverSend:(NSString *)dataString toPlayer:(NSString *)playerID
{
    NSLog(@"Server is sending data to player %@...\n%@", playerID, dataString);
    AsyncSocket *sock = [self.playerSocketHashtable valueForKey:playerID];
    NSString *outputDataString = [dataString stringByAppendingString:@"\r\n"];
    NSData *data = [outputDataString dataUsingEncoding: NSUTF8StringEncoding];
    [sock writeData:data withTimeout:-1 tag:0];
}

/// Server disconnects with all clients
- (void)serverDisconnectWithClients
{
    for (AsyncSocket *sock in serverConnectedSockets)
    {
        [sock disconnect];
    }
    [serverListenSocket disconnect];
}

// Private methods
- (BOOL)isJoinMessage:(NSString *)msg
{
    NSString *action = [[NSDictionary dictionaryWithString:msg] objectForKey:@"action"];
    if ([action isEqual: @"join"])
        return YES;
    else
        return NO;
}

// Delegate methods

/**
 * Called when a socket accepts a connection.
 * Another socket is automatically spawned to handle it.
 *
 * You must retain the newSocket if you wish to handle the connection.
 * Otherwise the newSocket instance will be released and the spawned connection will be closed.
 *
 * By default the new socket will have the same delegate and delegateQueue.
 * You may, of course, change this at any time.
 **/
- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
    NSLog(@"Server accepted new socket.");
	[serverConnectedSockets addObject:newSocket];
}

/**
 * Called when a socket connects and is ready for reading and writing.
 * The host parameter will be an IP address, not a DNS name.
 **/
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
	NSLog(@"Server already connected to %@:%hu", host, port);
    [sock readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:0];
}

/**
 * Called when a socket has completed writing the requested data. Not called if there is an error.
 **/
- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
	NSLog(@"Server just wrote data");
}

/**
 * Called when a socket has completed reading the requested data into memory.
 * Not called if there is an error.
 **/
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"Server just read data");
    // read data as string
    NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
	NSString *msg = [[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding];
    
    // print in log
	if(msg)
	{
        NSLog(@"%@", msg);
        [sock writeData:data withTimeout:-1 tag:0];
	}
	else
	{
        NSLog(@"Error converting received data into UTF-8 String");
	}
    
    // TODO:
    //  Do something after reading data from a client.

    NSDictionary *dict = [NSDictionary dictionaryWithString:msg];
    NSString *action = [dict valueForKey:@"action"];
    if ([action isEqualToString:@"join"])
    {
        NSString *name = [dict valueForKey:@"name"];
        PokerPlayer *player = [self.game allocPlayer];
        player.name = name;
        NSString *clientPlayerID = player.ID;
        [self.playerSocketHashtable setObject:sock forKey:clientPlayerID];
        
        NSMutableDictionary *retDict = [[NSMutableDictionary alloc] init];
        [retDict setValue:@"allocPID" forKey:@"action"];
        [retDict setValue:name forKey:@"name"];
        [retDict setValue:clientPlayerID forKey:@"PID"];
        [self serverSend:[retDict toJSONString] toPlayer:clientPlayerID];
        
    } else {
        // Join message did not imform server
        [self.game didServerReceiveMessage:msg];
    }
    
    [sock readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:0];
}

/**
 * Called when a socket disconnects with or without error.
 *
 * If you call the disconnect method, and the socket wasn't already disconnected,
 * then an invocation of this delegate method will be enqueued on the delegateQueue
 * before the disconnect method returns.
 *
 * Note: If the GCDAsyncSocket instance is deallocated while it is still connected,
 * and the delegate is not also deallocated, then this method will be invoked,
 * but the sock parameter will be nil. (It must necessarily be nil since it is no longer available.)
 * This is a generally rare, but is possible if one writes code like this:
 *
 * asyncSocket = nil; // I'm implicitly disconnecting the socket
 *
 * In this case it may preferrable to nil the delegate beforehand, like this:
 *
 * asyncSocket.delegate = nil; // Don't invoke my delegate method
 * asyncSocket = nil; // I'm implicitly disconnecting the socket
 *
 * Of course, this depends on how your state machine is configured.
 **/
- (void)onSocketDidDisconnect:(AsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"Server disconnected.");
	[serverConnectedSockets removeObject:sock];
}


@end
