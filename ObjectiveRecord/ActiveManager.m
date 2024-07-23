//
//  ActiveManager.m
//  Shopify_Mobile
//
//  Created by Matthew Newberry on 8/2/10.
//  Copyright 2010 Shopify. All rights reserved.
//

#import "ActiveManager.h"
#import "ActiveConnection.h"
#import "NSThread+Blocks.m"

#define OR_CORE_DATE_STORE_TYPE		NSSQLiteStoreType
#define OR_CORE_DATE_STORE_NAME		@"CoreDataStore.sqlite"
#define OR_CORE_DATE_BATCH_SIZE		25
#define OR_MOC_KEY                  @"managedObjectContext"
#define OR_CORE_DATA_MIGRATION_NEED @"coreDataMigrationNeeded"
#define OR_SEED_DIR                 @"Seeds"

static ActiveManager *_shared = nil;

@implementation ActiveManager

@synthesize remoteContentFormat = _remoteContentFormat;
@synthesize remoteContentType = _remoteContentType;
@synthesize parsingClass = _parsingClass;
@synthesize baseRemoteURL = _baseRemoteURL;
@synthesize connectionClass = _connectionClass;
@synthesize logLevel = _logLevel;
@synthesize defaultDateParser = _defaultDateParser;
@synthesize defaultNumberFormatter = _defaultNumberFormatter;
@synthesize entityDescriptions = _entityDescriptions;
@synthesize modelProperties = _modelProperties;
@synthesize modelRelationships = _modelRelationships;
@synthesize modelAttributes = _modelAttributes;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize fixtureParsingClass = _fixtureParsingClass;

+ (ActiveManager *) shared{
    	
	if(_shared == nil)
		_shared = [[ActiveManager alloc] init];
	
	return _shared;
}

- (id) init{
	
	if((self = [super init])){
		
		self.remoteContentType = @"application/json";
		self.remoteContentFormat = @"json";
	
		self.managedObjectModel = [self managedObjectModel];
		self.persistentStoreCoordinator = [self persistentStoreCoordinator];
		_managedObjectContext = [self newManagedObjectContext];
		
		_defaultDateParser = [[NSDateFormatter alloc] init];
		[_defaultDateParser setTimeZone:[NSTimeZone localTimeZone]];
        
        _defaultNumberFormatter = [[NSNumberFormatter alloc] init];
        
		self.entityDescriptions = [NSMutableDictionary dictionary];
        self.modelProperties = [NSMutableDictionary dictionary];
        self.modelRelationships = [NSMutableDictionary dictionary];
		
		self.logLevel = 2;
	}
	
	return self;
}

- (void) setConnectionClass:(id)activeConnectionClass{
	
	_connectionClass = activeConnectionClass;
}

- (void) addRequest:(ActiveRequest *) request{
	
	[self addRequest:request delegate:request.delegate didParseObjectSelector:request.didParseObjectSelector didFinishSelector:request.didFinishSelector didFailSelector:request.didFailSelector];
}

- (void) addBaseURL:(ActiveRequest *)request{
	
	[request setUrlPath:[[ActiveManager shared].baseRemoteURL stringByAppendingString:request.urlPath]];
}

- (void) addRequest:(ActiveRequest *) request delegate:(id) delegate didParseObjectSelector:(SEL)didParseObjectSelector didFinishSelector:(SEL)didFinishSelector didFailSelector:(SEL)didFailSelector{
	
	if([request.urlPath rangeOfString:@"http"].length == 0)
		[self addBaseURL:request];
	    
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{

		id <ActiveConnection> conn = [[[_connectionClass alloc] init] autorelease];
		[conn setResponseDelegate:delegate];
		[conn setDidFinishSelector:didFinishSelector];
		[conn setDidFailSelector:didFailSelector];
		
		[conn send:request];
	});
}

- (void) addRequest:(ActiveRequest *) request didParseObjectBlock:(ActiveConnectionDidParseObjectBlock)didParseObjectBlock didFinishBlock:(ActiveConnectionBlock)didFinishBlock didFailBlock:(ActiveConnectionBlock)didFailBlock{
	
	[self addRequest:request toQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0) didParseObjectBlock:didParseObjectBlock didFinishBlock:didFinishBlock didFailBlock:didFailBlock];
}

- (void) addRequest:(ActiveRequest *) request toQueue:(dispatch_queue_t)queue didParseObjectBlock:(ActiveConnectionDidParseObjectBlock)didParseObjectBlock didFinishBlock:(ActiveConnectionBlock)didFinishBlock didFailBlock:(ActiveConnectionBlock)didFailBlock
{
	[self addRequest:request toQueue:queue group:nil didParseObjectBlock:didParseObjectBlock didFinishBlock:didFinishBlock didFailBlock:didFailBlock];
}

