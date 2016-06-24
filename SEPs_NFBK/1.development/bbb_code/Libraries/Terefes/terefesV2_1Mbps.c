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
/* Channel Pulse Width: 28 ≤ PW ≤ 5000 us    */
/* Pulse width start at 30 us                */
/* Period:              2 ≤ Period ≤ 2000 us */
/*********************************************/


#include <unistd.h>     // UNIX standard function definitions
#include <fcntl.h>      // File control definitions
#include <sys/time.h>   // Select
#include <stdio.h>

#include "terefes.h"


//---
// TEREFES constants, to set the pulse amplitude and width
//---
#define NUMBEROFCHANNELS   32
//-- Amplitude Constants --//
#define MAXAMPLITUD_MA     90          // In mA
#define MAXAMPLITUD        115         // In Counts
#define MINAMPLITUD        0
//-- Pulse Width Constants --//
#define MAXPULSEWIDTH_US   5000.0      // In micro seconds
#define MINPULSEWIDTH_US   28.0      // In micro seconds
//-- Inter and Gloabl time --//
#define MINGROUPTIME       2        // In time period -> 4 count & 500 Hz
#define MAXGROUPTIME       1000     // In time period -> 2000 count & 1 Hz
//-- Convertion parameters --> From Physical values to counts --//
#define AMPLITUDE_CONT     0.78125
#define PULSEWIDTH_SUM     27.6
#define PULSEWIDTH_DIV     2.4
#define TIEMPO_CONT        0.5
#define ENDLINE            13
#define CMD_MAX_LEN        14

   //-- Wait 'x' microseconds between each command --//
   //-- Delete variable to not wait            --//
#define WAIT_AFTER_SEND       100          // in micro seconds
#define WAIT_AFTER_STOPFES    2000         // in micro seconds
#define WAIT_FOR_ANSWER_US    200000       // in micro seconds
#define WAIT_FOR_ANSWER_S     0            // in seconds

#define TEREFESBAUDRATE     B1000000       //1 Mbps


void fcn_PrintCommand(unsigned char cmd[], unsigned char len)
{
   unsigned char i;
   
   printf(">> ");
   for(i=0; i<len; i++){
      printf("%c", cmd[i]);
   }
   printf("\n");
   
}

int fcn_FEScheckChannels(unsigned char ch, unsigned char channel[2])
{
   
   if( (ch<0) || (ch>NUMBEROFCHANNELS) ){
      printf("*** [Error] Channel: %d\tInvalid channel number -> Range: [0-%d] \n", ch,NUMBEROFCHANNELS);
      return -1;
   }else{
      channel[0] = '0'+((ch-1)/10);     // MSB
      channel[1] = '0'+((ch-1)%10);     // LSB
   }
   return 1;
}


void fcn_FESCompleteConstWPartMsg(unsigned char *cmd_index, unsigned char *cmd_fixed, unsigned char cmd[CMD_MAX_LEN], unsigned char channel[2])
{
   
      //-- First Part command is fixed for all command --//
   cmd[(*cmd_index)++] = 119; cmd[(*cmd_index)++] = 32;
   if(channel[0] == '0') cmd[(*cmd_index)++] = channel[1];
   else{
      cmd[(*cmd_index)++] = channel[0];
      cmd[(*cmd_index)++] = channel[1];
   }
   cmd[(*cmd_index)++] = 32;
   *cmd_fixed = *cmd_index;
   
}


void fcn_FEScheckWData(unsigned short int data, unsigned short int i_val, unsigned char *cmd_index, unsigned char cmd[CMD_MAX_LEN])
{
   unsigned char enable_zero, result;
   unsigned short int i, remain;
   
   if (data == 0) {
      cmd[(*cmd_index)++] = '0';
   }else{
      remain = data;
      i = i_val;
      enable_zero = 0;
      while(i > 0){
         result = (unsigned char) (remain/i);
         remain -= (i*result);
         i /= 10;
         if((result) || (enable_zero)){
            cmd[(*cmd_index)++] = result + '0';
            enable_zero = 1;
         }
      }
   }
   
}



   //------------------------------------------------------//
   //---       Full Channel configuration               ---//
   //---       Firmware V1 and V2                        ---//
   //- fd: FES port file descriptor                      --//
   //- Ch: Channel to be configured                      --//
   //- ap, an: positive and negative amplitude in [mV]   --//
   //- tp, tn: positive and negative pulse width in [us] --//
   //- repeat: Channel pulse repetition                  --//
   //- order: pulse order; 0: Pos/Neg; 1: Neg/Pos        --//
