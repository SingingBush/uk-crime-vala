using Gtk;

public class UkCrimeApp : ApplicationWindow {

    private PoliceApi api;
    //  private PoliceForce selected_force;

    private Gtk.Label police_force_label; // = new Gtk.Label("Select a Police Force");
    private Gtk.Label police_force_link; // = new Gtk.Label("url");
    private Gtk.TextView text_view;

    private const int DEFAULT_MARGIN = 10;

    public static int main (string[] args) {
        Gtk.init (); // With GTK3 this would have been Gtk.init (ref args);

        UkCrimeApp app = new UkCrimeApp ();
        app.present(); // With GTK3 this would have been a call to show_all()

        // this is the main loop that is required to start the window.
        // With gtk3 this would have been a call to Gtk.main()
        while (Gtk.Window.get_toplevels ().get_n_items () > 0) {
            GLib.MainContext.@default ().iteration (true);
        }
        return 0;
    }

    public UkCrimeApp() {
        this.api = new PoliceApi();

        // run the app with debug enabled: "G_MESSAGES_DEBUG=all ./ukcrime-gtk4"
        GLib.debug ("Starting UK Crime App");

        this.title = "UK Crime";
        //  this.set_default_size (350, 70);
        this.set_default_size (800, 600);
        this.margin_top = DEFAULT_MARGIN;
        this.margin_start = DEFAULT_MARGIN;
        this.margin_end = DEFAULT_MARGIN;
        this.margin_bottom = DEFAULT_MARGIN;

        //  use Gtk.Box instead of BorderPane in JavaFX app
        // Create the main vertical box
        //var border_layout = new Gtk.Box(Orientation.VERTICAL, DEFAULT_MARGIN);
        //set_child (border_layout);

        // Left Panel
        var left_panel = new Gtk.Box(Orientation.VERTICAL, DEFAULT_MARGIN);
        //  left_panel.set_vexpand(true);
        left_panel.set_size_request (280, 290);

        var police_label = new Gtk.Label("Select a Police Force");
        left_panel.append(police_label);


        GLib.List<PoliceForce> forces = api.getAllPoliceForces();
        var forcesL = new GLib.ListStore(typeof (PoliceForce));
        forces.foreach((pf) => {
            forcesL.append(pf);
        });

        //var selection_model = new Gtk.NoSelection(forcesL);
        var selection_model = new Gtk.SingleSelection (forcesL) {
            autoselect = true,
            can_unselect = false
        };

        var list_view_factory = new Gtk.SignalListItemFactory ();
        

        // setup the widgets to use in each row
        list_view_factory.setup.connect ((factory, list_item) => {
            var li = (Gtk.ListItem) list_item;
            li.selectable = false; // Disable default click selection
            li.activatable = true; // Ensure it can still be 'activated'

            //li.selectable = false;
            // for now just use a Label, could use a Box with multiple items later
            var label = new Gtk.Label ("");
            label.halign = Gtk.Align.START;
            li.set_child(label);
        });

        // setup the data in each row when the model is bound to the UI
        list_view_factory.bind.connect ((factory, list_item) => {
            var li = (Gtk.ListItem) list_item;
            PoliceForce pf = (PoliceForce) li.item;
            // use the model data to set the label text
            var pf_label = (Gtk.Label) li.child;
            pf_label.label = @"$(pf.name) $(pf.id)";
        });


        // could also set headers for the list
        //var list_view_header_factory = new Gtk.SignalListItemFactory ();
        //  list_view_header_factory.setup.connect (on_list_view_header_setup);
        //  list_view_header_factory.bind.connect (on_list_view_header_bind);


        var force_list = new Gtk.ListView(selection_model, list_view_factory); // Populate with data
        force_list.show_separators = false;
        force_list.enable_rubberband = true;
        force_list.single_click_activate = true;
        //  force_list.min_content_height = 100;
        //  force_list.set_min_content_height (100);
        //force_list.height_request = -1;
        //  force_list.set_size_request (280, 290);
        //force_list.header_factory = list_view_header_factory;
        //  force_list.set_hexpand(true); // maximize height but it's better to have scrollbar


        force_list.activate.connect ((l_view, position) => {
            selection_model.selected = position; // ensure selection matches activation
            var pf = forces.nth_data(position);
            GLib.debug(@"Activate list item $(position) : $(pf.name)");
            //  this.selected_force = pf;
            loadPoliceForceDetails(pf);
        });
        //force_list.select.connect ((l_view, position) => {
        //    GLib.debug(@"Select $(position)");
        //});

        var left_scroll_pane = new Gtk.ScrolledWindow ();
        left_scroll_pane.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
        left_scroll_pane.hexpand = false;
        left_scroll_pane.vexpand = true;
        left_scroll_pane.set_child (force_list);

        left_panel.append(left_scroll_pane);
    


        //  var grid  = new Grid();
        //  grid.orientation = Orientation.VERTICAL;
        //  grid.column_spacing = 2;
        //  grid.row_spacing = 1;

        var button = new Gtk.Button.with_label ("Call API");

        var label = new Gtk.Label("initial text");

        //  var listbox = new Gtk.ListBox();

        //  this.text_view = new TextView();
        //  this.text_view.editable = false;
        //  this.text_view.cursor_visible = false;

        //  var scroll = new ScrolledWindow();
        //  scroll.set_policy(PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
        //  scroll.add(listbox);

        button.clicked.connect (() => {            
            try {
                GLib.List<PoliceForce> ffff = api.getAllPoliceForces();
                GLib.info("received %u forces from the API:", ffff.length());
                //  ffff.foreach((pf) => GLib.debug("Force %s : %s", pf.id, pf.name));
                ffff.foreach((pf) => {
                    //  var row = new Gtk.ListBoxRow();
                    var row_label = new Gtk.Label("%s (%s)".printf(pf.name, pf.id));
                    //  row.set_child(row_label);

                    // var list_item = (Gtk.ListItem)
                    //force_list.add(row_label);
                    //force_list.append(row_label);
                    //listbox.append(row);
                });
                //listbox.show_all();

                label.set_text(@"Found $(ffff.length()) police forces");

                PoliceForce pf = ffff.nth_data (1) as PoliceForce;
                PoliceForceDetails details = api.getPoliceForceById(pf.id);
                GLib.info ("%s (%s) '%s'", details.id, details.url, details.description);
            } catch (GLib.Error e) {
                GLib.error("Error using API: %s", e.message);
            }
        });

        //  grid.attach (button, 1, 1, 1, 1);
        //  grid.attach (label, 2, 1, 1, 1);

        //  //  grid.attach (listbox, 1, 2, 2, 1);
        //  grid.attach (scroll, 1, 2, 2, 1);

        //  this.set_child (grid);

        // Combine into the main layout
        var main_layout = new Gtk.Box(Orientation.HORIZONTAL, DEFAULT_MARGIN);
        main_layout.append(left_panel);
        main_layout.append(this.init_center_panel());

        // Attach to the window
        set_child (main_layout);
    }