- (void) addRequest:(ActiveRequest *) request toQueue:(dispatch_queue_t)queue group:(dispatch_group_t)group didParseObjectBlock:(ActiveConnectionDidParseObjectBlock)didParseObjectBlock didFinishBlock:(ActiveConnectionBlock)didFinishBlock didFailBlock:(ActiveConnectionBlock)didFailBlock
{	
	if ([request.urlPath rangeOfString:@"http"].length == 0) {
		[self addBaseURL:request];
	}
	
	dispatch_block_t block = ^{
		NSObject <ActiveConnection> *conn = [[_connectionClass alloc] init];
        [conn setResponseDelegate:request.delegate];
        [conn setDidFailBlock:didFailBlock];
        [conn setDidFinishBlock:didFinishBlock];
        [conn setDidParseObjectBlock:didParseObjectBlock];
        
        [conn send:request];
        [conn release];
	};
	
	if (group) {
		dispatch_group_async(group, queue, block);
	}
	else if (dispatch_get_current_queue() == queue) {
        block();
    }
	else {
        dispatch_async(queue, block);
	}
}

- (ActiveResult *) addSyncronousRequest:(ActiveRequest *)request{
	
	if([request.urlPath rangeOfString:@"http"].length == 0)
		[self addBaseURL:request];
	
	return [[[_connectionClass new] autorelease] performSelector:@selector(sendSyncronously:) withObject:request];
}

- (void) addSyncronousRequest:(ActiveRequest *)request delegate:(id) delegate didFinishSelector:(SEL)didFinishSelector didFailSelector:(SEL)didFailSelector{
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if([request.urlPath rangeOfString:@"http"].length == 0)
		[self addBaseURL:request];
	
	ActiveResult *result = [[[_connectionClass new] autorelease] performSelector:@selector(sendSyncronously:) withObject:request];
	
	if(result.error != nil)
		[delegate performSelector:didFinishSelector withObject:result];
	else
		[delegate performSelector:didFailSelector withObject:result];
	
	[pool release];
}

- (void) addSyncronousRequest:(ActiveRequest *)request didFinishBlock:(ActiveConnectionBlock)didFinishBlock didFailBlock:(ActiveConnectionBlock)didFailBlock{
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if([request.urlPath rangeOfString:@"http"].length == 0)
		[self addBaseURL:request];
	
	ActiveResult *result = [[[_connectionClass new] autorelease] performSelector:@selector(sendSyncronously:) withObject:request];
	
	if(result.error != nil)
		[NSThread performBlockOnMainThread:^{
			didFinishBlock(result);
		}];
	else
		[NSThread performBlockOnMainThread:^{
			didFailBlock(result);
		}];
	
	[pool release];
}



- (NSData *) serializeObject:(id)object{
	
	id <ActiveParser> parser = [[[_parsingClass alloc] init] autorelease];
	NSString *string = [parser parseToString:object];
	
	return [string dataUsingEncoding:NSUTF8StringEncoding];
}

- (id) parseString:(NSString *) content{
    
    id <ActiveParser> parser = [[[_parsingClass alloc] init] autorelease];
    return [parser parse:content];
}

- (id) parseFixture:(NSString *) content{
    
    if(_fixtureParsingClass != nil){
        id <ActiveParser> parser = [[[_fixtureParsingClass alloc] init] autorelease];
        return [parser parse:content];
    }
    else
        return [self parseString:content];
}


/*	Core Data		*/

- (void) managedObjectContextDidSave:(NSNotification *)notification{
            
	[self.managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
												withObject:notification
											 waitUntilDone:YES];
}

- (void)mergeChanges:(NSNotification *)notification {

	[self performSelectorOnMainThread:@selector(managedObjectContextDidSave:) withObject:notification waitUntilDone:YES];
}

- (NSManagedObjectContext*) newManagedObjectContext
{	
	NSManagedObjectContext *moc = nil;
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0f) {
		moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
	}
	else {
		moc = [[NSManagedObjectContext alloc] init];	
	}
	
	[moc setPersistentStoreCoordinator:self.persistentStoreCoordinator];
	[moc setUndoManager:nil];
	[moc setMergePolicy:NSOverwriteMergePolicy];
    
	//Start observing this Managed Object Context
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeChanges:) name:NSManagedObjectContextDidSaveNotification object:moc];
	
	return moc;
}

- (NSManagedObjectContext*) managedObjectContext
{	
	if ([NSThread isMainThread]) {
		return _managedObjectContext;
		
	} else {
		
		NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
		NSManagedObjectContext *backgroundThreadContext = [threadDictionary objectForKey:OR_MOC_KEY];
		
		if (!backgroundThreadContext) {
			
			backgroundThreadContext = [self newManagedObjectContext];					
			[threadDictionary setObject:backgroundThreadContext forKey:OR_MOC_KEY];			
			[backgroundThreadContext release];
		}
        
		return backgroundThreadContext;
	}
}


- (NSManagedObjectModel*) managedObjectModel {
    
	if( _managedObjectModel != nil )
		return _managedObjectModel;
    
    NSURL *momURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"Shopify_Mobile" ofType:@"momd"]];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];

    
    if(_managedObjectModel == nil)
        _managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
	
	return _managedObjectModel;
}