int terefes_SetUpChannel(int fd, unsigned char ch, unsigned char ap, unsigned int tp, unsigned char an,
                     unsigned int tn, unsigned char repeat, unsigned char order){
   unsigned char cmd[CMD_MAX_LEN];
   unsigned char channel[2];
   unsigned char cmd_index=0, cmd_fixed;
   unsigned short int count_pw;
   
      //-- Check Channel Number --//
   if(fcn_FEScheckChannels(ch, channel) < 0) return -1;
   
      //-- Channel config decimal values  --//
      // command.ap={119,32,channel[0],channel[1],32,97,112,32,48,48,48,13};
      // command.an={119,32,channel[0],channel[1],32,97,110,32,48,48,48,13};
      // command.tp={119,32,channel[0],channel[1],32,116,112,32,48,48,48,48,48,13};
      // command.tn={119,32,channel[0],channel[1],32,116,110,32,48,48,48,48,48,13};
      // command.re={119,32,channel[0],channel[1],32,114,101,32,48,48,48,13};
      // command.ord={119,32,channel[0],channel[1],32,105,110,32,48,13};
   
      //-- First Part command is fixed for all command --//
   fcn_FESCompleteConstWPartMsg(&cmd_index, &cmd_fixed, cmd, channel);
   
   
      //-- Check Positive Amplitude --//
   cmd_index = cmd_fixed;
   cmd[cmd_index++] = 'a'; cmd[cmd_index++] = 'p'; cmd[cmd_index++] = 32;
   if( (ap<MINAMPLITUD) || (ap>MAXAMPLITUD_MA) ){
      printf("*** [Error] Channel: %d\tInvalid positive amplitude -> Range: [0-%d] mV\n", ch, MAXAMPLITUD_MA);
      return -1;
   }else{
      if(!ap) cmd[cmd_index++] = '0';
      else{
         fcn_FEScheckWData((unsigned short int)(ap/AMPLITUDE_CONT), 100, &cmd_index, cmd);
      }
   }
   cmd[cmd_index] = ENDLINE;
   write(fd, &cmd[0], cmd_index+1);
   fcn_PrintCommand(&cmd[0], cmd_index+1);
   
   usleep(WAIT_AFTER_SEND);
   
   
      //-- Check Negative Amplitude --//
   cmd_index = cmd_fixed;
   cmd[cmd_index++] = 'a'; cmd[cmd_index++] = 'n'; cmd[cmd_index++] = 32;
   if( (an<MINAMPLITUD) || (an>MAXAMPLITUD) ){
      printf("*** [Error] Channel: %d\tInvalid negative amplitude -> Range: [0-%d] mV\n", ch, MAXAMPLITUD);
      return -1;
   }else{
      if(!an) cmd[cmd_index++] = '0';
      else{
         fcn_FEScheckWData((unsigned short int)(an/AMPLITUDE_CONT), 100, &cmd_index, cmd);
      }
   }
   cmd[cmd_index] = ENDLINE;
   write(fd, &cmd[0], cmd_index+1);
   fcn_PrintCommand(&cmd[0], cmd_index+1);
   
   usleep(WAIT_AFTER_SEND);
   
   
      //-- Check Channel Repetition --//
   cmd_index = cmd_fixed;
   cmd[cmd_index++] = 'r'; cmd[cmd_index++] = 'e'; cmd[cmd_index++] = 32;
   if( (repeat<0) || (repeat>255) ){
      printf("*** [Error] Channel: %d\tInvalid repetition -> Range: [0-255]\n", ch);
      return -1;
   }else{
      if(!repeat) cmd[cmd_index++] = '0';
      else{
         fcn_FEScheckWData((unsigned short int)repeat, 100, &cmd_index, cmd);
      }
   }
   cmd[cmd_index] = ENDLINE;
   write(fd, &cmd[0], cmd_index+1);
   fcn_PrintCommand(&cmd[0], cmd_index+1);
   
   usleep(WAIT_AFTER_SEND);
   
   
   
      //-- Check Positive Pulse Width --//
   cmd_index = cmd_fixed;
   cmd[cmd_index++] = 't'; cmd[cmd_index++] = 'p'; cmd[cmd_index++] = 32;
   if( (tp<MINPULSEWIDTH_US) || (tp>MAXPULSEWIDTH_US) ){
      printf("*** [Error] Channel: %d\tInvalid positive Pulse Width -> Range: [%.2f-%.2f] us\n", ch, MINPULSEWIDTH_US,MAXPULSEWIDTH_US);
      return -1;
   }else{
      count_pw = (unsigned short int)((float)(tp-PULSEWIDTH_SUM)/PULSEWIDTH_DIV);
      if(!count_pw) cmd[cmd_index++] = '0';
      else{
         fcn_FEScheckWData(count_pw, 1000, &cmd_index, cmd);
      }
   }
   cmd[cmd_index] = ENDLINE;
   write(fd, &cmd[0], cmd_index+1);
   fcn_PrintCommand(&cmd[0], cmd_index+1);
   
   usleep(WAIT_AFTER_SEND);
   
      //-- Check Negative Pulse Width --//
   cmd_index = cmd_fixed;
   cmd[cmd_index++] = 't'; cmd[cmd_index++] = 'n'; cmd[cmd_index++] = 32;
   if( (tn<MINPULSEWIDTH_US) || (tn>MAXPULSEWIDTH_US) ){
      printf("*** [Error] Channel: %d\tInvalid negative Pulse Width -> Range: [%.2f-%.2f] us\n", ch, MINPULSEWIDTH_US,MAXPULSEWIDTH_US);
      return -1;
   }else{
      count_pw = (unsigned short int)((float)(tn-PULSEWIDTH_SUM)/PULSEWIDTH_DIV);
      if(!count_pw) cmd[cmd_index++] = '0';
      else{
         fcn_FEScheckWData(count_pw, 1000, &cmd_index, cmd);
      }
   }
   cmd[cmd_index] = ENDLINE;
   write(fd, &cmd[0], cmd_index+1);
   fcn_PrintCommand(&cmd[0], cmd_index+1);
   
   usleep(WAIT_AFTER_SEND);
   
   
      //-- Check order --//
   cmd_index = cmd_fixed;
   cmd[cmd_index++] = 'i'; cmd[cmd_index++] = 'n'; cmd[cmd_index++] = 32;
   if( (order<0) || (order>1) ){
      printf("*** [Error] Channel: %d\tInvalid repetition -> Range: [0-255]\n", ch);
      return -1;
   }else{
      cmd[cmd_index++] = '0'+order;
   }
   cmd[cmd_index] = ENDLINE;
   write(fd, &cmd[0], cmd_index+1);
   fcn_PrintCommand(&cmd[0], cmd_index+1);
   
   usleep(WAIT_AFTER_SEND);
   
   return 0;
}



   //-------------------------------------------------------------//
   //--- Modified Channel amplitude Compatible with Terefes V1 ---//
   //---       Firmware V1 and V2                              ---//
   //- fd: FES port file descriptor                            --//
   //- Ch: Channel to be configured                            --//
   //- ap, an: positive and negative amplitude in [mV]         --//

