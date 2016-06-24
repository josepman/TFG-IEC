   //------------------------------------------------------
   //  Timers Functions
   //
   //  Created by: F. Resquin
   //  Date: 9/8/2015
   //  email: franresquin@gmail.com
   //  Neural Rehabilitation Group - Cajal Institute
   //
   //  --- DO NOT REDISTRIBUTE WITHOUT PERMISSION ---
   //------------------------------------------------------

/* Include Libraries */
#include <stdio.h>
#include <unistd.h>


#include "Timer.h"
   //#include "../globalVar.h"



int timer_TimerConfig(struct itimerspec *new_value, int oneshoot_sec, int oneshoot_nsec, int period_sec,int period_nsec)
{
   int fd;
   
      // set the expiration time
   new_value->it_value.tv_sec = oneshoot_sec;
   new_value->it_value.tv_nsec = oneshoot_nsec;
      // set the period of the timer
   new_value->it_interval.tv_sec = period_sec;
   new_value->it_interval.tv_nsec = period_nsec;
   
      // create the timer, monolitic and nonBlocking mode
      //timerfd = timerfd_create(CLOCK_MONOTONIC, TFD_NONBLOCK);
   fd = timerfd_create(CLOCK_MONOTONIC, 0);
   if (fd == -1)
   {
      printf("--- Timer could not be created ...[fail]\n");
   }
   
   return fd;
}




int timer_StartTimer(int fd, struct itimerspec *new_value)
{
   
   // start the timer execution
   if (timerfd_settime(fd, 0, new_value, NULL) == -1)
   {
      printf("--- Timer could not be started ...[fail]\n");
      return -1;
   }//else printf("+ Timer started... [ok]\n");
   
   return 0;
}


int timer_StartTimerV1(int oneshoot_sec, int oneshoot_nsec, int period_sec,int period_nsec)
{
   int fd;
   struct itimerspec new_value;
   
      // Verify values
   if((oneshoot_sec < 0) || (oneshoot_nsec < 0) || (period_nsec < 0) || (period_nsec < 0))
   {
      printf("-...[ERROR] timer_StartTimerV1 --> Wrong Timer configuration, parameter must be bigger than 0\n");
      return -1;
   }
   // set the expiration time
   new_value.it_value.tv_sec = oneshoot_sec;
   new_value.it_value.tv_nsec = oneshoot_nsec;
      // set the period of the timer
   new_value.it_interval.tv_sec = period_sec;
   new_value.it_interval.tv_nsec = period_nsec;
   
      // create the timer, monolitic and nonBlocking mode
   fd = timerfd_create(CLOCK_MONOTONIC, 0);
   if (fd == -1)
   {
      printf("--- Timer could not be created ...[fail]\n");
      return -1;
   }
   
      // start the timer execution
   if (timerfd_settime(fd, 0, &new_value, NULL) == -1)
   {
      printf("--- Timer could not be started ...[fail]\n");
      return -1;
   }//else printf("+ Timer started... [ok]\n");
   
   return fd;
}



int timer_StopTimer(int fd)
{
   struct itimerspec new_value;
   
      // set the expiration time
   new_value.it_value.tv_sec = 0;
   new_value.it_value.tv_nsec = 0;
      // set the period of the timer
   new_value.it_interval.tv_sec = 0;
   new_value.it_interval.tv_nsec = 0;
   
      // start the timer execution
   if (timerfd_settime(fd, 0, &new_value, NULL) == -1)
   {
      printf("--- Timer could not be started ...[fail]\n");
      return -1;
   }//else printf("+ Timer started... [ok]\n");
   
   return fd;
}
