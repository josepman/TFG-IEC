
CC=arm-linux-gnueabihf-g++ -g

# Set file localization
# Hose Machine (Ubuntu) Directorios origen
LOCALDIR=/home/hose/SEPs_NFBK/1.development/bbb_code/applications/terefes_com_hrefs/Sources
BUILDDIR=/home/hose/SEPs_NFBK/1.development/bbb_code/applications/terefes_com_hrefs/build
MYLIBDIR=/home/hose/SEPs_NFBK/1.development/bbb_code/Libraries

# Compilacion en BeagleBone
#LOCALDIR=/home/ubuntu/Documents/SEPs_NFBK/1.Development/bbb_code/applications/terefes_com_hrefs/Sources
#BUILDDIR=/home/ubuntu/Documents/SEPs_NFBK/1.development/bbb_code/applications/terefes_com_hrefs/build
#MYLIBDIR=/home/ubuntu/Documents/SEPs_NFBK/1.development/bbb_code/Libraries/
 

BEAGLEIP=192.168.7.2
BEAGLEDIR=/home/ubuntu/Documents

TIMERDIR=$(MYLIBDIR)/Timer
GPIODIR=$(MYLIBDIR)/GPIO
TEREFESDIR=$(MYLIBDIR)/Terefes
 

# Compiling options
CPPFLAGS=-I$(LOCALDIR) -I$(TIMERDIR) -I$(TEREFESDIR) -I$(GPIODIR)
#CFLAGS=-c -Wall --sysroot=/usr/arm-linux-gnueabihf -iquote$(LOCALDIR)
#LDFLAGS=--sysroot=/usr/arm-linux-gnueabihf -lstdc++ -lm
CFLAGS=-c -Wall -iquote$(LOCALDIR)
LDFLAGS=-lstdc++ -lm
 

 # Define Sources Files
MAINSOURCE=$(LOCALDIR)/prueba_2hz.c $(LOCALDIR)/globalvar.h $(LOCALDIR)/MyLib.h
MAINOBJ=$(BUILDDIR)/prueba_2hz.o

TIMERSOURCE=$(TIMERDIR)/Timer.c $(TIMERDIR)/Timer.h
TIMEROBJ=$(BUILDDIR)/Timer.o

TEREFESSOURCE=$(TEREFESDIR)/terefesV2_1Mbps.c $(TEREFESDIR)/terefes.h
TEREFESOBJ=$(BUILDDIR)/terefesV2_1Mbps.o

GPIOSOURCE=$(GPIODIR)/SimpleGPIO.c $(GPIODIR)/SimpleGPIO.h
GPIOOBJ=$(BUILDDIR)/SimpleGPIO.o

# Define Objetives files
OBJS=$(MAINOBJ) $(TIMEROBJ) $(TEREFESOBJ) $(GPIOOBJ)

# Executable
EXECUTABLE=prueba_2hz.run
 
all: $(MAINSOURCE) $(TIMERSOURCE) $(UDPSOURCE) $(TEREFESSOURCE) $(GPIOSOURCE) $(BUILDDIR)/$(EXECUTABLE)
	 
$(BUILDDIR)/$(EXECUTABLE): $(OBJS)
	cd $(BUILDDIR); $(CC) $(LDFLAGS) ${OBJS} -o $@;

$(MAINOBJ): $(MAINSOURCE) 
	cd $(BUILDDIR); $(CC) $(CFLAGS) $(CPPFLAGS) -c $<
		
$(TIMEROBJ): $(TIMERSOURCE) $(LOCALDIR)/globalvar.h
	cd $(BUILDDIR); $(CC) $(CFLAGS) $(CPPFLAGS) -c $<
	
$(GPIOOBJ): $(GPIOSOURCE) $(LOCALDIR)/globalvar.h
	cd $(BUILDDIR); $(CC) $(CFLAGS) $(CPPFLAGS) -c $<
	
$(TEREFESOBJ): $(TEREFESSOURCE) $(LOCALDIR)/globalvar.h 
	cd $(BUILDDIR); $(CC) $(CFLAGS) $(CPPFLAGS) -c $<

clean:
	rm -f $(OBJS) $(BUILDDIR)/$(EXECUTABLE) 
	
send:
	scp -r $(BUILDDIR)/$(EXECUTABLE) ubuntu@$(BEAGLEIP):$(BEAGLEDIR)