int terefes_SetChannelAmplitude(int fd, unsigned char ch, unsigned char ap, unsigned char an)
{
   unsigned char cmd[CMD_MAX_LEN];
   unsigned char channel[2];
   unsigned char cmd_index=0, cmd_fixed;
   
      //-- Check Channel Number --//
   if(fcn_FEScheckChannels(ch, channel) < 0) return -1;
   
      //-- Channel config decimal values  --//
      // command.ap={119,32,channel[0],channel[1],32,97,112,32,48,48,48,13};
      // command.an={119,32,channel[0],channel[1],32,97,110,32,48,48,48,13};
   
      //-- First Part command is fixed for all command --//
   fcn_FESCompleteConstWPartMsg(&cmd_index, &cmd_fixed, cmd, channel);
   
   
      //-- Check Positive Amplitude --//
   cmd[cmd_index++] = 'a'; cmd[cmd_index++] = 'p'; cmd[cmd_index++] = 32;
   if( (ap<MINAMPLITUD) || (ap>MAXAMPLITUD_MA) ){
      printf("*** [Error] Channel: %d\tInvalid positive amplitude -> Range: [0-%d] mV\n", ch, MAXAMPLITUD_MA);
      return -1;
   }else{
      if(!ap) cmd[cmd_index++] = '0';
      else{
         fcn_FEScheckWData((unsigned short int)(ap/AMPLITUDE_CONT), 100, &cmd_index, cmd);
      }
   }
   cmd[cmd_index] = ENDLINE;
   write(fd, &cmd[0], cmd_index+1);
   fcn_PrintCommand(&cmd[0], cmd_index+1);
   
   usleep(WAIT_AFTER_SEND);
   
      //-- Check Negative Amplitude --//
   cmd_index = cmd_fixed;
   cmd[cmd_index++] = 'a'; cmd[cmd_index++] = 'n'; cmd[cmd_index++] = 32;
   if( (an<MINAMPLITUD) || (an>MAXAMPLITUD) ){
      printf("*** [Error] Channel: %d\tInvalid negative amplitude -> Range: [0-%d] mV\n", ch, MAXAMPLITUD);
      return -1;
   }else{
      if(!an) cmd[cmd_index++] = '0';
      else{
         fcn_FEScheckWData((unsigned short int)(an/AMPLITUDE_CONT), 100, &cmd_index, cmd);
      }
   }
   cmd[cmd_index] = ENDLINE;
   write(fd, &cmd[0], cmd_index+1);
   fcn_PrintCommand(&cmd[0], cmd_index+1);
   
   usleep(WAIT_AFTER_SEND);
   
   
   return 0;
}




   //----------------------------------------------------------------//
   //--- Modified Channel Pulse width Compatible with Terefes V1  ---//
   //---       Firmware V1 and V2                                 ---//
   //- fd: FES port file descriptor                               --//
   //- Ch: Channel to be configured                               --//
   //- tp, tn: positive and negative pulse width in [us]          --//
int terefes_SetChannelPulseWidth(int fd, unsigned char ch, unsigned int tp, unsigned int tn)
{
   unsigned char cmd[CMD_MAX_LEN];
   unsigned char channel[2];
   unsigned char cmd_index=0, cmd_fixed;
   unsigned short int count_pw;
   
      //-- Check Channel Number --//
   if(fcn_FEScheckChannels(ch, channel) < 0) return -1;
   
      //-- Channel config decimal values  --//
      // command.tp={119,32,channel[0],channel[1],32,116,112,32,48,48,48,48,48,13};
      // command.tn={119,32,channel[0],channel[1],32,116,110,32,48,48,48,48,48,13};
   
      //-- First Part command is fixed for all command --//
   fcn_FESCompleteConstWPartMsg(&cmd_index, &cmd_fixed, cmd, channel);
   
   
      //-- Check Positive Pulse Width --//
   cmd[cmd_index++] = 't'; cmd[cmd_index++] = 'p'; cmd[cmd_index++] = 32;
   if( (tp<MINPULSEWIDTH_US) || (tp>MAXPULSEWIDTH_US) ){
      printf("*** [Error] Channel: %d\tInvalid positive Pulse Width -> Range: [%.2f-%.2f] us\n", ch, MINPULSEWIDTH_US,MAXPULSEWIDTH_US);
      return -1;
   }else{
      count_pw = (unsigned short int)((float)(tp-PULSEWIDTH_SUM)/PULSEWIDTH_DIV);
      if(!count_pw) cmd[cmd_index++] = '0';
      else{
         fcn_FEScheckWData(count_pw, 1000, &cmd_index, cmd);
      }
   }
   cmd[cmd_index] = ENDLINE;
   write(fd, &cmd[0], cmd_index+1);
   fcn_PrintCommand(&cmd[0], cmd_index+1);
   
   usleep(WAIT_AFTER_SEND);
   
   
      //-- Check Negative Pulse Width --//
   cmd_index = cmd_fixed;
   cmd[cmd_index++] = 't'; cmd[cmd_index++] = 'n'; cmd[cmd_index++] = 32;
   if( (tn<MINPULSEWIDTH_US) || (tn>MAXPULSEWIDTH_US) ){
      printf("*** [Error] Channel: %d\tInvalid negative Pulse Width -> Range: [%.2f-%.2f] us\n", ch, MINPULSEWIDTH_US,MAXPULSEWIDTH_US);
      return -1;
   }else{
      count_pw = (unsigned short int)((float)(tn-PULSEWIDTH_SUM)/PULSEWIDTH_DIV);
      if(!count_pw) cmd[cmd_index++] = '0';
      else{
         fcn_FEScheckWData(count_pw, 1000, &cmd_index, cmd);
      }
   }
   cmd[cmd_index] = ENDLINE;
   write(fd, &cmd[0], cmd_index+1);
   fcn_PrintCommand(&cmd[0], cmd_index+1);
   
   usleep(WAIT_AFTER_SEND);
   
   return 0;
}



   //-------------------------------------------------------------//
   //--- Write Global Repetitions Compatible with Terefes V1   ---//
   //---       Firmware V1 and V2                              ---//
   //- fd: FES port file descriptor                            --//
   //- rep: Global repetitions; range[0-255]                   --//

