//
//  S7FTPRequest.m
//  S7FtpClient
//
//  Created by Aleks Nesterow on 10/28/09.
//  aleks.nesterow@gmail.com
//	
//	Inspired by http://allseeing-i.com/ASIHTTPRequest/
//	Was using code samples from http://developer.apple.com/iphone/library/samplecode/SimpleFTPSample/index.html
//	and http://developer.apple.com/mac/library/samplecode/CFFTPSample/index.html
//  
//  Copyright © 2009, 7touch Group, Inc.
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  * Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//  * Neither the name of the 7touchGroup, Inc. nor the
//  names of its contributors may be used to endorse or promote products
//  derived from this software without specific prior written permission.
//  
//  THIS SOFTWARE IS PROVIDED BY 7touchGroup, Inc. "AS IS" AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL 7touchGroup, Inc. BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//  

#import "S7FTPRequest.h"

NSString *const S7FTPRequestErrorDomain = @"S7FTPRequestErrorDomain";

static NSError *S7FTPRequestTimedOutError;
static NSError *S7FTPAuthenticationError;
static NSError *S7FTPRequestCancelledError;
static NSError *S7FTPUnableToCreateRequestError;

static NSOperationQueue *sharedRequestQueue = nil;

@interface S7FTPRequest (/* Private */)

@property (nonatomic, retain) NSOutputStream *writeStream;
@property (nonatomic, retain) NSInputStream *readStream;
@property (nonatomic, retain) NSDate *timeOutDate;
@property (nonatomic, retain) NSRecursiveLock *cancelledLock;

- (void)applyCredentials;
- (void)cleanUp;
- (NSError *)constructErrorWithCode:(NSInteger)code message:(NSString *)message;
- (void)failWithError:(NSError *)error;
- (void)initializeComponentWithURL:(NSURL *)ftpURL operation:(S7FTPRequestOperation)operation;
- (BOOL)isComplete;
- (void)requestFinished;
- (void)setStatus:(S7FTPRequestStatus)status;
- (void)startUploadRequest;
- (void)handleUploadEvent:(NSStreamEvent)eventCode;
- (void)startCreateDirectoryRequest;
- (void)handleCreateDirectoryEvent:(NSStreamEvent)eventCode;
- (void)resetTimeout;

@end

@implementation S7FTPRequest

@synthesize delegate = _delegate, didFinishSelector = _didFinishSelector, didFailSelector = _didFailSelector;
@synthesize willStartSelector = _willStartSelector, didChangeStatusSelector = _didChangeStatusSelector, bytesWrittenSelector = _bytesWrittenSelector;
@synthesize fileSize = _fileSize, bytesWritten = _bytesWritten, error = _error;
@synthesize operation = _operation;
@synthesize userInfo = _userInfo;
@synthesize username = _username, password = _password;
@synthesize ftpURL = _ftpURL, filePath = _filePath, directoryName = _directoryName;
@synthesize status = _status;

@synthesize timeOutSeconds = _timeOutSeconds;
@synthesize timeOutDate = _timeOutDate;
@synthesize cancelledLock = _cancelledLock;

- (void)setStatus:(S7FTPRequestStatus)status {
	NSLog(@"Now you are in setStatus method in S7FTPRequest class");
	if (_status != status) {
		_status = status;
		if (self.didChangeStatusSelector && [self.delegate respondsToSelector:self.didChangeStatusSelector]) {
			[self.delegate performSelectorOnMainThread:self.didChangeStatusSelector withObject:self waitUntilDone:[NSThread isMainThread]];
		}
	}
    NSLog(@"Now you are completed setStatus method in S7FTPRequest class");
}

/* Private */
@synthesize writeStream = _writeStream, readStream = _readStream;

#pragma mark init / dealloc

