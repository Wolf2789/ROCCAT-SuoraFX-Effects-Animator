using Lua;
using Posix;

namespace SuoraFXEffectsAnimator {
	public class LUA {
		private LuaVM L;
		
		public LUA() {
			L = new LuaVM();
		}
		
		public void initialize() {
			L.open_libs();
			L.register("sleep", sleep);
			L.register("print", print);
			L.register("keyboard_update", keyboard_update);
			L.register("keyboard_key", keyboard_key);
			L.register("keyboard_reset", keyboard_reset);
		}
		
		public bool available() {
			return L != null;
		}
		
		public void execute(string code) {
			L.do_string(code);
		}
		
		
		// Lua methods
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
			bool newline = true;
			if (args > 1) {
				newline = L.to_boolean(2);
			}
			gui.log(L.to_string(1), newline);
			return 0;
		}
		
		static int keyboard_update(LuaVM L) {
			int args = L.get_top();
			string preset = "CUSTOM";
			if (args > 0)
				preset = L.to_string(1);
			device.update(preset);
			return 0;
		}
		
		static int keyboard_key(LuaVM L) {
			int args = L.get_top();
			if (args == 2) {
				int x = ((L.to_integer(1) % 16) * 4);
				int y = L.to_integer(2) % 8;
				L.push_number(device.getDataAt( x ,y));
				L.push_number(device.getDataAt(x+1,y));
				L.push_number(device.getDataAt(x+2,y));
				return 3;
			} else if (args == 5) {
				int x = ((L.to_integer(1) % 16) * 4) + 1;
				int y = L.to_integer(2) % 8;
				int r = L.to_integer(3) % 256;
				int g = L.to_integer(4) % 256;
				int b = L.to_integer(5) % 256;
				device.setDataAt(x, y, (uint8)r, (uint8)g, (uint8)b);
				L.push_number(0);
			} else
				L.push_number(1);
			return 1;
		}
		
		static int keyboard_reset(LuaVM L) {
			int args = L.get_top();
			if (args > 0) {
				device.resetRow(L.to_integer(1));
			} else {
				for (int i = 0; i < 8; i++)
					device.resetRow(i);
			}
			return 0;
		}
	}
}
