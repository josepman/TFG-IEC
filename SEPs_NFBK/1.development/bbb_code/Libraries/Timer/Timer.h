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

#ifndef ____Timer__
#define ____Timer__

#include <sys/timerfd.h>
#include <time.h>

#include "globalvar.h"

/* Define Constants Values */


/* FUNCTIONS definitions */
int timer_TimerConfig(struct itimerspec *new_value, int oneshoot_sec, int oneshoot_nsec, int period_sec,int period_nsec);
int timer_StartTimer(int fd, struct itimerspec *new_value);
int timer_StartTimerV1(int oneshoot_sec, int oneshoot_nsec, int period_sec,int period_nsec);
int timer_StopTimer(int fd);


#endif /* defined(____Timer__) */