+ (void)initialize {
	NSLog(@"Now you are in initialize method in S7FTPRequest class");
	if (self == [S7FTPRequest class]) {
		
		S7FTPRequestTimedOutError = [[NSError errorWithDomain:S7FTPRequestErrorDomain
														 code:S7FTPRequestTimedOutErrorType
													 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
															   NSLocalizedString(@"The request timed out.", @""),
															   NSLocalizedDescriptionKey, nil]] retain];	
		S7FTPAuthenticationError = [[NSError errorWithDomain:S7FTPRequestErrorDomain
														code:S7FTPAuthenticationErrorType
													userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
															  NSLocalizedString(@"Authentication needed.", @""),
															  NSLocalizedDescriptionKey, nil]] retain];
		S7FTPRequestCancelledError = [[NSError errorWithDomain:S7FTPRequestErrorDomain
														  code:S7FTPRequestCancelledErrorType
													  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																NSLocalizedString(@"The request was cancelled.", @""),
																NSLocalizedDescriptionKey, nil]] retain];
		S7FTPUnableToCreateRequestError = [[NSError errorWithDomain:S7FTPRequestErrorDomain
															   code:S7FTPUnableToCreateRequestErrorType
														   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																	 NSLocalizedString(@"Unable to create request (bad url?)", @""),
																	 NSLocalizedDescriptionKey,nil]] retain];
	}
	
	[super initialize];
    NSLog(@"Now you are completed initialize method in S7FTPRequest class");
}

- (id)init {
	NSLog(@"Now you are in init method in S7FTPRequest class");
	if (self = [super init]) {
		[self initializeComponentWithURL:nil operation:S7FTPRequestOperationDownload];
	}
	
	return self;
    NSLog(@"Now you are completed init method in S7FTPRequest class");
}

- (id)initWithURL:(NSURL *)ftpURL toDownloadFile:(NSString *)filePath {
	NSLog(@"Now you are in initWithURL:(NSURL *)ftpURL toDownloadFile:(NSString *)filePath  method in S7FTPRequest class");
	if (self = [super init]) {
		[self initializeComponentWithURL:ftpURL operation:S7FTPRequestOperationDownload];
		self.filePath = filePath;
	}
	
	return self;
    NSLog(@"Now you are completed initWithURL:(NSURL *)ftpURL toDownloadFile:(NSString *)filePath  method in S7FTPRequest class");
}

- (id)initWithURL:(NSURL *)ftpURL toUploadFile:(NSString *)filePath {
	NSLog(@"Now you are in (id)initWithURL:(NSURL *)ftpURL toUploadFile:(NSString *)filePath method in S7FTPRequest class");
	if (self = [super init]) {
		[self initializeComponentWithURL:ftpURL operation:S7FTPRequestOperationUpload];
		self.filePath = filePath;
	}
	
	return self;
    NSLog(@"Now you are completed (id)initWithURL:(NSURL *)ftpURL toUploadFile:(NSString *)filePath method in S7FTPRequest class");
}

- (id)initWithURL:(NSURL *)ftpURL toCreateDirectory:(NSString *)directoryName {
	NSLog(@"Now you are in (id)initWithURL:(NSURL *)ftpURL toCreateDirectory:(NSString *)directoryName method in S7FTPRequest class");
	if (self = [super init]) {
		[self initializeComponentWithURL:ftpURL operation:S7FTPRequestOperationCreateDirectory];
		self.directoryName = directoryName;
	}
	
	return self;
    NSLog(@"Now you are completed (id)initWithURL:(NSURL *)ftpURL toCreateDirectory:(NSString *)directoryName method in S7FTPRequest class");
}

- (void)initializeComponentWithURL:(NSURL *)ftpURL operation:(S7FTPRequestOperation)operation {
	NSLog(@"Now you are in initializeComponentWithURL method in S7FTPRequest class");
	self.ftpURL = ftpURL;
	self.operation = operation;
	self.timeOutSeconds = 10;
	self.cancelledLock = [[[NSRecursiveLock alloc] init] autorelease];
    NSLog(@"Now you are completed initializeComponentWithURL method in S7FTPRequest class");
}

+ (id)requestWithURL:(NSURL *)ftpURL toDownloadFile:(NSString *)filePath {
	NSLog(@"Now you are in (id)requestWithURL:(NSURL *)ftpURL toDownloadFile:(NSString *)filePath method in S7FTPRequest class");
	return [[[self alloc] initWithURL:ftpURL toDownloadFile:filePath] autorelease];
    NSLog(@"Now you are completed (id)requestWithURL:(NSURL *)ftpURL toDownloadFile:(NSString *)filePath method in S7FTPRequest class");
}

+ (id)requestWithURL:(NSURL *)ftpURL toUploadFile:(NSString *)filePath {
	NSLog(@"Now you are in (id)requestWithURL:(NSURL *)ftpURL toUploadFile:(NSString *)filePath method in S7FTPRequest class");
	return [[[self alloc] initWithURL:ftpURL toUploadFile:filePath] autorelease];
    NSLog(@"Now you are completed (id)requestWithURL:(NSURL *)ftpURL toUploadFile:(NSString *)filePath method in S7FTPRequest class");
}