int terefes_SetMaxGlobalRepetition(int fd, unsigned char rep){
   unsigned char cmd[CMD_MAX_LEN];
   unsigned char cmd_index=0;
   
      //Command: e rm xxx\n
   cmd[cmd_index++] = 'e'; cmd[cmd_index++] = 32;
   cmd[cmd_index++] = 'r'; cmd[cmd_index++] = 'm';
   cmd[cmd_index++] = 32;
   
      //-- Check Global repetion value --//
   if( (rep<0) || (rep>255) ){
      printf("*** [Error] Invalid global repetitions -> Range: [0-255]\n");
      return -1;
   }else{
      if(!rep) cmd[cmd_index++] = '0';
      else{
         fcn_FEScheckWData((unsigned short int)rep, 100, &cmd_index, cmd);
      }
   }
   cmd[cmd_index] = ENDLINE;
   write(fd, &cmd[0], cmd_index+1);
   fcn_PrintCommand(&cmd[0], cmd_index+1);
   
   usleep(WAIT_AFTER_SEND);
   
   return 0;
}



   //-------------------------------------------------------------------//
   //--- Write InterGroup and global time Compatible with Terefes V1 ---//
   //---       Firmware V1 and V2                                    ---//
   //- tinter: intergroup period in micro seconds                    --//
   //- tglobal: global pulse period in micro seconds;                --//
   //--         it define the stimulation frequency                  --//

int terefes_SetStimulationPeriod(int fd, unsigned int tinter, unsigned int tglobal){
   unsigned char cmd[CMD_MAX_LEN];
   unsigned char cmd_index=0, cmd_fixed;
   unsigned short int count_t;
   
      //-- Comands --//
      // e ti 65565/
      // e tg 65565/
   cmd[cmd_index++] = 'e'; cmd[cmd_index++] = 32;
   cmd[cmd_index++] = 't';
   cmd_fixed = cmd_index;
   
      //-- InterGroup time --> Ti --//
   cmd[cmd_index++] = 'i'; cmd[cmd_index++] = 32;
   if( (tinter<MINGROUPTIME) || (tinter>MAXGROUPTIME) ){
      printf("*** [Error] Invalid Inter Group Time -> Range: [%d-%d] ms\n", MINGROUPTIME, MAXGROUPTIME);
      return -1;
   }else{
      count_t = (unsigned short int)(tinter/TIEMPO_CONT);
      if(!count_t) cmd[cmd_index++] = '0';
      else{
         fcn_FEScheckWData(count_t, 1000, &cmd_index, cmd);
      }
   }
   cmd[cmd_index] = ENDLINE;
   write(fd, &cmd[0], cmd_index+1);
   fcn_PrintCommand(&cmd[0], cmd_index+1);
   
   usleep(WAIT_AFTER_SEND);
   
   
   
      //-- Check Global time --//
   cmd_index = cmd_fixed;
   cmd[cmd_index++] = 'g'; cmd[cmd_index++] = 32;
   if( (tglobal<MINGROUPTIME) || (tglobal>MAXGROUPTIME) ){
      printf("*** [Error] Invalid Global Time -> Range: [%d-%d] ms\n", MINGROUPTIME, MAXGROUPTIME);
      return -1;
   }else{
      count_t = (unsigned short int)(tglobal/TIEMPO_CONT);
      if(!count_t) cmd[cmd_index++] = '0';
      else{
         fcn_FEScheckWData(count_t, 1000, &cmd_index, cmd);
      }
   }
   cmd[cmd_index] = ENDLINE;
   write(fd, &cmd[0], cmd_index+1);
   fcn_PrintCommand(&cmd[0], cmd_index+1);
   
   usleep(WAIT_AFTER_SEND);
   
   return 0;
}




   //-------------------------------------------------------------------//
   //--- Set the number of channels inside the list to be stimulated ---//
   //---       Firmware V1 and V2                                    ---//
   //- fd: FES port file descriptor                                  --//
   //- Len_ch: number of channel in the list to be stimulated        --//
   //--        range [1-32]                                          --//
int terefes_StimulationChannels(int fd, unsigned char len_ch){
   unsigned char cmd[CMD_MAX_LEN];
   unsigned char cmd_index=0;
   
      //-- Comand: >> e fl xx/ --//
   cmd[cmd_index++] = 'e'; cmd[cmd_index++] = 32;
   cmd[cmd_index++] = 'f'; cmd[cmd_index++] = 'l';
   cmd[cmd_index++] = 32;
   
      //-- Check received parameter, must in range [1-32] --//
   if( (len_ch<1) || (len_ch>32) ){
      printf("*** [Error] Invalid fl number -> Range: [0-31]\n");
      return -1;
   }else{
      if ((len_ch-1) > 9) {
         cmd[cmd_index++] = '0'+ (unsigned char)((len_ch-1)/10);          // MSB
         cmd[cmd_index++] = '0'+((len_ch-1)%10);          // LSB
      }else cmd[cmd_index++] = '0'+(len_ch-1);
   }
   cmd[cmd_index] = ENDLINE;
   write(fd, &cmd[0], cmd_index+1);
   fcn_PrintCommand(&cmd[0], cmd_index+1);
   
   usleep(WAIT_AFTER_SEND);
   
   return 0;
}


   //-------------------------------------------------------------------------//
   //--- Add channel to the stimulation list -> Compatible with terefes V1 ---//
   //---       Firmware V1 and V2                                          ---//
   //- fd: FES port file descriptor                                        ---//
   //- ch: channel number to be added in the list                          ---//
   //- pos: position of the list in which the channel will be added        ---//

