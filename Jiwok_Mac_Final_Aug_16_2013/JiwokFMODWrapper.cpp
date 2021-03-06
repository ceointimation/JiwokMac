/*
 *  JiwokFMODWrapper.cpp
 *  Jiwok
 *
 *  Created by reubro R on 04/08/10.
 *  Copyright 2010 kk. All rights reserved.
 *
 */

#include "JiwokFMODWrapper.h"
#include "BPMDetect.h"

JiwokFMODWrapper::JiwokFMODWrapper()
{
	return;
}
void ERRCHECK(FMOD_RESULT result)
{
    if (result != FMOD_OK)
    {
		printf("FMOD error! (%d) %s\n", result, FMOD_ErrorString(result));
    }
}

float JiwokFMODWrapper::GetBPM(const char *filename)
{
 	FMOD_SYSTEM     *system;
	FMOD_SOUND      *sound;
	FMOD_RESULT       result;
	unsigned int      version;
	
	result = FMOD_System_Create(&system);
	ERRCHECK(result);
	
	result = FMOD_System_GetVersion(system, &version);
	ERRCHECK(result);
	
	if (version < FMOD_VERSION)
	{
		//printf("Error!  You are using an old version of FMOD %08x.  This program requires %08x\n", version, FMOD_VERSION);
		return 0;
	}
	
	result = FMOD_System_Init(system, 1, FMOD_INIT_NORMAL, 0);
	
	ERRCHECK(result);
	
	result = FMOD_System_CreateStream(system,filename, FMOD_OPENONLY | FMOD_ACCURATETIME, 0, &sound);
	// ERRCHECK(result);
	
	
	unsigned int  length = 0;
	int channels = 0, bits = 0;
	float frequency = 0;
	float volume = 0, pan = 0;
	int priority = 0;
	
	FMOD_SOUND_TYPE stype;
	FMOD_SOUND_FORMAT format;
	
	result = FMOD_Sound_GetLength(sound, &length, FMOD_TIMEUNIT_PCMBYTES);
	ERRCHECK(result);
	
	result = FMOD_Sound_GetDefaults(sound, &frequency, &volume, &pan, &priority);
	ERRCHECK(result);
	
	result = FMOD_Sound_GetFormat(sound, &stype, &format, &channels, &bits);
	ERRCHECK(result);
	
	printf("result is %d",result);
	
	
	soundtouch::BPMDetect *bpm = new soundtouch::BPMDetect(channels,frequency);
	
	//void *data;
	//unsigned int read;
	unsigned int bytesread;
	
	#define CHUNKSIZE 32768 //4096
	
//	#define CHUNKSIZE 4096
	
	
	bytesread = 0;
	soundtouch::SAMPLETYPE* samples = new soundtouch::SAMPLETYPE[CHUNKSIZE];
	int sbytes = bits / 8;
	const unsigned int  NUMSAMPLES = CHUNKSIZE;
	unsigned int  bytes = NUMSAMPLES * sbytes;
	unsigned int  readbytes = 0;
	
	do
	{
		readbytes = 0;
		if(sbytes == 2) 
		{
			long int data[32768];
			result = FMOD_Sound_ReadData(sound, data, bytes, &readbytes );
			if(!result == FMOD_OK) break;
			for ( unsigned int  i = 0; i < readbytes/sbytes; ++i )
				samples[i] = (float) data[i] / 32768;
		} 
		else if(sbytes == 1) 
		{
			long int data[32768];
			result = FMOD_Sound_ReadData(sound, data, bytes, &readbytes );
			if(!result == FMOD_OK) break;
			for ( unsigned int  i = 0; i < (readbytes); ++i )
				samples[i] = (float) data[i] / 128;
		}
		
		bpm->inputSamples(samples, (readbytes /sbytes)/ channels );
		
		bytesread += readbytes;
	}
	while (result == FMOD_OK && readbytes == CHUNKSIZE*2);
	
	result = FMOD_Sound_Release(sound);
	ERRCHECK(result);
	result = FMOD_System_Close(system);
	ERRCHECK(result);
	result = FMOD_System_Release(system);
	ERRCHECK(result);
	
	float bpmg = bpm->getBpm();
	
	float bpm1 = bpmg;
	
	
	if ( bpmg < 1 ) return 0.;
	while ( bpmg > 190 ) bpmg /= 2.;
	while ( bpmg < 50 ) bpmg *= 2.;
	
	
	printf("bpmg bpmg is %f  bpm %f",bpmg,bpm1);

	
	return  bpmg;
}
unsigned int JiwokFMODWrapper::GetLength(const char *filename)
{
    
	FMOD_SYSTEM     *system;
	FMOD_SOUND      *sound;
	FMOD_RESULT       result;
	unsigned int      version;
	
	result = FMOD_System_Create(&system);
	ERRCHECK(result);
	
	result = FMOD_System_GetVersion(system, &version);
	ERRCHECK(result);
	
	if (version < FMOD_VERSION)
	{
		//printf("Error!  You are using an old version of FMOD %08x.  This program requires %08x\n", version, FMOD_VERSION);
		return 0;
	}
	
	result = FMOD_System_Init(system, 1, FMOD_INIT_NORMAL, 0);
	
	ERRCHECK(result);
	
	result = FMOD_System_CreateStream(system,filename, FMOD_OPENONLY | FMOD_ACCURATETIME, 0, &sound);
	// ERRCHECK(result);
	
	unsigned int length = 0;
	
	result = FMOD_Sound_GetLength(sound, &length, FMOD_TIMEUNIT_MS);
	ERRCHECK(result);

	
	result = FMOD_Sound_Release(sound);
	ERRCHECK(result);
	result = FMOD_System_Close(system);
	ERRCHECK(result);
	result = FMOD_System_Release(system);
	ERRCHECK(result);
	
	return length;
}