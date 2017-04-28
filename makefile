EXECUTABLE=SuoraFX-Effects-Animator

VALAC=valac
VALAPKGS=--pkg gtk+-3.0 --pkg gee-0.8 --pkg gtksourceview-3.0 --pkg libusb-1.0 --pkg lua
VALASOURCES=$(shell find -name *.vala)
VALAOPTS=
CFLAGS=-X "-I/usr/include/lua5.2" -X -llua5.2

default:
	$(VALAC) $(CFLAGS) $(VALAPKGS) $(VALAOPTS) $(VALASOURCES) -o $(EXECUTABLE)
	
run:
	sudo ./$(EXECUTABLE)
	
build_and_run: default run
