using LibUSB;
using Gee;
using Posix;

namespace SuoraFXEffectsAnimator {
  public class DataPacket {
    private uint8[] data;
    public DataPacket(uint8[] data) {
      this.data = data;
    }

    public uint8[] get()                          { return this.data; }
    public void    set(uint8[] data)              { this.data = data; }
    public uint8   getAt(int index)               { return this.data[index]; }
    public void    setAt(int index, uint8 value)  { this.data[index] = value; }
  }


  public class Preset {
    private uint8 effect;
    private uint8 option;
    public bool sendCustomData;
    public Preset(uint8 effect, uint8 option = 0x00, bool sendCustomData = false) {
      this.effect = effect;
      this.option = option;
      this.sendCustomData = sendCustomData;
    }

    public uint8 getEffect() { return this.effect; }
    public uint8 getOption() { return this.option; }
  }
}