+ (id)requestWithURL:(NSURL *)ftpURL toCreateDirectory:(NSString *)directoryName {
	NSLog(@"Now you are in (id)requestWithURL:(NSURL *)ftpURL toCreateDirectory:(NSString *)directoryName method in S7FTPRequest class");
	return [[[self alloc] initWithURL:ftpURL toCreateDirectory:directoryName] autorelease];
    NSLog(@"Now you are completed (id)requestWithURL:(NSURL *)ftpURL toCreateDirectory:(NSString *)directoryName method in S7FTPRequest class");
}

- (void)dealloc {
	
	[_writeStream release];
	[_readStream release];
	
	[_error release];
	
	[_userInfo release];
	
	[_username release];
	[_password release];
	
	[_ftpURL release];
	[_filePath release];
	[_directoryName release];
	
	[_cancelledLock release];
	
	[super dealloc];
}

#pragma mark Request logic

- (void)applyCredentials {
	NSLog(@"Now you are in applyCredentials method in S7FTPRequest class");
	if (self.username) {
		if (![self.writeStream setProperty:self.username forKey:(id)kCFStreamPropertyFTPUserName]) {
			[self failWithError:
			 [self constructErrorWithCode:S7FTPInternalErrorWhileApplyingCredentialsType
								  message:[NSString stringWithFormat:
										   NSLocalizedString(@"Cannot apply the username \"%@\" to the FTP stream.", @""),
										   self.username]]];
			return;
		}
		if (![self.writeStream setProperty:self.password forKey:(id)kCFStreamPropertyFTPPassword]) {
			[self failWithError:
			 [self constructErrorWithCode:S7FTPInternalErrorWhileApplyingCredentialsType
								  message:[NSString stringWithFormat:
										   NSLocalizedString(@"Cannot apply the password \"%@\" to the FTP stream.", @""),
										   self.password]]];
			return;
		}
	}
    NSLog(@"Now you are completed applyCredentials method in S7FTPRequest class");
}

- (void)cancel {
	NSLog(@"Now you are in cancel method in S7FTPRequest class");
	[[self cancelledLock] lock];
	
	/* Request may already be complete. */
	if ([self isComplete] || [self isCancelled]) {
		return;
	}
	
	[self cancelRequest];
	
	[[self cancelledLock] unlock];
	
	/* Must tell the operation to cancel after we unlock, as this request might be dealloced and then NSLock will log an error. */
	[super cancel];
    NSLog(@"Now you are completed cancel method in S7FTPRequest class");
}

- (void)main {
	NSLog(@"Now you are in main method in S7FTPRequest class");
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[[self cancelledLock] lock];
	
	[self startRequest];
	[self resetTimeout];
	
	[[self cancelledLock] unlock];
	
	/* Main loop */
	while (![self isCancelled] && ![self isComplete]) {
		
		[[self cancelledLock] lock];
		
		/* Do we need to timeout? */
		if ([[self timeOutDate] timeIntervalSinceNow] < 0) {
			[self failWithError:S7FTPRequestTimedOutError];
			break;
		}
		
		[[self cancelledLock] unlock];
		
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[self timeOutDate]];
	}
	
	[pool release];
    NSLog(@"Now you are completed main method in S7FTPRequest class");
}

- (void)resetTimeout
{
    NSLog(@"Now you are in resetTimeout method in S7FTPRequest class");
	[self setTimeOutDate:[NSDate dateWithTimeIntervalSinceNow:[self timeOutSeconds]]];
    NSLog(@"Now you are completed resetTimeout method in S7FTPRequest class");
}

- (void)cancelRequest {
	NSLog(@"Now you are in cancelRequest method in S7FTPRequest class");
	[self failWithError:S7FTPRequestCancelledError];
    NSLog(@"Now you are completed cancelRequest method in S7FTPRequest class");
}

