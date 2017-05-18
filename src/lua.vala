using Lua;
using Posix;

namespace SuoraFXEffectsAnimator {
  public class LUA {

    private LuaVM L;
    public LUA() { L = new LuaVM(); }

    public void initialize() {
      L.open_libs();
      L.do_string("""
      function ite(a,b,c)
        if a then return b else return c end
      end

      SPEED      = "KB_SPEED"
      BRIGTHNESS = "KB_BRIGTHNESS"
      COLOR      = "KB_COLOR"
      KEY        = "KB_KEY"
      RESET      = "KB_RESET"
      SET        = "KB_SET"
      """);
      L.register("sleep", sleep);
      L.register("print", print);
      L.register("println", println);
      L.register("keyboard", keyboard);
      L.register("command", command);
    }

    public bool   available()            { return L != null; }
    public int    call()                 { return L.pcall(0,0,0); }
    public string get_error()            { return L.to_string(-1); }
    public void   load_file(string file) { L.load_file(file); }
    public void   execute(string code)   { L.do_string(code); }


    static int sleep(LuaVM L) {
      int args = L.get_top();
      if (args == 1) {
        int x = L.to_integer(1);
        usleep(x*1000);
      }
      return 0;
    }

    static int print(LuaVM L) {
      int args = L.get_top();
      string to_print = "";
      if (args > 0) {
        for (int i = 1; i <= args; i++)
          to_print += L.to_string(i);
      }
      LOG(to_print, false);
      return 0;
    }

    static int println(LuaVM L) {
      int args = L.get_top();
      string to_print = "";
      if (args > 0) {
        for (int i = 1; i <= args; i++)
          to_print += L.to_string(i);
      }
      LOG(to_print, true);
      return 0;
    }

    
    static int command(LuaVM L) {
      int args = L.get_top();
      if (args > 0) {
        device.customCommand = (uint8)L.to_integer(1);
        return 0;
      } else {
        L.push_number(device.customCommand);
        return 1;
      }
    }


    // KEYBOARD API
    static int keyboard(LuaVM L) {
      int args = L.get_top();
      if (args > 0) {
        switch (L.to_string(1)) {
          case "KB_SET": {
            string preset = "CUSTOM";
            if (args > 1)
              preset = L.to_string(2);
            device.update(preset);
          } return 0;

          case "KB_RESET": {
            if (args > 1)
              device.resetChunk(L.to_integer(2) % 8);
            else
              for (int i = 0; i < 8; i++)
                device.resetChunk(i);
          } return 0;

          case "KB_SPEED":
            if (args > 1) {
              device.speed = (uint8)L.to_integer(2);
              return 0;
            } else {
              L.push_number(device.speed);
              return 1;
            }

          case "KB_BRIGTHNESS":
            if (args > 1) {
              device.brightness = (uint8)L.to_integer(2);
              return 0;
            } else {
              L.push_number(device.brightness);
              return 1;
            }

          case "KB_COLOR":
            if (args > 1) {
              device.color = (uint8)L.to_integer(2);
              return 0;
            } else {
              L.push_number(device.color);
              return 1;
            }

          case "KB_KEY": {
            if (args == 3) {
              int x = ((L.to_integer(2) % 16) * 4) + 1;
              int y = L.to_integer(3) % 8;
              L.push_number((int)device.getKeyR(x,y));
              L.push_number((int)device.getKeyG(x,y));
              L.push_number((int)device.getKeyB(x,y));
              return 3;
            } else if (args == 6) {
              int x = ((L.to_integer(2) % 16) * 4) + 1;
              int y = L.to_integer(3) % 8;
              int r = L.to_integer(4) % 256;
              int g = L.to_integer(5) % 256;
              int b = L.to_integer(6) % 256;
              device.setKey(x, y, (uint8)r, (uint8)g, (uint8)b);
              L.push_number(0);
            } else
              L.push_number(-1);
          } return 1;
        }
      }

      // pass error to lua
      L.push_number(-1);
      return 1;
    }
  }
}
