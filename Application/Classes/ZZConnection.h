//
//  ZZConnection.h
//  Trazzle
//
//  Created by Marc Bauer on 12.09.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AsyncSocket.h"
#import "AMFDuplexGateway.h"


@interface ZZConnection : NSObject
{
	id m_remote;
	id m_delegate;
	BOOL m_isLegacyConnection;
	NSDictionary *m_connectionParams;
	NSMutableDictionary *m_pluginStorage;
}
@property (nonatomic, readonly) BOOL isLegacyConnection;
@property (nonatomic, readonly) id remote;
@property (nonatomic, readonly) NSString *swfURL;
@property (nonatomic, readonly) NSString *applicationName;
- (id)initWithRemote:(id)remote delegate:(id)delegate;
- (void)setConnectionParams:(NSDictionary *)params;
- (NSMutableDictionary *)storageForPluginWithName:(NSString *)name;
- (void)disconnect;
@end

@interface NSObject (ZZConnectionDelegate)
- (void)connection:(ZZConnection *)client didReceiveMessage:(NSString *)message;
- (void)connectionDidDisconnect:(ZZConnection *)connection;
@end