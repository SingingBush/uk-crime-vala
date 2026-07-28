using Gtk;

class MainWindow : ApplicationWindow {

    private const int DEFAULT_MARGIN = 10;

    private PoliceApi api;

    // this list store will contain the data returned via API so that it can be rendered in to a ListView
    // Gtk.ListStore is deprecated so need to make sure to use a Gio.ListStore
    private GLib.ListStore forcesListStore = new GLib.ListStore(typeof (PoliceForce));

    // UI widgets used across methods

    // The left-side of the window will list forces
    private Gtk.Spinner forces_spinner;

    private Gtk.Label police_force_label; // = new Gtk.Label("Select a Police Force");

    // The right-side of the window will display details for the selected force
    private Gtk.Spinner details_spinner;
    private Gtk.Label details_title;
    private Gtk.Label details_police_force_link;
    private Gtk.TextView details_text_view;

    //private Gtk.Button button;
    //private Gtk.Label label;

    public MainWindow (Gtk.Application app, PoliceApi api) {
        base.application = app;

        // rather than passing the API client in perhaps worth having a background service that can also cache data.
        // see: https://docs.vala.dev/sample-code/gtk4-samples/synchronising-widgets.html
        this.api = api;

        this.title = "UK Crime";
        //this.titlebar = new Gtk.HeaderBar.with_title ("UK Crime").show_title_buttons (true);
        this.set_default_size (800, 600);
        this.margin_top = DEFAULT_MARGIN;
        this.margin_start = DEFAULT_MARGIN;
        this.margin_end = DEFAULT_MARGIN;
        this.margin_bottom = DEFAULT_MARGIN;


        // Left: forces list with spinner
        var left_box = new Gtk.Box(Orientation.VERTICAL, DEFAULT_MARGIN) {
            vexpand = true, // fill vertical space
            hexpand = false // fill horizontal space
        };
        left_box.set_size_request (280, 290);

        var police_label = new Gtk.Label("Select a Police Force");
        this.forces_spinner = new Gtk.Spinner();

        // use a ListView instead of a ListBox as it's a better choice for lists of unknown length
        Gtk.ListView forces_list_view = this.create_forces_list_view();

        left_box.append(forces_spinner);
        left_box.append(police_label);
        left_box.append(forces_list_view);

        // Right: details area with spinner
        var details_panel = new Gtk.Box(Orientation.VERTICAL, DEFAULT_MARGIN);

        // potentially a Grid may be good for the details panel
        //  var grid  = new Grid();
        //  grid.orientation = Orientation.VERTICAL;
        //  grid.column_spacing = 2;
        //  grid.row_spacing = 1;

        this.details_spinner = new Gtk.Spinner();
        this.details_title = new Gtk.Label("Select a police force to see details");
        this.details_title.halign = Gtk.Align.START;
        // Use GTK Style Classes rather than direct Pango attributes:
        //  .title-1 through .title-4: Hierarchical titles from largest to smallest.
        //  .heading: The standard style for UI-level headers.
        //  .body: Standard readable body text.
        //  .caption: Smaller, less prominent text.
        this.details_title.get_style_context().add_class("heading"); // a pre-defined style class

        // there is also TextView.with_buffer (TextBuffer buffer)
        // the TextView is scrollable so can be wrapped in a ScrollView if needed
        this.details_text_view = new Gtk.TextView () {
            editable = false,
            cursor_visible = false,
            overwrite = true,
            wrap_mode = Gtk.WrapMode.WORD,
            hexpand = true // fill horizontal space
        };
        this.details_text_view.get_style_context().add_class("body");

        this.details_police_force_link = new Gtk.Label("url: -");
        this.details_police_force_link.halign = Gtk.Align.START;
        // todo: as well as styling, make the link open a browser on click
        this.details_police_force_link.attributes = Pango.AttrList.from_string(
            "5 -1 foreground #4b7dfa"
        );

        details_panel.append(details_spinner);
        details_panel.append(details_title);
        details_panel.append(details_text_view);
        details_panel.append(details_police_force_link);

        // Place left (list view) and right (details) boxes in a horizontal container
        var hbox = new Gtk.Box(Orientation.HORIZONTAL, DEFAULT_MARGIN);
        hbox.append(left_box);
        hbox.append(details_panel);

        // wrap all the content within a Scrolled Window:
        var scroll_pane = new Gtk.ScrolledWindow ();
        scroll_pane.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
        scroll_pane.set_child (hbox);

        this.set_child (scroll_pane);

        // Start loading forces
        this.load_forces_into_list_store();
    }

    private Gtk.ListView create_forces_list_view() {
        //var selection_model = new Gtk.NoSelection(this.forcesListStore);
        var selection_model = new Gtk.SingleSelection (this.forcesListStore) {
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
            // use the model data to set the label text (potentially could use more complex UI)
            var pf_label = (Gtk.Label) li.child;
            pf_label.label = @"$(pf.name) ($(pf.id))";
        });


        // could also set headers for the list
        //var list_view_header_factory = new Gtk.SignalListItemFactory ();
        //  list_view_header_factory.setup.connect (on_list_view_header_setup);
        //  list_view_header_factory.bind.connect (on_list_view_header_bind);


        var force_list = new Gtk.ListView(selection_model, list_view_factory) {
            show_separators = false,
            enable_rubberband = true,
            single_click_activate = true,
            vexpand = true // fill vertical space
        };
        

        force_list.activate.connect ((l_view, position) => {
            selection_model.selected = position; // required for selection highlight to matche activation
            PoliceForce pf = this.forcesListStore.get_item(position) as PoliceForce;
            GLib.debug(@"Activate list item $(position) : $(pf.name)");

            load_force_details(pf.id);
        });

        return force_list;
    }

    // Load details for a force using async function
    private async void load_force_details (string id) {
        this.details_spinner.start();
        this.details_title.set_text("Loading...");

        try {
            PoliceForceDetails details = api.getPoliceForceById(id);
            GLib.info ("%s (%s) '%s'", details.id, details.url, details.description);
            details_spinner.stop();
            this.details_title.set_text(details.name ?? details.id);
            this.details_police_force_link.label = @"url: $(details.url)" ?? "url: -";
            // todo: strip html tags from description
            this.details_text_view.buffer.text = details.description ?? "no description available";
        } catch (Error e) {
            this.details_spinner.stop();
            this.details_title.set_text("Error");
            this.details_police_force_link.label = "";
            this.details_text_view.buffer.text = e.message;
        }
    }

    // Load list of forces using async function and populate ListStore
    private async void load_forces_into_list_store() {
        this.forces_spinner.start();

        try {
            GLib.List<PoliceForce> forces = this.api.getAllPoliceForces();
            GLib.info("received %u forces from the API:", forces.length());

            this.forces_spinner.stop();

            forces.foreach((pf) => {
                GLib.debug("Force %s : %s", pf.id, pf.name);
                this.forcesListStore.append(pf);
            });

            // on the initial load of police forces we should populate details section for 1st element in list
            if (forces.length() > 0) {
                PoliceForce pf = forces.nth_data (0) as PoliceForce;
                load_force_details(pf.id);
            } else {
                // todo: how to best indicate no forces from API?
                this.details_title.set_text("No forces found");
            }
        } catch (Error e) {
            this.forces_spinner.stop();
            this.details_title.set_text("Failed to load forces");
            this.details_text_view.buffer.text = e.message;
        }

    }
}