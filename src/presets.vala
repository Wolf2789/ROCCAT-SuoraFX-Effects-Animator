using LibUSB;
using Gee;

namespace SuoraFXEffectsAnimator {
	
	public class Packet {
		private	uint8[]	data;
		public	bool	enabled;
		
		public Packet(uint8[] data, bool enabled = true) {
			this.data = data;
			this.enabled = enabled;
		}
		
		public uint8[]	get()							{ return this.data; }
		public uint8	getAt(int index)				{ return this.data[index]; }
		public void		setAt(int index, uint8 value)	{ this.data[index] = value; }
	}

	public class Preset {
		private Packet[] packet;
		public Preset() { this.packet = {}; }
		public void		addPacket(uint8[] p, bool enabled = true) { this.packet += new Packet(p, enabled); }
		public uint8[]	getPacket(int index) { return this.packet[index].get(); }
		public void		send(DeviceHandle handle) {
			foreach (Packet p in packet)
				if (p.enabled)
					handle.control_transfer(0x21, 0x09, 0x0300, 0x03, p.get(), 8, 0);
		}
	}
	
	public class WavePreset : Preset {
		public WavePreset() {
			base();
			this.addPacket({ 0x08, 0x01, 0x03, 0x0A, 0x00, 0x08, 0x01, 0xE0 });
			this.addPacket({ 0x08, 0x02, 0x03, 0x0A, 0x32, 0x08, 0x03, 0xAB });
			this.addPacket({ 0x08, 0x02, 0x03, 0x0A, 0x32, 0x08, 0x04, 0xAA });
			this.addPacket({ 0x08, 0x02, 0x03, 0x0A, 0x32, 0x08, 0x02, 0xAC });
			this.addPacket({ 0x08, 0x02, 0x03, 0x0A, 0x32, 0x08, 0x01, 0xAD });
		}
		
		public new void send(DeviceHandle handle, unichar direction = 'U') {
			handle.control_transfer(0x21, 0x09, 0x0300, 0x03, getPacket(0), 8, 0);
			switch (direction) {
				case 'U': {
					handle.control_transfer(0x21, 0x09, 0x0300, 0x03, getPacket(1), 8, 0);
				} break;
				case 'D': {
					handle.control_transfer(0x21, 0x09, 0x0300, 0x03, getPacket(2), 8, 0);
				} break;
				case 'L': {
					handle.control_transfer(0x21, 0x09, 0x0300, 0x03, getPacket(3), 8, 0);
				} break;
				case 'R': {
					handle.control_transfer(0x21, 0x09, 0x0300, 0x03, getPacket(4), 8, 0);
				} break;
			}
		}
	}
	
	public class CustomPreset : Preset {
		private Packet[] data;
		public CustomPreset() {
			base();
			this.addPacket({ 0x08, 0x01, 0x33, 0x0A, 0x00, 0x08, 0x01, 0xB0 });
			this.addPacket({ 0x12, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0xE5 });
			this.addPacket({ 0x08, 0x02, 0x33, 0x0A, 0x32, 0x08, 0x00, 0x7E });
			data = new Packet[8];
			for (int i = 0; i < 8; i++)
				data[i] = new Packet({0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
									  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
									  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
									  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
									  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
									  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
									  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
									  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00});
		}
		
		public uint8[]	getData(int y) { return this.data[y].get(); }
		public uint8	get(int x, int y) { return this.data[y].getAt(x); }
		public void		set(int x, int y, uint8 r, uint8 g, uint8 b) {
			this.data[y].setAt( x , r);
			this.data[y].setAt(x+1, g);
			this.data[y].setAt(x+2, b);
		}
		
		public new void send(DeviceHandle handle) {
			//handle.control_transfer(0x21, 0x09, 0x0300, 0x03, getPacket(0), 8, 0);
			handle.control_transfer(0x21, 0x09, 0x0300, 0x03, getPacket(1), 8, 0);
			int written;
			for (int i = 0; i < 8; i++)
				handle.interrupt_transfer(0x06, this.getData(i), out written, 0);
			handle.control_transfer(0x21, 0x09, 0x0300, 0x03, getPacket(2), 8, 0);
		}
	}

}
