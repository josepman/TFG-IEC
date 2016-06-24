
/***********************************************
 ****** TEREFES  Communication            ******
 ****** Firmware V1 and V2                ******
 ****** Author: Francisco Resquin         ******
 ****** NRG - CSIC                        ******
 ****** Update: 15/12/2015                ******
  -- DO NOT REDISTRIBUTE WITHOUT PERMISSION --
 **********************************************/

/*********************************************/
/*          Maximum values                   */
/* Channel Amplitude:   0 ≤ Amp ≤ 89 mA      */
/* Channel Pulse Width: 30 ≤ PW ≤ 5000 us    */
/* Period:              2 ≤ Period ≤ 2000 us */
/*********************************************/

#ifndef ____terefes__
#define ____terefes__


//--- Global Variables ---//

/* Libraries */
#include <termios.h>
//#include "globalVar.h"

#ifndef uint16_t
typedef unsigned short int    uint16_t;
#endif

#ifndef int16_t
typedef short int             int16_t;
#endif

#ifndef uchar_t
typedef unsigned char         uchar_t;
#endif

#ifndef uint8_t
typedef unsigned char         uint8_t;
#endif



/***********************************************/
/*** Functions Definitions                   ***/
/*** See library manual or                   ***/
/*** terefesV2_1Mbps.c for further details   ***/
/***********************************************/

/*----------------------*/
/*-- Firmware V1 & V2 --*/
/*----------------------*/
int terefes_SetUpChannel(int fd, unsigned char ch, unsigned char ap, unsigned int tp, unsigned char an,
                         unsigned int tn, unsigned char repeat, unsigned char order);
int terefes_SetChannelAmplitude(int fd, unsigned char ch, unsigned char ap, unsigned char an);
int terefes_SetChannelPulseWidth(int fd, unsigned char ch, unsigned int tp, unsigned int tn);
int terefes_SetMaxGlobalRepetition(int fd, unsigned char rep);
int terefes_SetStimulationPeriod(int fd, unsigned int tinter, unsigned int tglobal);
int terefes_StimulationChannels(int fd, unsigned char len_ch);
int terefes_AddChannelToList(int fd, unsigned char ch, unsigned char pos);
int terefes_TurnOnF1(int fd);
int terefes_TurnOnF2(int fd);
int terefes_TurnOffF1(int fd);
int terefes_TurnOffF2(int fd);
int terefes_StartStimulation(int fd);
int terefes_StopStimulation(int fd);
/*--------------------------*/
/*-- Only for firmware V2 --*/
/*--------------------------*/
int terefes_SetConfigurationMode(int fd, unsigned char mode);
int terefes_SetFastPositiveChAmp(int fd, unsigned char ampCh[16], unsigned char len);
int terefes_SetFastNegativeChAmp(int fd, unsigned char ampCh[16], unsigned char len);
int terefes_SetFastPositivePWidth(int fd, unsigned short int pwCh[16], unsigned char len);
int terefes_SetFastNegativePWidth(int fd, unsigned short int pwCh[16], unsigned char len);
/*-------------------------------*/
/*-- Serial Port Configuration --*/
/*-------------------------------*/
//int terefes_OpenPort(struct termios *fesOldPort, struct termios *fesNewPort);
int terefes_OpenPort(struct termios *fesOldPort, struct termios *fesNewPort, char *device);
void terefes_PortConfig(int fd, struct termios *fesOldPort, struct termios *fesNewPort);

/*-------------------------------------*/
/*-- Terefes Parameters verification --*/
/*-- Firmware V1 & V2                --*/
/*-------------------------------------*/
void terefes_CheckModeConfiguration(int fesFD);
int terefes_CheckChannelConfiguration(int fesFD, unsigned ch);
void terefes_CheckGroupConfiguration(int fesFD);

#endif /* defined(____terefes__) */