- (void)startRequest {
	NSLog(@"Now you are in startRequest method in S7FTPRequest class");
	_complete = NO;
	_fileSize = 0;
	_bytesWritten = 0;
	_status = S7FTPRequestStatusNone;
	
	switch (self.operation) {
		case S7FTPRequestOperationUpload:
			[self startUploadRequest];
			break;
		case S7FTPRequestOperationCreateDirectory:
			[self startCreateDirectoryRequest];
			break;
	}
    NSLog(@"Now you are completed startRequest method in S7FTPRequest class");
}

- (void)startAsynchronous
{
    NSLog(@"Now you are in startAsynchronous method in S7FTPRequest class");
	[[S7FTPRequest sharedRequestQueue] addOperation:self];
    NSLog(@"Now you are completed startAsynchronous method in S7FTPRequest class");
}


- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
	NSLog(@"Now you are in (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode method in S7FTPRequest class");
	[[self cancelledLock] lock];
	
    assert(stream == self.writeStream);
	
	[self resetTimeout];
	
	switch (self.operation) {
		case S7FTPRequestOperationUpload:
			[self handleUploadEvent:eventCode];
			break;
		case S7FTPRequestOperationCreateDirectory:
			[self handleCreateDirectoryEvent:eventCode];
			break;
	}
	
	[[self cancelledLock] unlock];
    NSLog(@"Now you are completed (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode method in S7FTPRequest class");
}

#pragma mark Upload logic

- (void)startUploadRequest {
	NSLog(@"Now you are in startUploadRequest method in S7FTPRequest class");
	if (!self.ftpURL || !self.filePath) {
		[self failWithError:S7FTPUnableToCreateRequestError];
		return;
	}
	
	CFStringRef fileName = (CFStringRef)[self.filePath lastPathComponent];
	if (!fileName) {
		[self failWithError:
		 [self constructErrorWithCode:S7FTPInternalErrorWhileBuildingRequestType
							  message:[NSString stringWithFormat:
									   NSLocalizedString(@"Unable to retrieve file name from file located at %@", @""),
									   self.filePath]]];
		return;
	}
	
	CFURLRef uploadUrl = CFURLCreateCopyAppendingPathComponent(kCFAllocatorDefault, (CFURLRef)self.ftpURL, fileName, false);
	if (!uploadUrl) {
		[self failWithError:[self constructErrorWithCode:S7FTPInternalErrorWhileBuildingRequestType
												 message:NSLocalizedString(@"Unable to build URL to upload.", @"")]];
		return;
	}
	
	NSError *attributesError = nil;
	NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.filePath error:&attributesError];
	if (attributesError) {
		[self failWithError:attributesError];
		return;
	} else {
		_fileSize = [fileAttributes fileSize];
		if (self.willStartSelector && [self.delegate respondsToSelector:self.willStartSelector]) {
			[self.delegate performSelectorOnMainThread:self.willStartSelector withObject:self waitUntilDone:[NSThread isMainThread]];
		}
	}
	
	self.readStream = [NSInputStream inputStreamWithFileAtPath:self.filePath];
	if (!self.readStream) {
		[self failWithError:
		 [self constructErrorWithCode:S7FTPUnableToCreateRequestErrorType
							  message:[NSString stringWithFormat:
									   NSLocalizedString(@"Cannot start reading the file located at %@ (bad path?).", @""),
									   self.filePath]]];
		return;
	}
	
	[self.readStream open];
	
	CFWriteStreamRef uploadStream = CFWriteStreamCreateWithFTPURL(NULL, uploadUrl);
	if (!uploadStream) {
		[self failWithError:
		 [self constructErrorWithCode:S7FTPUnableToCreateRequestErrorType
							  message:[NSString stringWithFormat:
									   NSLocalizedString(@"Cannot open FTP connection to %@", @""),
									   (NSURL *)uploadUrl]]];
		CFRelease(uploadUrl);
		return;
	}
	CFRelease(uploadUrl);
	
	self.writeStream = (NSOutputStream *)uploadStream;
	[self applyCredentials];
	self.writeStream.delegate = self;
	[self.writeStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[self.writeStream open];
	
	CFRelease(uploadStream);
    NSLog(@"Now you are completed startUploadRequest method in S7FTPRequest class");
}

