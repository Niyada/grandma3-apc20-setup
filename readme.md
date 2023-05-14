# GrandMA3 APC20 Setup

## Description
Setup to control the GrandMA3 onPc software via an AKAI APC20 midi controller with live LED feedback.

## Disclaimer
Please keep in mind that this is a work in progress. If you have any issues, questions, ideas or find any bugs: do not hesitate to contact me or add an github issue.

## Chataigne
The setup is based on the [Chataigne](https://benjamin.kuperberg.fr/chataigne/) software.
It is used to translate the midi signals from the APC20 to OSC signals for the GrandMA3 onPc software using the exisiting [GrandMA3 Community Module](https://github.com/yastefan/grandMA3-Chataigne-Module) by (yastefan)[https://github.com/yastefan]. 

You can find the Chataigne setup file in the `chataigne` directory. More Information can be found in this repo's wiki.

## LED Feedback Plugin
The LED feedback plugin for the GrandMA3 onPc software can be found in the `plugin` directory. It is used to live update the APC's LEDs. 
It was inspired by [GLAD](http://www.ma-share.net/forum/profile.php?14,6)'s [MidiFeedbackLoop](http://www.ma-share.net/forum/read.php?14,53659,53659#msg-53659) for the GrandMA2 software. More Information can be found in this repo's wiki. 

## Requirements & Installation
### Installation
A detailed installation guide can be found in this repo's wiki.
### Requirements
- [GrandMA3 onPc](https://www.malighting.com/de/downloads/produkt/grandma3/)
- [Chataigne](https://benjamin.kuperberg.fr/chataigne/)
- [LoopMidi](https://www.tobias-erichsen.de/software/loopmidi.html)
- [Apc20 Initialization Script](https://forum.dmxcontrol-projects.org/index.php?thread/4736-tool-initialisieren-des-akai-apc20-midi-controllers/)