int terefes_AddChannelToList(int fd, unsigned char ch, unsigned char pos){
   unsigned char cmd[CMD_MAX_LEN];
   unsigned char channel[2], ch_pos[2];
   unsigned char cmd_index=0;
   
      //-- Comand: >> e lc xx xx\n --//
   
   cmd[cmd_index++] = 'e'; cmd[cmd_index++] = 32;
   cmd[cmd_index++] = 'l'; cmd[cmd_index++] = 'c';
   cmd[cmd_index++] = 32;
   
      //-- Check Channel Number --//
   if(fcn_FEScheckChannels(ch, channel) < 0) return -1;
      //-- Check Channel Position --//
   if(fcn_FEScheckChannels(pos, ch_pos) < 0) return -1;
   
   if((ch-1) > 9){
      cmd[cmd_index++] = channel[0];
      cmd[cmd_index++] = channel[1];
   }else cmd[cmd_index++] = channel[1];
   
   cmd[cmd_index++] = 32;
   
   if((pos-1) > 9){
      cmd[cmd_index++] = ch_pos[0];
      cmd[cmd_index++] = ch_pos[1];
   }else cmd[cmd_index++] = ch_pos[1];
   
   cmd[cmd_index] = ENDLINE;
   write(fd, &cmd[0], cmd_index+1);
   fcn_PrintCommand(&cmd[0], cmd_index+1);
   
   usleep(WAIT_AFTER_SEND);
   
   return 0;
}



   //-----------------------------------//
   //-- Turn on stimulation Sourece 1 --//
   //---       Firmware V1 and V2    ---//
int terefes_TurnOnF1(int fd){
   unsigned char cmd[4];
   
      // on1
   cmd[0] = 'o';
   cmd[1] = 'n';
   cmd[2] = '1';
   cmd[3] = ENDLINE;
   
   write(fd, &cmd[0], sizeof(cmd));
   
   usleep(WAIT_AFTER_SEND);
   
   fcn_PrintCommand(&cmd[0], sizeof(cmd));
   
   return 0;
}

   //----------------------------------//
   //-- Turn on stimulation Source 2 --//
   //---       Firmware V1 and V2    --//
int terefes_TurnOnF2(int fd){
   unsigned char cmd[4];
   
      // on2
   cmd[0] = 'o';
   cmd[1] = 'n';
   cmd[2] = '2';
   cmd[3] = ENDLINE;
   
   write(fd, &cmd[0], sizeof(cmd));
   
   usleep(WAIT_AFTER_SEND);
   
   fcn_PrintCommand(&cmd[0], sizeof(cmd));
   
   return 0;
}

   //-----------------------------------//
   //-- Turn off stimulation Source 1 --//
   //---       Firmware V1 and V2    ---//
int terefes_TurnOffF1(int fd){
   unsigned char cmd[5];
   
      // off1
   cmd[0] = 'o';
   cmd[1] = 'f';
   cmd[2] = 'f';
   cmd[3] = '1';
   cmd[4] = ENDLINE;
   
   write(fd, &cmd[0], sizeof(cmd));
   
   usleep(WAIT_AFTER_STOPFES);
   
   fcn_PrintCommand(&cmd[0], sizeof(cmd));
   
   return 0;
}


   //-----------------------------------//
   //-- Turn off stimulation Source 2 --//
   //---       Firmware V1 and V2    ---//
int terefes_TurnOffF2(int fd){
   unsigned char cmd[5];
   
      // off1
   cmd[0] = 'o';
   cmd[1] = 'f';
   cmd[2] = 'f';
   cmd[3] = '2';
   cmd[4] = ENDLINE;
   
   write(fd, &cmd[0], sizeof(cmd));
   
   usleep(WAIT_AFTER_STOPFES);
   
   fcn_PrintCommand(&cmd[0], sizeof(cmd));
   
   return 0;
}


   //-------------------------//
   //-- start Stimulation  ---//
   //-- Firmware V1 and V2 ---//
int terefes_StartStimulation(int fd){
   unsigned char cmd[2];
   
      // Comand: s\n
   cmd[0] = 's';
   cmd[1] = ENDLINE;
   
   write(fd, &cmd[0], sizeof(cmd));
   
   usleep(WAIT_AFTER_SEND);
   
   fcn_PrintCommand(&cmd[0], sizeof(cmd));
   
   return 0;
}

   //-------------------------//
   //-- Stop Stimulation   ---//
   //-- Firmware V1 and V2 ---//
int terefes_StopStimulation(int fd){
   unsigned char cmd[2];
   
      // Comand: p\n
   cmd[0] = 'p';
   cmd[1] = ENDLINE;
   write(fd, &cmd[0], sizeof(cmd));
   
   usleep(WAIT_AFTER_STOPFES);
   
   fcn_PrintCommand(&cmd[0], sizeof(cmd));
   
   return 0;
}



   /**********************************/
   /***  Only for Firmware V2     ***/
   /*********************************/

   //----------------------------------------------------//
   // --- Set Terefes function Mode                   ---//
   //---       Firmware V2                            ---//
   // --- Range: 1-6                                  ---//
   // --- Further details, see Diego Galeano's Manual --//
