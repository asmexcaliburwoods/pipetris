MAKE_Windows_NT=c:/cygwin/bin/make.exe
MAKE_Linux=make

OINT_HOME=../oberon_interpreter_1_0_incubation

MAKE=$(MAKE_`uname -s`)
	
os:

oberon_interpreter:	os
	CPATH=`pwd` && cd $(OINT_HOME) && $(MAKE) all && cd $(CPATH)

petris: Petris.Mod

all:	os petris

wake_petris:	all
	$(OINT_HOME)/oberon_interpret Petris.Mod
	# --encoding cp866 

clean:	os
	cd ../oberon_interpreter_1_0_incubation && $(MAKE) clean
