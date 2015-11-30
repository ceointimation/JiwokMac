/*
 *  Delegates.h
 *  Jiwok
 *
 *  Created by reubro R on 30/07/10.
 *  Copyright 2010 kk. All rights reserved.
 *
 */


@protocol FolderIterationDelegate<NSObject>
@required
-(void)didCompleteIteration;
-(void)didStartIteration;
@end



@protocol FolderAdditionDelegate<NSObject>
@required
-(void)didAddFolder;
-(void)searchWindowClosed;
@end


@protocol WorkoutGenerationDelegate<NSObject>
@required
-(void)didSelectGenerate;
-(void)didSelectRemove;
-(void)changeStatus:(NSString *)status;
-(void)generationCompleted;
-(void)generationFailed;

@end


@protocol UserLoggedInDelegate<NSObject>
@required
-(void)checkForAutoDisplaying;
@end