int terefes_SetConfigurationMode(int fd, unsigned char mode)
{
   unsigned char cmd[7], cmd_index=0;

   cmd[cmd_index++] = 'e'; cmd[cmd_index++] = 32;
   cmd[cmd_index++] = 'm'; cmd[cmd_index++] = 'd';
   cmd[cmd_index++] = 32;
   
   //-- Check Mode Received - Range: [1-6] --//
   if( (mode<1) || (mode>6) ){
      printf("*** [Error] Mode Configuration: %d\tInvalid mode selection -> Range: [1-6]\n", mode);
      return -1;
   }else{
      cmd[cmd_index++] = '0'+mode;
   }
   cmd[cmd_index] = ENDLINE;
   write(fd, &cmd[0], cmd_index+1);
   fcn_PrintCommand(&cmd[0], cmd_index+1);
   
   return 0;
}


   //-------------------------------------------------------------------//
   //--- Modify Positive Channel amplitude of channels included      ---//
   //--- inside the list                                             ---//
   //--- Only for firmware V2                                        ---//
   //--- Further details, see Diego Galeano's Manual                 --//
   //- fd: FES port file descriptor                                  --//
   //- Amp_ch: Channel amplitude, value corresponding to the channel --//
   //-         included in the list                                  --//
   //- len: len of the channel list                                  --//

int terefes_SetFastPositiveChAmp(int fd, unsigned char ampCh[16], unsigned char len)
{
   unsigned char cmd[68];
   unsigned char cmd_index=0, i;
   
   cmd[cmd_index++] = 'f'; cmd[cmd_index++] = 'a';
   cmd[cmd_index++] = 'p'; cmd[cmd_index++] = 32;
   
   //-- Check Positive Amplitude --//
   for (i=0; i<len; i++) {
      if( (ampCh[i]<MINAMPLITUD) || (ampCh[i]>MAXAMPLITUD_MA) ){
         printf("*** [Error] Fast Positive Amplitude\tInvalid positive amplitude; Position: %d -> Range: [0-%d] mV\n", i+1, MAXAMPLITUD_MA);
         return -1;
      }else{
         if(!ampCh[i]) cmd[cmd_index++] = '0';
         else{
            fcn_FEScheckWData((unsigned short int)(ampCh[i]/AMPLITUDE_CONT), 100, &cmd_index, cmd);
         }
      }
      if(i+1 < len) cmd[cmd_index++] = 32;
   }
   cmd[cmd_index] = ENDLINE;
   write(fd, &cmd[0], cmd_index+1);
   fcn_PrintCommand(&cmd[0], cmd_index+1);

   
   return 0;
}



   //-------------------------------------------------------------------//
   //--- Modify Negative Channel amplitude of channels included      ---//
   //--- inside the list                                             ---//
   //--- Only for firmware V2                                        ---//
   //--- Further details, see Diego Galeano's Manual                 --//
   //- fd: FES port file descriptor                                  --//
   //- Amp_ch: Channel amplitude, value corresponding to the channel --//
   //-         included in the list                                  --//
   //- len: len of the channel list                                  --//

int terefes_SetFastNegativeChAmp(int fd, unsigned char ampCh[16], unsigned char len)
{
   unsigned char cmd[68];
   unsigned char cmd_index=0, i;
   
   cmd[cmd_index++] = 'f'; cmd[cmd_index++] = 'a';
   cmd[cmd_index++] = 'n'; cmd[cmd_index++] = 32;
   
      //-- Check Negative Amplitude --//
   for (i=0; i<len; i++) {
      if( (ampCh[i]<MINAMPLITUD) || (ampCh[i]>MAXAMPLITUD_MA) ){
         printf("*** [Error] Fast Positive Amplitude;\tInvalid positive amplitude; Position: %d -> Range: [0-%d] mV\n", i+1, MAXAMPLITUD_MA);
         return -1;
      }else{
         if(!ampCh[i]) cmd[cmd_index++] = '0';
         else{
            fcn_FEScheckWData((unsigned short int)(ampCh[i]/AMPLITUDE_CONT), 100, &cmd_index, cmd);
         }
      }
      if(i+1 < len) cmd[cmd_index++] = 32;
   }
   cmd[cmd_index] = ENDLINE;
   write(fd, &cmd[0], cmd_index+1);
   fcn_PrintCommand(&cmd[0], cmd_index+1);

   
   return 0;
}




   //-------------------------------------------------------------------//
   //--- Modify Positive Pulse Width of channels included            ---//
   //--- inside the list                                             ---//
   //--- Only for firmware V2                                        ---//
   //--- Further details, see Diego Galeano's Manual                 --//
   //- fd: FES port file descriptor                                  --//
   //- PW_ch: Channel amplitude, value corresponding to the channel  --//
   //-         included in the list                                  --//
   //- len: len of the channel list                                  --//
int terefes_SetFastPositivePWidth(int fd, unsigned short int pwCh[16], unsigned char len)
{
   unsigned char cmd[84];
   unsigned char cmd_index=0, i;
   unsigned short int count_pw;
   
   cmd[cmd_index++] = 'f'; cmd[cmd_index++] = 't';
   cmd[cmd_index++] = 'p'; cmd[cmd_index++] = 32;
   
   /*
   printf("Received: ");
   for (i=0; i<len; i++) {
      printf("%d ", pwCh[i]);
   }
   printf("\n");
   */
      //-- Check Positive Pulse Width --//
   for (i=0; i<len; i++) {
      if( (pwCh[i]<MINPULSEWIDTH_US) || (pwCh[i]>MAXPULSEWIDTH_US) ){
         printf("*** [Error] Fast Positive Pulse Width\tInvalid positive Pulse Width; Position: %d -> Range: [%.2f - %.2f] us\n", i+1, MINPULSEWIDTH_US,MAXPULSEWIDTH_US);
         return -1;
      }else{
         count_pw = (unsigned short int)((float)(pwCh[i]-PULSEWIDTH_SUM)/PULSEWIDTH_DIV);
         if(!count_pw) cmd[cmd_index++] = '0';
         else{
            fcn_FEScheckWData(count_pw, 1000, &cmd_index, cmd);
         }
      }
      if(i+1 < len) cmd[cmd_index++] = 32;
   }
   cmd[cmd_index] = ENDLINE;
   write(fd, &cmd[0], cmd_index+1);
   fcn_PrintCommand(&cmd[0], cmd_index+1);
   
   
   return 0;
}



   //-------------------------------------------------------------------//
   //--- Modify Negative Pulse Width of channels included            ---//
   //--- inside the list                                             ---//
   //--- Only for firmware V2                                        ---//
   //--- Further details, see Diego Galeano's Manual                 --//
   //- fd: FES port file descriptor                                  --//
   //- PW_ch: Channel amplitude, value corresponding to the channel  --//
   //-         included in the list                                  --//
   //- len: len of the channel list                                  --//