    // will need to be inherited from Gtk.Application to use this properly
    //  protected override void activate() {
    //      // 2. Define your CSS
    //      // 'currentColor' ensures the text adapts to Light/Dark themes!
    //      string css = """
    //          .brand-title {
    //              font-size: 32pt;
    //              font-weight: 800;
    //              letter-spacing: 2px;
    //              color: currentColor;
    //              margin: 20px;
    //          }
    //      """;

    //      // 3. Load the CSS Provider
    //      var provider = new Gtk.CssProvider();
    //      provider.load_from_data(css, css.length);

    //      // 4. Apply it to the Display (available to all windows)
    //      Gtk.StyleContext.add_provider_for_display(
    //          Gdk.Display.get_default(),
    //          provider,
    //          Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
    //      );
    //  }

    // todo: finish building the Main Content Panel
    private Gtk.Widget init_center_panel () {
        var scroll_pane = new Gtk.ScrolledWindow ();
        scroll_pane.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
        //  scroll_pane.hexpand = false;
        //  scroll_pane.vexpand = true;
        

        var center_panel = new Gtk.Box(Orientation.VERTICAL, DEFAULT_MARGIN);
        center_panel.margin_start = DEFAULT_MARGIN;

        this.police_force_label = new Gtk.Label("Select a Police force");
        this.police_force_label.halign = Gtk.Align.START;
        // Use GTK Style Classes rather than direct Pango attributes:
        //  .title-1 through .title-4: Hierarchical titles from largest to smallest.
        //  .heading: The standard style for UI-level headers.
        //  .body: Standard readable body text.
        //  .caption: Smaller, less prominent text.
        this.police_force_label.get_style_context().add_class("heading"); 
        // this.police_force_label.attributes = Pango.AttrList.from_string(
        //     """
        //         0 -1 scale x-large,
        //         0 -1 weight bold,
        //         0 -1 foreground #0d4a86
        //     """
        // ); // 0 -1 font-desc "Sans Bold 22",
        center_panel.append(this.police_force_label);

        this.police_force_link = new Gtk.Label("url: -");
        this.police_force_link.halign = Gtk.Align.START;
        this.police_force_link.attributes = Pango.AttrList.from_string(
            "5 -1 foreground #4b7dfa"
        );
        center_panel.append(this.police_force_link);

        // there is also TextView.with_buffer (TextBuffer buffer)
        this.text_view = new Gtk.TextView () {
            editable = false,
            cursor_visible = false,
            overwrite = true,
            wrap_mode = Gtk.WrapMode.WORD
        };
        //  text_view.set_wrap_mode (Gtk.WrapMode.WORD);
        text_view.set_size_request (280, 280);
        scroll_pane.set_child (text_view); // text view is scrollable
        center_panel.append(scroll_pane);

        // todo: only show this widget if we have officers data
        //  var officers_list = new Gtk.ListView (null, null); // Populate with data
        //  officers_list.set_size_request (280, 290);
        //  center_panel.append (officers_list);

        var neighborhoods_section = new Gtk.Box (Orientation.HORIZONTAL, DEFAULT_MARGIN);

        var neighborhoods_list = new Gtk.ListView (null, null); // Populate with data
        neighborhoods_list.set_size_request (280, 300);
        neighborhoods_section.append (neighborhoods_list);

        var neighborhood_component = new Gtk.Button.with_label ("Current Neighborhood"); // Placeholder
        neighborhoods_section.append (neighborhood_component);

        center_panel.append (neighborhoods_section);

        //  scroll_pane.set_child (center_panel);
        return center_panel;
    }

