/********************************************************
 ****** BeagleBone Example                         ******
 ****** TEREFES library Verification               ******
 ****** Author: Francisco Resquín                  ******
 ****** NRG - CSIC                                 ******
 ********************************************************/


#define max(x,y) ((x) > (y) ? (x) : (y))
#include "globalvar.h"
#include "MyLib.h"

void pause(int dur);

int main()
{
   /* Ask current amp. */
   int inputnum;
   unsigned char current;
   //cout << "enter (integer) current" << endl;
   //cin >> inputnum;
   current = (unsigned char) 3;
   
   /* GPIO channel def. */
   unsigned int SYNCHGPIO = 23;   // P8_13: GPIO0_23 = (0x32) + 23 = 23

   /* Setting GPIO pin */
   gpio_export(SYNCHGPIO);    // The synch. pin
   gpio_set_dir(SYNCHGPIO, OUTPUT_PIN);   // The synch. pin is an output
   
   /* FES device */
   int fesFD;
   struct termios fesOldPort, fesNewPort;
   
   /* Program */
   unsigned char ret;
   
   /* Select */
   fd_set readfds;
   //int max_fd;
   
   printf("+... Hello BeagleBone ... [OK]\n");
   
   /* 1- OPEN Serial Port for FES Communitation */
   //fesFD = terefes_OpenPort(&fesOldPort, &fesNewPort);
   fesFD = terefes_OpenPort(&fesOldPort, &fesNewPort, TEREFESDEVICE);
   if(fesFD < 0){
      printf("\n\t-... [Error] Please Connect the Stimulator to the Beaglebone!!!\n");
      return -1;
   }
   printf("+... Serial port Config done ... [OK]\n");
   
   
   //Get current configuration
   //ret = terefes_CheckChannelConfiguration(fesFD, CH1);
   //terefes_CheckGroupConfiguration(fesFD);
   
   /* 2- Terefes Channel configuration */
   ret = terefes_SetUpChannel(fesFD,CH1, current, 1000, 0, 28, 0, 1);
   ret = terefes_SetMaxGlobalRepetition(fesFD, 2);
   ret = terefes_SetStimulationPeriod(fesFD, 3, 2000);
   ret = terefes_AddChannelToList(fesFD,CH1, 1);
   ret = terefes_StimulationChannels(fesFD,1);
   
   //Verify FES Configuration
   ret = terefes_CheckChannelConfiguration(fesFD, CH1);
   terefes_CheckGroupConfiguration(fesFD);
   
   /* 3- FES On */
   ret = terefes_TurnOnF1(fesFD);
   
   // 5 iterations on-off of FES
   pause(2);
   for (int i = 0; i < 5; ++i)
   {
      gpio_set_value(SYNCHGPIO, HIGH);
      ret = terefes_StartStimulation(fesFD);
//      pause(5);
      usleep(8020);
      ret = terefes_StopStimulation(fesFD);
      gpio_set_value(SYNCHGPIO, LOW);
      pause(5);
   }
   
   //-- Stop FES --//
   ret = terefes_TurnOffF1(fesFD);
   
   printf("Program END... [ok]\n");
   
   //-- restore the old port settings --//
   tcsetattr(fesFD,TCSANOW,&fesOldPort);
   
   /* Release Timer File Descriptor */
   close(fesFD);
   
   return 0;
   
}


void pause(int dur)
{
   int temp = time(NULL) + dur;
   
   while(temp > time(NULL));
}