int terefes_SetFastNegativePWidth(int fd, unsigned short int pwCh[16], unsigned char len)
{
   unsigned char cmd[84];
   unsigned char cmd_index=0, i;
   unsigned short int count_pw;
   
   cmd[cmd_index++] = 'f'; cmd[cmd_index++] = 't';
   cmd[cmd_index++] = 'n'; cmd[cmd_index++] = 32;
   
   
   printf("Received: ");
   for (i=0; i<len; i++) {
      printf("%d ", pwCh[i]);
   }
   printf("\n");
   
      //-- Check Positive Pulse Width --//
   for (i=0; i<len; i++) {
      if( (pwCh[i]<MINPULSEWIDTH_US) || (pwCh[i]>MAXPULSEWIDTH_US) ){
         printf("*** [Error] Fast Negative Pulse Width\tInvalid negative Pulse Width; Position: %d -> Range: [%.2f - %.2f] us\n", i+1, MINPULSEWIDTH_US,MAXPULSEWIDTH_US);
         return -1;
      }else{
         count_pw = (unsigned short int)((float)(pwCh[i]-PULSEWIDTH_SUM)/PULSEWIDTH_DIV);
         if(!count_pw) cmd[cmd_index++] = '0';
         else{
            fcn_FEScheckWData(count_pw, 1000, &cmd_index, cmd);
         }
      }
      if(i+1 < len) cmd[cmd_index++] = 32;
   }
   cmd[cmd_index] = ENDLINE;
   write(fd, &cmd[0], cmd_index+1);
   fcn_PrintCommand(&cmd[0], cmd_index+1);
   
   return 0;
}




/*********************************/
/*** Serial Port Configuration ***/
/*********************************/
/*
int terefes_OpenPort(struct termios *fesOldPort, struct termios *fesNewPort)
{
   int fd; // File descriptor for the port
   
   fd = open(TEREFESDEVICE, O_RDWR|O_NOCTTY|O_SYNC);
      //fd = open(FESDEVICE, O_WRONLY|O_NOCTTY|O_SYNC);
   
   if (fd < 0){
      printf("-... [Error] TEREFES -> FES Port could not be Opened: '%s' [fail: 1]\n", TEREFESDEVICE);
      return -1;
   }else printf("+... TEREFES -> FES Port Opened: '%s'... [ok]\n", TEREFESDEVICE);
   
   tcflush(fd, TCIOFLUSH);
   
   terefes_PortConfig(fd, fesOldPort, fesNewPort);
   
   return (fd);
   
}*/

int terefes_OpenPort(struct termios *fesOldPort, struct termios *fesNewPort, char *device)
{
   int fd; // File descriptor for the port
   
   fd = open(device, O_RDWR|O_NOCTTY|O_SYNC);
      //fd = open(FESDEVICE, O_WRONLY|O_NOCTTY|O_SYNC);
   
   if (fd < 0){
      printf("-... [Error] TEREFES -> FES Port could not be Opened: '%s' [fail: 1]\n", device);
      return -1;
   }else printf("+... TEREFES -> FES Port Opened: '%s'... [ok]\n", device);
   
   tcflush(fd, TCIOFLUSH);
   
   terefes_PortConfig(fd, fesOldPort, fesNewPort);
   
   return (fd);
   
}


/****
 ** FES Serial Port is programed as Non-Canonical Input Processing and Asynchronous Input
 **    - Non-Canonical Input Processing: The read depend of two parameters. See explanation below
 **    - Asynchronous Input: An interrupt function is executed when the read has been fulfilled
 *****/
void terefes_PortConfig(int fd, struct termios *fesOldPort, struct termios *fesNewPort)
{
   
   /** save current port settings **/
   tcgetattr(fd, fesOldPort);
   
   /* set new port settings for canonical input processing
    - BAUDRATE: Set bps rate. You could also use cfsetispeed and cfsetospeed.
    - CS8     : 8n1 (8bit,no parity,1 stopbit)
    - CLOCAL  : local connection, no modem contol
    - CREAD   : enable receiving characters
    - CRTSCTS : output hardware flow control (only used if the cable has
    */
   fesNewPort->c_cflag = TEREFESBAUDRATE | CS8 | CLOCAL | CREAD;
      //fesNewPort->c_cflag = FESBAUDRATE | CS8 | CLOCAL;
   
   /*
    - IGNPAR  : ignore bytes with parity errors
    - ICRNL   : map CR to NL (otherwise a CR input on the other computer will not terminate input)
    - otherwise make device raw (no other input processing)
    */
      //fesNewPort->c_iflag = IGNPAR | ICRNL;
   fesNewPort->c_iflag = IGNPAR;
   fesNewPort->c_oflag = 0;
   
   /*
    ICANON  : enable canonical input
    0: non Canonical input
    */
   fesNewPort->c_lflag = 0;
      //fesNewPort->c_lflag = ICANON;
   
      //fesNewPort->c_cc[VEOF] = 10;
   fesNewPort->c_cc[VMIN] = 1; 		//blocking read until 6 chars received
   fesNewPort->c_cc[VTIME] = 0;		//t = TIME *0.1 seconds
   
   /** Set new Port settings  **/
   tcsetattr(fd, TCSANOW, fesNewPort);
   
   /** Wait 1 seconds **/
   usleep(100000);
   
   /** Clean the serial Port buffer **/
   tcflush(fd, TCIFLUSH);
   
}



