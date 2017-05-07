using Gtk;
using GLib;
using Lua;

namespace SuoraFXEffectsAnimator {
	public LUA lua;
	public SuoraFX device;
	public GUI gui;
		
	public class program {
		public static int main (string[] args) {
			// initialize environment
			lua = new LUA();
			lua.initialize();
			
			device = new SuoraFX();
			
			// initialize Lua API
			lua.execute("""
			function ite(a,b,c)
				if a then return b else return c end
			end
			""");
			lua.execute(device.presetsToLua());
			
			Gtk.init(ref args);
			gui = new GUI();
			gui.log("# SuoraFX: "+(device.open() ? "" : "not ") +"found");
			
			Gtk.main();
			return 0;
		}
	}
}