- (void)handleUploadEvent:(NSStreamEvent)eventCode {
	NSLog(@"Now you are in handleUploadEvent method in S7FTPRequest class");
	switch (eventCode) {
        case NSStreamEventOpenCompleted: {
			[self setStatus:S7FTPRequestStatusOpenNetworkConnection];
        } break;
        case NSStreamEventHasSpaceAvailable: {
			
            /* If we don't have any data buffered, go read the next chunk of data. */
            if (_bufferOffset == _bufferLimit) {
				
				[self setStatus:S7FTPRequestStatusReadingFromStream];
                NSInteger bytesRead = [self.readStream read:_buffer maxLength:kS7FTPRequestBufferSize];
                if (bytesRead == -1) {
					[self failWithError:
					 [self constructErrorWithCode:S7FTPConnectionFailureErrorType
										  message:[NSString stringWithFormat:
												   NSLocalizedString(@"Cannot continue reading the file at %@", @""),
												   self.filePath]]];
					return;
				} else if (bytesRead == 0) {
					[self requestFinished];
					return;
                } else {
                    _bufferOffset = 0;
                    _bufferLimit = bytesRead;
                }
            }
            
            /* If we're not out of data completely, send the next chunk. */
            
            if (_bufferOffset != _bufferLimit) {
				
                _bytesWritten = [self.writeStream write:&_buffer[_bufferOffset] maxLength:_bufferLimit - _bufferOffset];
                assert(_bytesWritten != 0);
                
				if (_bytesWritten == -1) {
					
					[self failWithError:
					 [self constructErrorWithCode:S7FTPConnectionFailureErrorType
										  message:NSLocalizedString(@"Cannot continue writing file to the specified URL at the FTP server.", @"")]];
					return;
                } else {
					
					[self setStatus:S7FTPRequestStatusWritingToStream];
					
					if (self.bytesWrittenSelector && [self.delegate respondsToSelector:self.bytesWrittenSelector]) {
						[self.delegate performSelectorOnMainThread:self.bytesWrittenSelector withObject:self waitUntilDone:[NSThread isMainThread]];
					}
					
                    _bufferOffset += _bytesWritten;
                }
            }
        } break;
        case NSStreamEventErrorOccurred: {
			[self failWithError:[self constructErrorWithCode:S7FTPConnectionFailureErrorType
													 message:NSLocalizedString(@"Cannot open FTP connection.", @"")]];
        } break;
        case NSStreamEventEndEncountered: {
			/* Ignore */
        } break;
        default: {
            assert(NO);
        } break;
    }
    NSLog(@"Now you are completed handleUploadEvent method in S7FTPRequest class");
}

- (void)startCreateDirectoryRequest {
	
	
	NSLog(@"Now you are in startCreateDirectoryRequest method in S7FTPRequest class");
	
	if (!self.ftpURL || !self.directoryName) {
		[self failWithError:S7FTPUnableToCreateRequestError];
		return;
	}
	
	CFURLRef createUrl = CFURLCreateCopyAppendingPathComponent(NULL, (CFURLRef)self.ftpURL, (CFStringRef)self.directoryName, true);
	if (!createUrl) {
		[self failWithError:[self constructErrorWithCode:S7FTPInternalErrorWhileBuildingRequestType
												 message:NSLocalizedString(@"Unable to build URL to create directory.", @"")]];
		return;
	}
	
	CFWriteStreamRef createStream = CFWriteStreamCreateWithFTPURL(NULL, createUrl);
	if (!createStream) {
		[self failWithError:
		 [self constructErrorWithCode:S7FTPUnableToCreateRequestErrorType
							  message:[NSString stringWithFormat:
									   NSLocalizedString(@"Cannot open FTP connection to %@", @""),
									   (NSURL *)createUrl]]];
		CFRelease(createUrl);
		return;
	}
	CFRelease(createUrl);
	
	self.writeStream = (NSOutputStream *)createStream;
	[self applyCredentials];
	self.writeStream.delegate = self;
	[self.writeStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[self.writeStream open];
	
	CFRelease(createStream);
    NSLog(@"Now you are completed startCreateDirectoryRequest method in S7FTPRequest class");
}

- (void)handleCreateDirectoryEvent:(NSStreamEvent)eventCode {
	NSLog(@"Now you are in handleCreateDirectoryEvent method in S7FTPRequest class");
	switch (eventCode) {
        case NSStreamEventOpenCompleted: {
			[self setStatus:S7FTPRequestStatusOpenNetworkConnection];
            /* Despite what it says in the documentation <rdar://problem/7163693>, 
             * you should wait for the NSStreamEventEndEncountered event to see 
             * if the directory was created successfully.  If you shut the stream 
             * down now, you miss any errors coming back from the server in response 
             * to the MKD command. */
        } break;
        case NSStreamEventHasBytesAvailable: {
            assert(NO); /* Should never happen for the output stream. */
        } break;
        case NSStreamEventHasSpaceAvailable: {
            assert(NO);
        } break;
        case NSStreamEventErrorOccurred: {
            /* -streamError does not return a useful error domain value, so we 
             * get the old school CFStreamError and check it. */
			CFStreamError err = CFWriteStreamGetError((CFWriteStreamRef)self.writeStream);
            if (err.domain == kCFStreamErrorDomainFTP) {
                [self failWithError:
				 [self constructErrorWithCode:S7FTPConnectionFailureErrorType
									  message:[NSString stringWithFormat:NSLocalizedString(@"FTP error %d", @""), (int)err.error]]];
            } else {
				[self failWithError:
				 [self constructErrorWithCode:S7FTPConnectionFailureErrorType
									  message:NSLocalizedString(@"Cannot open FTP connection.", @"")]];
            }
        } break;
        case NSStreamEventEndEncountered: {
			[self requestFinished];
        } break;
        default: {
            assert(NO);
        } break;
    }
	NSLog(@"Now you are completed handleCreateDirectoryEvent method in S7FTPRequest class");
}

#pragma mark Complete / Failure

- (NSError *)constructErrorWithCode:(NSInteger)code message:(NSString *)message {
	NSLog(@"Now you are in constructErrorWithCode method in S7FTPRequest class");
	return [NSError errorWithDomain:S7FTPRequestErrorDomain
							   code:code
						   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:message, NSLocalizedDescriptionKey, nil]];
    NSLog(@"Now you are completed constructErrorWithCode method in S7FTPRequest class");
}

