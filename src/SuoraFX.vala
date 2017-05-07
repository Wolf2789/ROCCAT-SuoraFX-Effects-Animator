using LibUSB;
using Gee;

namespace SuoraFXEffectsAnimator {
	public class SuoraFX {
		
		private Context			context;
		private DeviceHandle	handle;
		public  HashMap<string, Preset>	presets;
		
		public SuoraFX() {
			Context.init(out context);
			handle = new DeviceHandle.from_vid_pid(context, 0x1E7D, 0x3246);

			presets = new HashMap<string, Preset>();
			
			presets.set("COLORSHIFT", new Preset());
			presets.get("COLORSHIFT").addPacket({ 0x08, 0x01, 0x33, 0x0A, 0x00, 0x08, 0x01, 0xB0 }, false);
			presets.get("COLORSHIFT").addPacket({ 0x12, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0xE5 }, false);
			presets.get("COLORSHIFT").addPacket({ 0x08, 0x02, 0x08, 0x0A, 0x32, 0x08, 0x00, 0xA9 });
			
			presets.set("RAIN", new Preset());
			presets.get("RAIN").addPacket({ 0x08, 0x01, 0x03, 0x0A, 0x00, 0x08, 0x01, 0xE0 }, false);
			presets.get("RAIN").addPacket({ 0x08, 0x02, 0x0A, 0x0A, 0x32, 0x08, 0x04, 0xA3 }, false);
			
			presets.set("WAVE", new WavePreset());
			presets.set("CUSTOM", new CustomPreset());
		}
		
		// helpful functions
		public bool open() {
			return handle != null;
		}
		
		public bool claim() {
			if (open()) {
				if (handle.claim_interface(3) == 0) {
					return (handle.detach_kernel_driver(3) == 0);
				} else if (handle.detach_kernel_driver(3) == 0) {
					return (handle.claim_interface(3) == 0);
				}
			}
			return false;
		}
		
		public void unclaim() {
			if (open()) {
				handle.release_interface(3);
				handle.attach_kernel_driver(3);
			}
		}
		
		public string presetsToLua() {
			string result = "Preset = {";
			foreach (string key in this.presets.keys) {
				if (key == "WAVE") {
					result += key + "_U = \""+ key +"_U\",";
					result += key + "_D = \""+ key +"_D\",";
					result += key + "_L = \""+ key +"_L\",";
					result += key + "_R = \""+ key +"_R\",";
				} else {
					result += key + " = \""+ key +"\",";
				}
			}
			return result + "}";
		}
		
		
		public void update(string preset = "CUSTOM") {
			if (presets.has_key(preset))
				presets.get(preset).send(handle);
			else switch (preset) {
				case "WAVE_U":
				case "WAVE_D":
				case "WAVE_L":
				case "WAVE_R":
					((WavePreset)presets.get("WAVE")).send(this.handle, preset.get_char(5));
					break;
			}
		}
	}
}