- (NSString*) storePath {
	return [[self applicationDocumentsDirectory]
			stringByAppendingPathComponent: OR_CORE_DATE_STORE_NAME];
}


- (NSURL*) storeUrl {
	return [NSURL fileURLWithPath:[self storePath]];
}


- (NSDictionary*) migrationOptions {
	
	return $D([NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption);
}


- (NSPersistentStoreCoordinator*) persistentStoreCoordinator {
	if( _persistentStoreCoordinator != nil ) {
		return _persistentStoreCoordinator;
	}
	
	NSString* storePath = [self storePath];
	NSURL *storeUrl = [self storeUrl];
    
    NSError* error;
	
	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
								  initWithManagedObjectModel: _managedObjectModel];
	
	NSDictionary* options = [self migrationOptions];
	
	// Check whether the store already exists or not.
	NSFileManager* fileManager = [NSFileManager defaultManager];
	BOOL exists = [fileManager fileExistsAtPath:storePath];
	
	if(!exists ) {
		_modelCreated = YES;
	} else {
		if( _resetModel ||
		   [[NSUserDefaults standardUserDefaults] boolForKey:@"erase_all_preference"] ) {
			[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"erase_all_preference"];
			[fileManager removeItemAtPath:storePath error:nil];
			_modelCreated = YES;
		}
	}
    
    BOOL compatible = [_managedObjectModel isConfiguration:nil compatibleWithStoreMetadata:[NSPersistentStoreCoordinator metadataForPersistentStoreOfType:OR_CORE_DATE_STORE_TYPE URL:storeUrl error:&error]];
    
    if(!compatible)
        [[NSNotificationCenter defaultCenter] postNotificationName:OR_CORE_DATA_MIGRATION_NEED object:nil];
	
	if (![_persistentStoreCoordinator
		  addPersistentStoreWithType: OR_CORE_DATE_STORE_TYPE
		  configuration: nil
		  URL: storeUrl
		  options: options
		  error: &error
		  ]) {
		// We couldn't add the persistent store, so let's wipe it out and try again.
		[fileManager removeItemAtPath:storePath error:nil];
		_modelCreated = YES;
		
		if (![_persistentStoreCoordinator
			  addPersistentStoreWithType: OR_CORE_DATE_STORE_TYPE
			  configuration: nil
			  URL: storeUrl
			  options: options
			  error: &error
			  ]) {
			// Something is terribly wrong here.
		}
	}
	
	return _persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


+ (NSArray *) seedFiles{
    
   return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:$S(@"%@/%@", [[NSBundle bundleForClass:[self class]] bundlePath], OR_SEED_DIR) error:nil]; 
}

- (BOOL) loadAllSeedFiles{
    
    return [self loadSeedFilesForGroupName:nil];
}

- (BOOL) loadSeedFilesForGroupName:(NSString *) groupName{
        
    return [self loadSeedFiles:[[self class] seedFiles] groupName:groupName];
}

- (BOOL) loadSeedFiles:(NSArray *) files groupName:(NSString *) groupName{
    
    NSError *error = nil;
    
    for(NSString *file in files){
        
        NSString *content = [NSString stringWithContentsOfFile:$S(@"%@/%@/%@", [[NSBundle bundleForClass:[self class]] bundlePath], OR_SEED_DIR, file) encoding:NSUTF8StringEncoding error:&error];

        id value = [self parseFixture:content];
        
        if(value == nil){
            
            error = [NSError errorWithDomain:@"com.objectiverecord" code:1 userInfo:$D(file, content)];
            continue;
        }
                        
        NSMutableString *class = [NSMutableString stringWithString:[[[file stringByDeletingPathExtension] componentsSeparatedByString:@"_"] objectAtIndex:0]];
        [class replaceOccurrencesOfString:[ActiveRecord classPrefix] withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [[ActiveRecord classPrefix] length])];
        
        Class modelClass = NSClassFromString(class);
        [modelClass removeAll];
        
        if([value isKindOfClass:[NSDictionary class]]){
                        
            [value enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                
                if(groupName == nil || (groupName != nil && [groupName isEqualToString:key]))
                    [modelClass build:obj];
            }];
        }
        else if(groupName == nil)
            [modelClass build:value];
        
    }
    
    [ActiveRecord save];
    
    return error == nil;
}


- (id)copyWithZone:(NSZone *)zone	{
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (oneway void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

- (void)dealloc{
	[_managedObjectContext release];
	[_managedObjectModel release];
	[_persistentStoreCoordinator release];

	[_defaultDateParser release];
    [_defaultNumberFormatter release];
	[_entityDescriptions release];
	[_modelProperties release];
	[_modelRelationships release];
	[_modelAttributes release];
	[_baseRemoteURL release];

	[_parsingClass release];
    [_fixtureParsingClass release];
	[_remoteContentType release];
	[_remoteContentFormat release];

	[super dealloc];
}

@end
