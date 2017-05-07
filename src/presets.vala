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
		public void		set(uint8[] data)				{ this.data = data; }
		public uint8	getAt(int index)				{ return this.data[index]; }
		public void		setAt(int index, uint8 value)	{ this.data[index] = value; }
	}

	public class Preset {
		private Packet[] packet;
		private bool sendCustomData;
		public Preset(bool sendCustomData = false) {
			this.packet = {};
			this.sendCustomData = sendCustomData;
		}
		
		public void addPacket(uint8[] p, bool enabled = true) {
			this.packet += new Packet(p, enabled);
		}
		
		public uint8[] getPacket(int index) {
			return this.packet[index].get();
		}
		
		public void send(DeviceHandle handle) {
			// send custom data if needed
			if (sendCustomData) {
				handle.control_transfer(0x21, 0x09, 0x0300, 0x03, { 0x12, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0xE5 }, 8, 0);
				int written;
				for (int i = 0; i < 8; i++)
					handle.interrupt_transfer(0x06, device.getRowAt(i), out written, 0);
			}
			// send command message
			foreach (Packet p in packet)
				if (p.enabled)
					handle.control_transfer(0x21, 0x09, 0x0300, 0x03, p.get(), 8, 0);
		}
	}

	public class WavePreset : Preset {
		public WavePreset() {
			base();
			// init packets
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
}
