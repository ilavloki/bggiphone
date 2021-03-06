/*
 Copyright 2010 Petteri Kamppuri
 
 Licensed under the Apache License, Version 2.0 (the "License"); 
 you may not use this file except in compliance with the License. 
 You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 
 
 Unless required by applicable law or agreed to in writing, software distributed under the 
 License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
 either express or implied. See the License for the specific 
 language governing permissions and limitations under the License. 
 */ 

//
//  LoadingViewController.h
//  BGG
//
//  Created by Petteri Kamppuri on 3.1.2010.
//  Copyright 2010 Petteri Kamppuri. All rights reserved.
//

#import <UIKit/UIKit.h>


@class BGGHTMLScraper;


@interface LoadingViewController : UIViewController <UIActionSheetDelegate>
{
	NSArray			*items;
	BOOL			loading;
	BOOL			cancelLoading;
    NSInteger pageNumber;
    BOOL refreshEnabled;
}

@property NSInteger pageNumber;

-(void) startLoading;

@property (nonatomic, readonly, assign, getter=isLoading) BOOL loading;

// Protected methods.

-(void) updateViews;

-(NSString *) urlStringForLoading;
-(id) resultsFromDocument:(NSString *)document withHTMLScraper:(BGGHTMLScraper *)htmlScraper;

-(NSString *) pathForCachedFile;

-(void) cacheResponseData:(NSData *)responseData results:(id)results;
-(NSData *) loadDataFromCache;
- (BOOL) hasCachedData;
-(void) clearCachedData;

- (void) userWantsMoreOrReload;

- (void) userWantsNextPage;

@end
