using LibUSB;
using Gee;
using Posix;

namespace SuoraFXEffectsAnimator {
  public class SuoraFX {

    private Context      context;
    private DeviceHandle handle;

    public  HashMap<string, Preset> presets;
    private DataPacket[]            custom_data;

    public uint8 speed = 0x0A;
    public uint8 brightness = 0x32;
    public uint8 color = 0x08;
    
    public uint8 customCommand = 0x00;

    public SuoraFX() {
      // initialize device
      Context.init(out context);

      custom_data = {};
      for (int i = 0; i < 8; i++)
        custom_data += new DataPacket({0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0});

      // initialize presets
      presets = new HashMap<string, Preset>();

      presets.set("CUSTOM", new Preset(0x33, 0x00, true));

      presets.set("FULLY_LIT", new Preset(0x01));
      presets.set("BREATHING", new Preset(0x02));
      presets.set("COLOR_SHIFT", new Preset(0x08));

      presets.set("WAVE_RIGHT", new Preset(0x03, 0x01));
      presets.set("WAVE_LEFT", new Preset(0x03, 0x02));
      presets.set("WAVE_UP", new Preset(0x03, 0x03));
      presets.set("WAVE_DOWN", new Preset(0x03, 0x04));

      presets.set("FADE_OUT", new Preset(0x04));
      presets.set("FADE_IN", new Preset(0x07));

      presets.set("RIPPLE", new Preset(0x06));
      presets.set("RAIN", new Preset(0x0A));

      presets.set("SNAKE", new Preset(0x05));
      presets.set("SPIRAL", new Preset(0x0B));
      presets.set("GAME_OVER", new Preset(0x09));

      presets.set("SCANNER", new Preset(0x0C));
      presets.set("RADAR", new Preset(0x0D));
    }


    // DEVICE MANAGEMENT
    public bool open() {
      if (handle == null)
        handle = new DeviceHandle.from_vid_pid(context, 0x1E7D, 0x3246);
      return handle != null;
    }

    public bool claim() {
      if (open()) {
        if (handle.claim_interface(3) == 0)
          return (handle.detach_kernel_driver(3) == 0);
        else if (handle.detach_kernel_driver(3) == 0)
          return (handle.claim_interface(3) == 0);
      }
      return false;
    }

    public void unclaim() {
      if (open()) {
        handle.release_interface(3);
        handle.attach_kernel_driver(3);
        handle = null;
      }
    }


    // PRESETS RELATED
    public string presetsToLua() {
      string result = "Preset = {";
      foreach (string key in this.presets.keys)
        result += key + " = \""+ key +"\",";
      return result + "}";
    }

    // custom data management
    public void resetChunk(int y) {
      this.custom_data[y].set({0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0});
    }

    public void setKey(int x, int y, uint8 r, uint8 g, uint8 b) {
      this.custom_data[y].setAt( x , r);
      this.custom_data[y].setAt(x+1, g);
      this.custom_data[y].setAt(x+2, b);
    }

    public uint8 getKeyR(int x, int y) { return this.custom_data[y].getAt(x); }
    public uint8 getKeyG(int x, int y) { return this.custom_data[y].getAt(x+1); }
    public uint8 getKeyB(int x, int y) { return this.custom_data[y].getAt(x+2); }


    // USB RELATED
    public uint8[] generatePacket(uint8 b1, uint8 b2, uint8 b3, uint8 b4, uint8 b5, uint8 b6, uint8 b7) {
      //b2 = clamp(b2, 1, 0x02);  // command    = 0x01 .. 0x02
      //b3                        // effect     = 0x01 .. 0x0D, 0x50 .. 0x55
      //b4 = clamp(b4, 0, 0x0A);  // speed      = 0x00 .. 0x0A // be careful with 0x00 (fastest and glitchy)
      //b5 = clamp(b5, 1, 0x32);  // brightness = 0x01 .. 0x32
      //b6 = clamp(b6, 1, 0x08);  // color      = 0x01 .. 0x08
      uint8 checksum = 0xFF - (b1 + b2 + b3 + b4 + b5 + b6 + b7);
      return {b1, b2, b3, b4, b5, b6, b7, checksum};
    }

    public void update(string preset = "CUSTOM") {
      if (!this.presets.has_key(preset)) {
        LOG("ERROR: Preset not found ("+preset+")");
        return;
      }
      Preset p = this.presets.get(preset);
      if (p.sendCustomData) {
        handle.control_transfer(0x21, 0x09, 0x0300, 0x03, generatePacket(0x12, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00), 8, 0);
        int written = 0;
        for (int i = 0; i < 8; i++)
          handle.interrupt_transfer(0x06, this.custom_data[i].get(), out written, 0);
      }
      handle.control_transfer(0x21, 0x09, 0x0300, 0x03, generatePacket(
      	0x08, 0x02, // header
      	p.getEffect(),
      	clamp(this.speed, 0, 0x0A),
      	clamp(this.brightness, 1, 0x32),
      	clamp(this.color, 1, 0x08),
      	p.getOption()
      ), 8, 0);
    }
  }
}
