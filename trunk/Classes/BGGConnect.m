//
//  BGGConnect.m
//  BGG
//
//  Created by RYAN CHRISTIANSON on 1/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BGGConnect.h"
#import "PostWorker.h"


@implementation BGGConnect

@synthesize username, password, authCookies;

//! Connect and get a auth key from bgg
- (void) connectForAuthKey {
	
	[authCookies release];
	authCookies = nil;
	
	// post worker test
	PostWorker* worker = [[PostWorker alloc] init];

	// the login URL
	worker.url = @"http://boardgamegeek.com/login";
	
	// setup params
	NSMutableDictionary * params= [[NSMutableDictionary alloc] initWithCapacity:2];
	[params setObject:username forKey:@"username"];
	[params setObject:password forKey:@"password"];
	worker.params = params;
	[params release];
	
	
	BOOL success = [worker start];
	
	if ( success ) {
		NSArray * cookies =  worker.responseCookies ;
		NSInteger count = [cookies count];
		for ( NSInteger i = 0; i < count; i++ ) {
			NSHTTPCookie * cookie = (NSHTTPCookie*) [ cookies objectAtIndex:i];
			// see if the bggpassword cookie is set, if it is then auth is good
			if ( [ @"bggpassword" isEqualToString: [cookie name] ] ) {
				self.authCookies = cookies;
				break;
			} // end if is password cookie
		} // end for 
	} // end if success
	
	[worker release];

}

//! Log a play, with simple params
- (BGGConnectResponse) simpleLogPlayForGameId: (NSInteger) gameId forDate: (NSDate *) date numPlays: (NSInteger) plays {
	
	// see if we have auth key
	if ( authCookies == nil ) {
		[self connectForAuthKey];
	}
	
	// see if we got the auth key
	if ( authCookies == nil ) {
		return AUTH_ERROR;
	}
	
	

	// post worker test
	PostWorker* worker = [[PostWorker alloc] init];
	
	// set the auth cookies
	worker.requestCookies = authCookies;
	
	// the log play URL
	worker.url = @"http://boardgamegeek.com/geekplay.php";
	
	// setup params
	NSMutableDictionary * params= [[NSMutableDictionary alloc] initWithCapacity:2];

	// ajax=1&action=save&version=2&
	// objecttype=thing&objectid=36218&
	// playid=&action=save&playdate=2009-02-07&dateinput=2009-02-07&YUIButton=&location=&quantity=1&length=&incomplete=0&nowinstats=0&comments=
	
	// these do not change
	[params setObject:@"1" forKey:@"ajax"];
	[params setObject:@"save" forKey:@"action"];
	[params setObject:@"2" forKey:@"version"];
	[params setObject:@"thing" forKey:@"objecttype"];
	[params setObject:@"0" forKey:@"incomplete"];
	[params setObject:@"0" forKey:@"nowinstats"];
	
	// set the game id
	[params setObject:[NSString stringWithFormat:@"%d", gameId] forKey:@"objectid"];
	
	// set the quantity
	[params setObject:[NSString stringWithFormat:@"%d", plays] forKey:@"quantity"];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat: @"yyyy-MM-dd"];
	NSString * datePlayedStr = [dateFormatter stringFromDate:date];
	[dateFormatter release];
	
	// add play date
	[params setObject:datePlayedStr forKey:@"playdate"];
	[params setObject:datePlayedStr forKey:@"dateinput"];
	
	// set the params on request
	worker.params = params;
	[params release];

	
	BOOL success = [worker start];
	
	if ( success ) {
		NSString * responseBody = [[NSString alloc] initWithData:worker.responseData encoding:  NSASCIIStringEncoding];
		if ( responseBody != nil ) {
			NSRange range = [responseBody rangeOfString:@"Plays"];
			if ( range.location != NSNotFound ) {
				return SUCCESS;
			}
		}
	}
	
	return CONNECTION_ERROR;
	
	
	/*
	ajax=1
	&action=save&
	version=2&
	objecttype=boardgame
	&objectid=31260&
	playid=
	&action=save
	&playdate=2009-01-24
	&dateinput=2009-01-24
	&YUIButton=
	&location=
	&quantity=1
	&length=
	&incomplete=0
	&nowinstats=0
	&comments=
	 */
	
	
	
}


