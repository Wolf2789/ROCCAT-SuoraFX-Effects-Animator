# ROCCAT-SuoraFX-Effects-Animator
Made with Vala and Glade.

_Keep in mind that it's a very basic implementation and a lot of work should (and will) be done here._

## Features
* evaluating Lua code
* scripting effects in Lua
* premade built-in presets of SuoraFX

## Installation
### Dependencies
* gtk+-3.0
* gtksourceview-3.0
* lua-5.2
* libusb-1.0

### Building
Simply clone or download & unpack this repo and 
#### compile with
```
valac --pkg gtk+-3.0 --pkg libusb-1.0 --pkg gtksourceview-3.0 -X "-I/usr/include/lua5.2" --pkg lua -c "%f"
```
#### build with
```
valac --pkg gtk+-3.0 --pkg libusb-1.0 --pkg gtksourceview-3.0 -X "-I/usr/include/lua5.2" --pkg lua "%f"
```

## TODO
* no keyboard flickering when setting custom preset
* remapping keys
* effects API

# Contact
email me at: [wolf2789@gmail.com](mailto:wolf2789@gmail.com)
