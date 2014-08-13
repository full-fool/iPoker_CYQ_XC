//  ClientManager.m


#import "ClientManager.h"

#define SERVER_PORT 9999
#define READ_TIMEOUT -1
#define FORMAT(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]

@interface ClientManager()

@property (nonatomic) PokerGame *game;

@end


@implementation ClientManager

/// Client initialization
- (void)clientInitWithGame:(PokerGame *)game
{
    self.game = game;
    clientSocket = [[AsyncSocket alloc] initWithDelegate:self];
}

/// Client establishes connection with server, host should be in format "*.*.*.*"
- (BOOL)clientConnectToHost:(NSString *)host
{
    NSError *error = nil;
    // connection succeeds
    if ([clientSocket connectToHost:host onPort:SERVER_PORT error:&error])
    {
        NSLog(@"Client connects to host:%@", host);
        return true;
    }
    // connection fails
    else
    {
        NSLog(@"Client fails to connect to host:%@", host);
        return false;
    }
}

/// Client sends data to server
- (void)clientSend:(NSString *)dataString
{
    NSLog(@"Client is sending data...");
    NSString *outputDataString = [dataString stringByAppendingString:@"\r\n"];
    NSLog(@"%@", outputDataString);
    NSData *data = [outputDataString dataUsingEncoding: NSUTF8StringEncoding];
    [clientSocket writeData:data withTimeout:-1 tag:0];
}

- (void)clientDisconnect
{
    [clientSocket disconnect];
}

// Delegate methods

/**
 * Called when a socket connects and is ready for reading and writing.
 * The host parameter will be an IP address, not a DNS name.
 **/
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
	NSLog(@"Client already connected to %@:%hu", host, port);
	
    // TODO:
    //  Wait for welcome message.
    [sock readDataWithTimeout:-1 tag:0];
}

/**
 * Called when a socket has completed writing the requested data. Not called if there is an error.
 **/
- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
	NSLog(@"Client just wrote data");
}

/**
 * Called when a socket has completed reading the requested data into memory.
 * Not called if there is an error.
 **/
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"Client just read data");
    // read data as string
    NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
	NSString *msg = [[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding];
    
    // print in log
	if(msg)
	{
        NSLog(@"%@", msg);
	}
	else
	{
        NSLog(@"Error converting received data into UTF-8 String");
	}
    
    // TODO:
    //  Do something after reading data from server.
    [self.game didClientReceiveMessage:msg];
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
    NSLog(@"Client disconnected.");
}

@end
