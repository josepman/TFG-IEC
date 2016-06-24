   //------------------------------------------------------
   //  High level controller (HLC)
   //  Developed for bike stimulation paradigm
   //
   //  Created by Francisco Resquin on 14/12/15.
   //  email: franresquin@gmail.com
   //  Neural Rehabilitation group - Cajal Institute
   //
   //  --- DO NOT REDISTRIBUTE WITHOUT PERMISSION ---
   //------------------------------------------------------

#ifndef _MyLib_h
#define _MyLib_h

   //GENERALS Libraries
#include <stdio.h>
#include <stdlib.h>           //exit(0);
#include <string.h>           //memset(), memcpy()
#include <unistd.h>           // Close(), Read(), write(), Select()
#include <stdint.h>
#include <math.h>
#include <iostream>
using namespace std;
// Select
#include <sys/select.h>
#include <sys/time.h>         // Select()
#include <time.h>

/*** FES system ***/
#include "terefes.h"

/*** GPIO ***/
#include "SimpleGPIO.h"
///*** IntFES ***/
//#include "IntFES.h"
/*** FES_Control ***/
//#include "FES_Control.h"

   //Libraries
#include "Timer.h"


#endif