- (BOOL)isComplete {
	NSLog(@"Now you are in isComplete method in S7FTPRequest class");
	return _complete;
    NSLog(@"Now you are completed isComplete method in S7FTPRequest class");
}

- (BOOL)isFinished {
	NSLog(@"Now you are in isFinished method in S7FTPRequest class");
	return [self isComplete];
    NSLog(@"Now you are completed isFinished method in S7FTPRequest class");
}

- (void)requestFinished {
	NSLog(@"Now you are in requestFinished method in S7FTPRequest class");
	_complete = YES;
	[self cleanUp];
	
	[self setStatus:S7FTPRequestStatusClosedNetworkConnection];
	
	if (self.didFinishSelector && [self.delegate respondsToSelector:self.didFinishSelector]) {
		[self.delegate performSelectorOnMainThread:self.didFinishSelector withObject:self waitUntilDone:[NSThread isMainThread]];
	}
    NSLog(@"Now you are completed requestFinished method in S7FTPRequest class");
}

- (void)failWithError:(NSError *)error {
	
	NSLog(@"Now you are in failWithError method in S7FTPRequest class");
	
	_complete = YES;
	
	if (self.error != nil || [self isCancelled]) {
		return;
	}
	
	self.error = error;
	[self cleanUp];
	[self setStatus:S7FTPRequestStatusError];
	
	if (self.didFailSelector && [self.delegate respondsToSelector:self.didFailSelector]) {
		[self.delegate performSelectorOnMainThread:self.didFailSelector withObject:self waitUntilDone:[NSThread isMainThread]];
	}
    NSLog(@"Now you are completed failWithError method in S7FTPRequest class");
}

- (void)cleanUp {
	NSLog(@"Now you are in cleanUp method in S7FTPRequest class");
	if (self.writeStream != nil) {
        [self.writeStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.writeStream.delegate = nil;
        [self.writeStream close];
        self.writeStream = nil;
    }
    if (self.readStream != nil) {
        [self.readStream close];
        self.readStream = nil;
    }
    NSLog(@"Now you are completed cleanUp method in S7FTPRequest class");
}

+ (NSOperationQueue *)sharedRequestQueue
{
    NSLog(@"Now you are in sharedRequestQueue method in S7FTPRequest class");
	if (!sharedRequestQueue) {
		sharedRequestQueue = [[NSOperationQueue alloc] init];
		[sharedRequestQueue setMaxConcurrentOperationCount:4];
	}
	return sharedRequestQueue;
    NSLog(@"Now you are completed sharedRequestQueue method in S7FTPRequest class");
}

@end
