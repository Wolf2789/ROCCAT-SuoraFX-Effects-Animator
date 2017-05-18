using Gtk;
using GLib;
using Lua;
using Posix;

namespace SuoraFXEffectsAnimator {
  public LUA     lua;
  public SuoraFX device;
  public GUI     gui;

  public bool    useGUI = true;
  public bool    DEBUG = false;

  public class program {
    public static int main (string[] args) {
      // initialize device
      device = new SuoraFX();

      // initialize Lua API
      lua = new LUA();
      lua.initialize();
      lua.execute(device.presetsToLua());

      if (args.length > 1) {
        useGUI = false;
        bool file = true;
        
        int i = 1;
        while (i < args.length) {
          switch (args[i]) {
            case "-d":
              DEBUG = true;
              break;
            case "-l":
              file = false;
              break;
            default:
              if (file) {
                if (lua.load_file(args[i]) != 0)
                  LOG("# LUA: "+ lua.get_error());
              } else {
                if (lua.load_string(args[i]) != 0)
                  LOG("# LUA: "+ lua.get_error());
              }
              file = true;
              break;
          }
          i++;
        }
        
      } else {
        DEBUG = true;
        // initialize UI
        Gtk.init(ref args);
        gui = new GUI();
      }

      LOG("# SuoraFX: "+(device.open() ? "" : "not ") +"found");

      if (useGUI)
        // show UI
        Gtk.main();
      else {
        if (device.open()) {
          // execute lua program
          LOG("# Connecting to SuoraFX... ", false);
          if (device.claim()) {
            LOG("OK");
            LOG("# Executing Lua code... ");
            if (lua.call() != 0)
              LOG("Error: " + lua.get_error());
            LOG("# Done.");
            LOG("# Disconnecting from SuoraFX...");  
            device.unclaim();
          } else
            LOG("ERR\n# Failed to claim device interface. Exiting...");
        } else
          LOG("# Error: SuoraFX not connected!");
      }

      return 0;
    }
  }

  public void LOG(string s, bool newline = true) {
    if (DEBUG)
      if (useGUI)
        gui.log(s + (newline ? "\n" : ""));
      else
        printf("%s%s", s, (newline ? "\n" : ""));
  }

  public uint8 clamp(uint8 value, uint8 min, uint8 max) {
    return uint8.max(min, uint8.min(max, value));
  }
}