/*****************************************/
/*** Terefes configurtion Verification ***/
/*****************************************/

void fcn_WaitTerefesCmdResponse(int fesFD){
   
   unsigned char fin, i;
      // Select
   fd_set readfds;
   unsigned char buf[255];
   struct timeval tv;
   int ret;
   
   fin = 0;
   while(!fin)
   {
      tv.tv_sec = WAIT_FOR_ANSWER_S;
      tv.tv_usec = WAIT_FOR_ANSWER_US;
      FD_ZERO(&readfds);
      FD_SET(fesFD, &readfds);
      ret = select (fesFD+1, &readfds, NULL, NULL, &tv);
      if(ret > 0){
         if (FD_ISSET(fesFD, &readfds)){
            ret = read(fesFD, &buf[0], 255);
            for (i=0; i<ret; i++) {
               printf("%c",buf[i]);
            }
         }
      }else
      {
            //printf("\n");
         fin = 1;
      }
   }
}


/* Check terefes mode configuration */
void terefes_CheckModeConfiguration(int fesFD){
   
   unsigned char cmd[5], cmd_index=0;
   // int ret;
   
      //-- check Mode --//
   cmd[cmd_index++] = 'l'; cmd[cmd_index++] = 32;
   cmd[cmd_index++] = 'm'; cmd[cmd_index++] = 'd';
   cmd[cmd_index++] = 13;
   write(fesFD, &cmd[0], cmd_index);
   printf(">> %c%c%c\n",cmd[0],cmd[1],cmd[2]);
   
      //-- Wait response --//
   fcn_WaitTerefesCmdResponse(fesFD);

}


/* Check terefes mode configuration */
int terefes_CheckChannelConfiguration(int fesFD, unsigned ch){
   
   unsigned char cmd[5], cmd_index=0;
   unsigned char channel[2];
   //int ret
   
      //-- Check Channel Number --//
   if(fcn_FEScheckChannels(ch, channel) < 0) return -1;
   
      //-- check Mode --//
   cmd[cmd_index++] = 'r'; cmd[cmd_index++] = 32;
   if(channel[0] > 0){
      cmd[cmd_index++] = channel[0]; cmd[cmd_index++] = channel[1];
   }else{
      cmd[cmd_index++] = channel[1];
   }
   cmd[cmd_index++] = 13;
   write(fesFD, &cmd[0], cmd_index);
   
   if(channel[0] > 0) printf(">> %c%c%c%c\n",cmd[0],cmd[1],cmd[2],cmd[3]);
   else printf(">> %c%c%c\n",cmd[0],cmd[1],cmd[2]);
   
      //-- Wait response --//
   fcn_WaitTerefesCmdResponse(fesFD);
   
   return 1;
   
}



/* Check terefes mode configuration */
void terefes_CheckGroupConfiguration(int fesFD){
   
   unsigned char cmd[5], cmd_index=0;
      //int ret;
   
   //-- check ti --//
   cmd[cmd_index++] = 'l'; cmd[cmd_index++] = 32;
   cmd[cmd_index++] = 't'; cmd[cmd_index++] = 'i';
   cmd[cmd_index++] = 13;
   write(fesFD, &cmd[0], cmd_index);
   
   printf(">> %c%c%c%c\n",cmd[0],cmd[1],cmd[2],cmd[3]);
   
   fcn_WaitTerefesCmdResponse(fesFD);
   
   
      //-- check tg --//
   cmd_index=0;
   cmd[cmd_index++] = 'l'; cmd[cmd_index++] = 32;
   cmd[cmd_index++] = 't'; cmd[cmd_index++] = 'g';
   cmd[cmd_index++] = 13;
   write(fesFD, &cmd[0], cmd_index);
   
   printf(">> %c%c%c%c\n",cmd[0],cmd[1],cmd[2],cmd[3]);
   
   fcn_WaitTerefesCmdResponse(fesFD);
   
   
      //-- check lc --//
   cmd_index=0;
   cmd[cmd_index++] = 'l'; cmd[cmd_index++] = 32;
   cmd[cmd_index++] = 'l'; cmd[cmd_index++] = 'c';
   cmd[cmd_index++] = 13;
   write(fesFD, &cmd[0], cmd_index);
   
   printf(">> %c%c%c%c\n",cmd[0],cmd[1],cmd[2],cmd[3]);
   
   fcn_WaitTerefesCmdResponse(fesFD);
   
   
      //-- check fl --//
   cmd_index=0;
   cmd[cmd_index++] = 'l'; cmd[cmd_index++] = 32;
   cmd[cmd_index++] = 'f'; cmd[cmd_index++] = 'l';
   cmd[cmd_index++] = 13;
   write(fesFD, &cmd[0], cmd_index);
   
   printf(">> %c%c%c%c\n",cmd[0],cmd[1],cmd[2],cmd[3]);
   
   fcn_WaitTerefesCmdResponse(fesFD);
   
   
      //-- check rm --//
   cmd_index=0;
   cmd[cmd_index++] = 'l'; cmd[cmd_index++] = 32;
   cmd[cmd_index++] = 'r'; cmd[cmd_index++] = 'm';
   cmd[cmd_index++] = 13;
   write(fesFD, &cmd[0], cmd_index);
   
   printf(">> %c%c%c%c\n",cmd[0],cmd[1],cmd[2],cmd[3]);
   
   fcn_WaitTerefesCmdResponse(fesFD);
   
}
