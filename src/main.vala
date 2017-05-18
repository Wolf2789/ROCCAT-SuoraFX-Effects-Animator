using Gtk;
using GLib;
using Lua;
using Posix;

namespace SuoraFXEffectsAnimator {
  public LUA     lua;
  public SuoraFX device;
  public GUI     gui;

  public bool    useGUI = true;

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
        lua.load_file(args[1]);
      } else {
        // initialize UI
        Gtk.init(ref args);
        gui = new GUI();
      }

      LOG("# SuoraFX: "+(device.open() ? "" : "not ") +"found");

      if (useGUI)
        // show UI
        Gtk.main();
      else {
        // execute lua program
        if (lua.call() != 0)
          LOG("Error: " + lua.get_error());
      }

      return 0;
    }
  }

  public void LOG(string s, bool newline = true) {
    if (useGUI)
      gui.log(s + (newline ? "\n" : ""));
    else
      printf("%s%s", s, (newline ? "\n" : ""));
  }

  public uint8 clamp(uint8 value, uint8 min, uint8 max) {
    return uint8.max(min, uint8.min(max, value));
  }
}
