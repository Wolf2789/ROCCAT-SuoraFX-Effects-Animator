using Gtk;
using GLib;
using Lua;
using Posix;

namespace SuoraFXEffectsAnimator {
  public class GUI : Gtk.Window {

    private string         file_uri;
    private Gtk.Paned      EditorWindow;
    private Gtk.TextBuffer EditorBuffer;
    private Gtk.SourceView Editor;
    private Gtk.TextBuffer OutputBuffer;
    private Gtk.TextView   Output;
    private Gtk.Button     bOpen;
    private Gtk.Button     bSave;
    public  Gtk.Button     bRun;
    public  Gtk.Switch     bClaim;
    private Gtk.Label      lFile;

    public GUI() {
      // initialize glade
      var builder = new Gtk.Builder();
      try {
        builder.add_from_string("<?xml version=\"1.0\" encoding=\"UTF-8\"?><interface><requires lib=\"gtk+\" version=\"3.20\"/><object class=\"GtkFileFilter\" id=\"filterLUA\"><mime-types><mime-type>LUA File</mime-type></mime-types><patterns><pattern>*.lua</pattern></patterns></object><object class=\"GtkImage\" id=\"image_open\"><property name=\"visible\">True</property><property name=\"can_focus\">False</property><property name=\"stock\">gtk-open</property></object><object class=\"GtkImage\" id=\"image_run\"><property name=\"visible\">True</property><property name=\"can_focus\">False</property><property name=\"stock\">gtk-media-play</property></object><object class=\"GtkImage\" id=\"image_save\"><property name=\"visible\">True</property><property name=\"can_focus\">False</property><property name=\"stock\">gtk-save</property></object><object class=\"GtkHeaderBar\" id=\"main_headerbar\"><property name=\"height_request\">40</property><property name=\"visible\">True</property><property name=\"can_focus\">False</property><property name=\"show_close_button\">True</property><property name=\"decoration_layout\">close,minimize,maximize::menu,icon</property><child><placeholder/></child><child type=\"title\"><object class=\"GtkBox\"><property name=\"visible\">True</property><property name=\"can_focus\">False</property><property name=\"spacing\">11</property><child><object class=\"GtkButton\" id=\"button_open\"><property name=\"visible\">True</property><property name=\"can_focus\">True</property><property name=\"receives_default\">True</property><property name=\"image\">image_open</property><property name=\"always_show_image\">True</property></object><packing><property name=\"expand\">False</property><property name=\"fill\">True</property><property name=\"position\">0</property></packing></child><child><object class=\"GtkButton\" id=\"button_save\"><property name=\"visible\">True</property><property name=\"can_focus\">True</property><property name=\"receives_default\">True</property><property name=\"image\">image_save</property><property name=\"always_show_image\">True</property></object><packing><property name=\"expand\">False</property><property name=\"fill\">True</property><property name=\"position\">1</property></packing></child><child><object class=\"GtkLabel\" id=\"label_file\"><property name=\"visible\">True</property><property name=\"can_focus\">False</property><property name=\"justify\">center</property><property name=\"ellipsize\">middle</property><property name=\"single_line_mode\">True</property><property name=\"angle\">2.2351741811588166e-10</property><attributes><attribute name=\"weight\" value=\"bold\"/><attribute name=\"stretch\" value=\"normal\"/></attributes></object><packing><property name=\"expand\">False</property><property name=\"fill\">True</property><property name=\"position\">2</property></packing></child><child><object class=\"GtkSwitch\" id=\"switch_claim\"><property name=\"visible\">True</property><property name=\"can_focus\">True</property><property name=\"valign\">center</property></object><packing><property name=\"expand\">False</property><property name=\"fill\">True</property><property name=\"position\">3</property></packing></child><child><object class=\"GtkButton\" id=\"button_run\"><property name=\"visible\">True</property><property name=\"can_focus\">True</property><property name=\"receives_default\">True</property><property name=\"image\">image_run</property><property name=\"always_show_image\">True</property></object><packing><property name=\"expand\">False</property><property name=\"fill\">True</property><property name=\"position\">4</property></packing></child></object></child></object></interface>", -1);
        builder.add_from_string("<?xml version=\"1.0\" encoding=\"UTF-8\"?><interface><requires lib=\"gtk+\" version=\"3.20\"/><requires lib=\"gtksourceview\" version=\"3.0\"/><object class=\"GtkPaned\" id=\"editor_window\"><property name=\"visible\">True</property><property name=\"can_focus\">True</property><property name=\"orientation\">vertical</property><child><object class=\"GtkScrolledWindow\"><property name=\"visible\">True</property><property name=\"can_focus\">True</property><property name=\"shadow_type\">in</property><child><object class=\"GtkSourceView\" id=\"editor_sourceview\"><property name=\"visible\">True</property><property name=\"can_focus\">True</property><property name=\"pixels_below_lines\">2</property><property name=\"left_margin\">4</property><property name=\"right_margin\">4</property><property name=\"top_margin\">4</property><property name=\"bottom_margin\">4</property><property name=\"monospace\">True</property><property name=\"show_line_numbers\">True</property><property name=\"tab_width\">4</property><property name=\"auto_indent\">True</property><property name=\"smart_home_end\">always</property><property name=\"highlight_current_line\">True</property></object></child></object><packing><property name=\"resize\">True</property><property name=\"shrink\">True</property></packing></child><child><object class=\"GtkScrolledWindow\"><property name=\"visible\">True</property><property name=\"can_focus\">True</property><property name=\"shadow_type\">in</property><child><object class=\"GtkTextView\" id=\"editor_outputview\"><property name=\"visible\">True</property><property name=\"sensitive\">False</property><property name=\"can_focus\">True</property><property name=\"pixels_below_lines\">2</property><property name=\"editable\">False</property><property name=\"left_margin\">3</property><property name=\"right_margin\">3</property><property name=\"top_margin\">2</property><property name=\"bottom_margin\">2</property><property name=\"cursor_visible\">False</property><property name=\"accepts_tab\">False</property><property name=\"monospace\">True</property></object></child></object><packing><property name=\"resize\">True</property><property name=\"shrink\">True</property></packing></child></object></interface>", -1);
      } catch (GLib.Error e) {
        error("Could not load user interface: %s", e.message);
      }

      // initialize variables
      file_uri = Environment.get_current_dir() + "/untitled.lua";

      // initialize window
      var window = new Gtk.Window();
      window.window_position = WindowPosition.CENTER;
      window.set_default_size(450, 300);
      window.set_titlebar(builder.get_object("main_headerbar") as Gtk.HeaderBar);
      window.set_title("ROCCAT SuoraFX Effects Animator");
      window.destroy.connect(Gtk.main_quit);

      // initialize components
      EditorWindow = builder.get_object("editor_window") as Gtk.Paned;
      Editor = builder.get_object("editor_sourceview") as Gtk.SourceView;
      Output = builder.get_object("editor_outputview") as Gtk.TextView;
      bOpen = builder.get_object("button_open") as Gtk.Button;
      bSave = builder.get_object("button_save") as Gtk.Button;
      bRun = builder.get_object("button_run") as Gtk.Button;
      bClaim = builder.get_object("switch_claim") as Gtk.Switch;
      lFile = builder.get_object("label_file") as Gtk.Label;

      lFile.set_label(file_uri);
      EditorBuffer = Editor.get_buffer();
      EditorBuffer.set_text("keyboard(KEY, 0,0, 255,0,0) -- red L_CTRL key\nkeyboard(SET, Preset.CUSTOM)\n");
      OutputBuffer = Output.get_buffer();

      // initialize components events
      bOpen.clicked.connect(() => {
        var file_chooser = new FileChooserDialog("Open LUA Script", this, FileChooserAction.SAVE,
          "_Cancel", ResponseType.CANCEL,
          "_Open", ResponseType.ACCEPT);
        if (file_chooser.run() == ResponseType.ACCEPT)
          file_uri = file_chooser.get_filename();
        file_chooser.destroy();

        lFile.set_label(file_uri);

        if (GLib.FileUtils.test(file_uri, FileTest.EXISTS)) {
          string contents = "";
          try {
            GLib.FileUtils.get_contents(file_uri, out contents);
          } catch (GLib.Error e) {
            LOG("Unable to load file: "+ file_uri);
          }
          EditorBuffer.set_text(contents);
          LOG("File loaded succesfully!");
        }
      });

      bSave.clicked.connect(() => {
        if (GLib.FileUtils.test(file_uri, FileTest.EXISTS)) {
          var dialog = new Gtk.Dialog.with_buttons(
            "Do you want to override existing file?", this, (Gtk.DialogFlags.MODAL | Gtk.DialogFlags.DESTROY_WITH_PARENT),
            "_Yes", Gtk.ResponseType.ACCEPT,
            "_No", Gtk.ResponseType.REJECT,
            null);
          dialog.response.connect((response_id) => {
            if (response_id == Gtk.ResponseType.ACCEPT)
              save_editor_to_file();
            dialog.close();
          });
          dialog.show_all();
        } else {
          save_editor_to_file();
        }
      });

      bClaim.notify["active"].connect(() => {
        if (device.open()) {
          if (bClaim.active) {
            LOG("# Connecting to SuoraFX... ", false);
            if (device.claim()) {
              LOG("OK");
              bRun.set_sensitive(lua.available());
            } else
              LOG("ERR\n# Failed to claim device interface.");
          } else {
            LOG("# Disconnecting from SuoraFX...");
            bRun.set_sensitive(false);
            device.unclaim();
          }
        } else {
          bClaim.active = false;
          LOG("# Error: SuoraFX not connected!");
        }
      });

      bRun.clicked.connect(() => {
        LOG("# Executing Lua code... ");
        lua.execute(get_lua_code());
        LOG("# Done.");
      });
      bRun.set_sensitive(false);

      // finish window initialization
      window.add(EditorWindow);

      window.destroy.connect(() => {
        if (device.open())
          device.unclaim();
      });

      window.show_all();
    }


    // basic helpful functions
    public void log(string message) {
      if (OutputBuffer != null) {
        OutputBuffer.insert_at_cursor(message, -1);
        TextIter end;
        OutputBuffer.get_end_iter(out end);
        Output.scroll_to_iter(end, 0, false, 0, 0);
      }
    }

    private void save_editor_to_file() {
      TextIter start, end;
      EditorBuffer.get_start_iter(out start);
      EditorBuffer.get_end_iter(out end);
      try {
        GLib.FileUtils.set_contents(file_uri, EditorBuffer.get_text(start, end, true));
        LOG("File saved succesfully!");
      } catch (GLib.Error e) {
        LOG("Unable to save file: "+ file_uri);
      }
    }

    public string get_lua_code() {
      TextIter start, end;
      EditorBuffer.get_start_iter(out start);
      EditorBuffer.get_end_iter(out end);
      return EditorBuffer.get_text(start, end, true);
    }
  }
}
