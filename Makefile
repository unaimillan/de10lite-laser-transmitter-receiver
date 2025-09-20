.PHONY: clean simulate quartus synth synth-trans synth-recv upload gen_asm

help:
	$(info make help    - show this message(default))
	$(info make clean   - delete synth folder)
	$(info make quartus - open project in Quartus Prime)
	$(info make synth   - synthesize project in Quartus)
	$(info make upload  - upload project to the FPGA board)
	@true

# ------------------------------------------------------------------------------
# Generation and project creation
# ------------------------------------------------------------------------------



# ------------------------------------------------------------------------------
# Simulation
# ------------------------------------------------------------------------------



# ------------------------------------------------------------------------------
# Synthesis
# ------------------------------------------------------------------------------

# CABLE_NAME   ?= "USB-Blaster"
PROJECT_DIR  ?= ./synth/de10_lite
PROJECT_NAME_TRANSMITTER ?= "laser-transmitter"
PROJECT_NAME_RECEIVER    ?= "laser-receiver"
# PROJECT_NAME ?= $(TRANS_NAME)

QUARTUS     := cd $(PROJECT_DIR) && quartus
QUARTUS_SH  := cd $(PROJECT_DIR) && quartus_sh
QUARTUS_PGM := cd $(PROJECT_DIR) && quartus_pgm

# when we run quartus bins from WSL it can be installed on host W10
# it this case we have to add .exe to the executed binary name
ifdef WSL_DISTRO_NAME
 ifeq (, $(shell which $(QUARTUS)))
  QUARTUS     := $(QUARTUS).exe
  QUARTUS_SH  := $(QUARTUS_SH).exe
  QUARTUS_PGM := $(QUARTUS_PGM).exe
 endif
endif

# make open
#  cd project && quartus <projectname> &
#     cd project            - go to project folder 
#	  &&                    - if previous command was successfull
#     quartus <projectname> - open <projectname> in quartus 
#     &                     - run previous command in shell background
quartus:
	$(QUARTUS) $(PROJECT_NAME) &

# make build
#  cd project && quartus_sh --flow compile <projectname>
#     cd project                              - go to project folder 
#     &&                                      - if previous command was successfull
#     quartus_sh --flow compile <projectname> - run quartus shell & perform basic compilation 
#                                               of <projectname> project
synth-trans:
	$(QUARTUS_SH) --no_banner --flow compile $(PROJECT_NAME_TRANSMITTER)
	make upload-trans

synth-recv:
	$(QUARTUS_SH) --no_banner --flow compile $(PROJECT_NAME_RECEIVER)
	make upload-recv

# synth: synth-trans, synth-recv

# make load
#  cd project && quartus_pgm -c "USB-Blaster" -m JTAG -o "p;<projectname>.sof"
#     cd project               - go to project folder 
#	  &&                       - if previous command was successfull
#     quartus_pgm              - launch quartus programmer
#     -c "USB-Blaster"         - connect to "USB-Blaster" cable
#     -m JTAG                  - in JTAG programming mode
#     -o "p;<projectname>.sof" - program (configure) FPGA with <projectname>.sof file
# upload:
# 	$(QUARTUS_PGM) --no_banner -c $(CABLE_NAME) -m JTAG -o "p;output_files_transmitter/$(PROJECT_NAME).sof"
TRANSMITTER_CABLE_NAME ?= "USB-Blaster [1-2]"
RECEIVER_CABLE_NAME ?= "USB-Blaster [1-3]"

upload-trans:
	$(QUARTUS_PGM) --no_banner -c $(TRANSMITTER_CABLE_NAME) -m JTAG -o "p;output_files_transmitter/$(PROJECT_NAME_TRANSMITTER).sof"

upload-recv:
	$(QUARTUS_PGM) --no_banner -c $(RECEIVER_CABLE_NAME) -m JTAG -o "p;output_files_receiver/$(PROJECT_NAME_RECEIVER).sof"
