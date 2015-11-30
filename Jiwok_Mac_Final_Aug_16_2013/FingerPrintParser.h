//
//  FingerPrintParser.h
//  Jiwok_Coredata_Trial
//
//  Created by APPLE on 05/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FingerPrintParser : NSObject {
	
	NSXMLParser * dataParser;
	// holds the XML entities 
	NSMutableArray * entities;
	// a temporary entity holder added to the "entities" array for each parsed entity
	NSMutableDictionary * entity;
	// Used to track each item to be added to the "entities" array
	NSString * currentElement;
	// Entity properties 
	//NSMutableString *response, *id_eval, *satis_global, *e_qua_prix, *e_rapidite, *e_cui_plaisir, *e_decoration, *e_negatif, *e_positif, *path,		*nbFriends, *nbFavorites, *nbWantToGo, *favoriteDishes, *photo, *etabLike, *etabDislike, *firstName, *lastName, *memberId;
	
	NSMutableString *artist,*title,*url;
	/*
	,*workout_title,*workout_desc,*pop_rock,*rnb,*house_electro,*rap,*techno_rave,*funk_disco_soul,*world_music,*workout_flex_id,*user_id,*program_id,*workout_advice_title,*workout_provide,*program_objective,*program_description,*program_coach,*program_title,*workout_duration,*french_dates,*subscription_expiry,*program_title_url;
	*/
	 
	// Checks the main root
	NSString * entityRoot;
	
	int counter;	
	
	bool isAlbumName;

}

// used to initialize object
-(id) initObject;
// used to initialize the object
-(NSMutableArray *)startDataParsing:(NSData *)data;
// returns the resulting data of the parsed xml file
-(NSMutableArray *) getData;
// Used for XML data parsing
- (void)parseXMLData:(NSData *)dataXml;


@end