//! update game state in collection
- (BGGConnectResponse) saveCollectionForGameId: (NSInteger) gameId flag: (BGGConnectCollectionFlag) flag setFlag: (BOOL) shouldSet  {

	// see if we have auth key
	if ( authCookies == nil ) {
		[self connectForAuthKey];
	}
	
	// see if we got the auth key
	if ( authCookies == nil ) {
		return AUTH_ERROR;
	}

	
	// post worker test
	PostWorker* worker = [[PostWorker alloc] init];
	
	// set the auth cookies
	worker.requestCookies = authCookies;
	
	// the log play URL
	worker.url = @"http://boardgamegeek.com/geekcollection.php";
	
	// bgg params
	/*
	 ajax=1
	 &action=savedata
	 &fieldname=status
	 &collid=7820316
	 &own=1
	 &wishlistpriority=3
	 */
	
	// setup params
	NSMutableDictionary * params= [[NSMutableDictionary alloc] initWithCapacity:2];
	
	// these do not change
	[params setObject:@"1" forKey:@"ajax"];
	[params setObject:@"savedata" forKey:@"action"];
	[params setObject:@"status" forKey:@"fieldname"];
	[params setObject:@"boardgame" forKey:@"objecttype"];
	
	// these change based on what type of action
	
	return AUTH_ERROR;
	
	/*
	COLLECTION_FLAG_OWN,
	COLLECTION_FLAG_PREV_OWN,
	COLLECTION_FLAG_FOR_TRADE,
	COLLECTION_FLAG_WANT_IN_TRADE,
	COLLECTION_FLAG_WANT_TO_BUY,
	COLLECTION_FLAG_WANT_TO_PLAY,
	COLLECTION_FLAG_NOTIFY_CONTENT,
	COLLECTION_FLAG_NOTIFY_SALES,
	COLLECTION_FLAG_NOTIFY_AUCTIONS,
	COLLECTION_FLAG_PREORDED	
	
	if ( flag == COLLECTION_FLAG_OWN ) {
		if ( shouldSet ) {
			[params setObject:@"1" forKey:@"own"];
		}
		else {
			[params setObject:@"0" forKey:@"own"];
		}
	}
	
	// set the game id
	[params setObject:[NSString stringWithFormat:@"%d", gameId] forKey:@"objectid"];
	
	// set the quantity
	[params setObject:[NSString stringWithFormat:@"%d", plays] forKey:@"quantity"];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat: @"yyyy-MM-dd"];
	NSString * datePlayedStr = [dateFormatter stringFromDate:date];
	[dateFormatter release];
	
	// add play date
	[params setObject:datePlayedStr forKey:@"playdate"];
	[params setObject:datePlayedStr forKey:@"dateinput"];
	
	// set the params on request
	worker.params = params;
	[params release];
	
	
	BOOL success = [worker start];
	
	if ( success ) {
		NSString * responseBody = [[NSString alloc] initWithData:worker.responseData encoding:  NSASCIIStringEncoding];
		if ( [responseBody length] > 300 ) {
			return SUCCESS;
		}
	}
	
	return CONNECTION_ERROR;
	
	*/

}

//! update game state in wishlist
- (BGGConnectResponse) saveWishListStateForGameId: (NSInteger) gameId flag: (BGGConnectWishListState) stateToSave  {
	

	
	
}



- (id) init
{
	self = [super init];
	if (self != nil) {
		authCookies = nil;
	}
	return self;
}

- (void) dealloc
{
	[authCookies release];
	[username release];
	[password release];
	[super dealloc];
}


@end