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
			""" + device.presetsToLua()
			);
			
			Gtk.init(ref args);
			gui = new GUI();
			gui.bSwitch.notify["active"].connect(() => {
				if (device.open()) {
					if (gui.bSwitch.active) {
						gui.log("# Connecting to SuoraFX...", false);
						if (device.claim()) {
							gui.log("OK");
							gui.log("# Executing Lua code... ");
							lua.execute(gui.get_lua_code());
							gui.log("# Done.");
						} else {
							gui.log("ERR: Failed to claim device interface.");
						}
					} else {
						gui.log("# Disconnecting from SuoraFX...");
						device.unclaim();
					}
				} else {
					gui.bSwitch.active = false;
					gui.log("# Error: SuoraFX not connected!");
				}
			});
			gui.bSwitch.set_sensitive(device.open() && lua.available());
			gui.log("# SuoraFX: "+(device.open() ? "" : "not ") +"found");
			
			Gtk.main();
			return 0;
		}
	}
}