    private void loadPoliceForces() {
        //  var pf_list_store = new GLib.ListStore(typeof (PoliceForce)); // list may be fine
        try {
            GLib.List<PoliceForce> forces = api.getAllPoliceForces();
            GLib.info("received %u forces from the API:", forces.length());
            //  forces.foreach((pf) => GLib.debug("Force %s : %s", pf.id, pf.name));
            forces.foreach((pf) => {
                //  var row = new Gtk.ListBoxRow();
                var row_label = new Gtk.Label("%s (%s)".printf(pf.name, pf.id));
                //  row.set_child(row_label);

                // var list_item = (Gtk.ListItem)
                //force_list.add(row_label);
                //force_list.append(row_label);
                //listbox.append(row);
            });
            //listbox.show_all();

            //  label.set_text(@"Found $(forces.length()) police forces");

            //PoliceForce pf = forces.nth_data (1) as PoliceForce;
            //PoliceForceDetails details = api.getPoliceForceById(pf.id);
            //GLib.info ("%s (%s) '%s'", details.id, details.url, details.description);
        } catch (GLib.Error e) {
            GLib.error("Error using API: %s", e.message);
        }
    }

    private void loadPoliceForceDetails(PoliceForce police_force) {
        if (police_force == null) {
            GLib.warning("No police force selected, cannot load details");
            // should not happen
            return;
        }

        try {
            PoliceForceDetails details = api.getPoliceForceById(police_force.id);
            GLib.info ("Loaded details for %s: %s (%s)", details.name, details.id, details.url);

            this.police_force_label.label = details.name;
            this.police_force_link.label = @"url: $(details.url)" ?? "url: -";
            this.text_view.buffer.text = details.description ?? "no description available";

            // Further processing to update UI with details can be added here
        } catch (GLib.Error e) {
            GLib.error("Error loading police force details: %s", e.message);
        }
    }

    //  private void on_list_view_setup (Gtk.SignalListItemFactory factory, GLib.Object list_item_obj) {
    //      var vbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 4);
    //      var name_label = new Gtk.Label ("");
    //      name_label.halign = Gtk.Align.START;

    //      var id_label = new Gtk.Label ("");
    //      id_label.halign = Gtk.Align.START;

    //      vbox.append (name_label);
    //      vbox.append (id_label);
    //      ((Gtk.ListItem) list_item_obj).child = vbox;
    //  }
}
