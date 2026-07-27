using Gtk;

public class UkCrimeApp : ApplicationWindow {

    private PoliceApi api;

    // UI widgets used across methods
    private Gtk.Spinner forces_spinner;
    private Gtk.ListBox forces_listbox;
    private Gtk.Spinner details_spinner;
    private Gtk.Label details_title;
    private Gtk.Label details_desc;

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

    // Load details for a force using async function
    private async void load_force_details_task (string id) {
        this.details_spinner.start();
        this.details_title.set_text("Loading...");
        this.details_desc.set_text("");

        try {
            PoliceForceDetails details = api.getPoliceForceById(id);
            details_spinner.stop();
            this.details_title.set_text((details.name != null) ? details.name : details.id);
            this.details_desc.set_text((details.description != null) ? details.description : "(no description)");
        } catch (Error e) {
            this.details_spinner.stop();
            this.details_title.set_text("Error");
            this.details_desc.set_text(e.message);
        }
    }

    // Load list of forces using async function and populate ListBox
    private async void load_forces_into_list_box() {
        this.forces_spinner.start();
        this.forces_listbox.set_sensitive(false);

        try {
            GLib.List<PoliceForce> forces = this.api.getAllPoliceForces();
            GLib.info("received %u forces from the API:", forces.length());

            this.forces_spinner.stop();

            forces.foreach((pf) => {
                GLib.debug("Force %s : %s", pf.id, pf.name);
                var label = new Gtk.Label(pf.name);
                label.halign = Align.START;
                label.set_tooltip_text(pf.id);
                forces_listbox.append(label);
            });

            if (forces.length() > 0) {
                var first_row = forces_listbox.get_row_at_index(0);
                if (first_row != null) {
                    forces_listbox.select_row(first_row);
                    forces_listbox.set_sensitive(true);
                    var child = first_row.get_child() as Gtk.Label;
                    var id = child.get_tooltip_text();
                    //  if (id != null) load_force_details_task((string) id);
                    PoliceForce pf = forces.nth_data (1) as PoliceForce;
                    PoliceForceDetails details = api.getPoliceForceById(pf.id);
                    GLib.info ("%s (%s) '%s'", details.id, details.url, details.description);
                }
            } else {
                this.details_title.set_text("No forces found");
            }
        } catch (Error e) {
            this.forces_spinner.stop();
            this.details_title.set_text("Failed to load forces");
            this.details_desc.set_text(e.message);
        }

    }   

    public UkCrimeApp() {
        this.api = new PoliceApi();

        // run the app with debug enabled: "G_MESSAGES_DEBUG=all ./ukcrime-gtk4"
        GLib.debug ("Starting UK Crime App");

        this.title = "UK Crime";
        this.set_default_size (350, 70);

        var grid  = new Grid();
        grid.orientation = Orientation.VERTICAL;
        grid.column_spacing = 2;
        grid.row_spacing = 1;

        // Left: forces list with spinner
        var left_box = new Gtk.Box(Orientation.VERTICAL, 6);
        this.forces_spinner = new Gtk.Spinner();
        this.forces_listbox = new Gtk.ListBox();

        left_box.append(forces_spinner);
        left_box.append(forces_listbox);

        // Right: details area with spinner
        var right_box = new Gtk.Box(Orientation.VERTICAL, 6);
        this.details_spinner = new Gtk.Spinner();
        this.details_title = new Gtk.Label("Select a police force to see details");
        this.details_desc = new Gtk.Label("");
        this.details_desc.wrap = true;

        right_box.append(details_spinner);
        right_box.append(details_title);
        right_box.append(details_desc);

        // Place left and right boxes in a horizontal container
        var hbox = new Gtk.Box(Orientation.HORIZONTAL, 12);
        hbox.append(left_box);
        hbox.append(right_box);

        grid.attach(hbox, 1, 1, 2, 1);

        // When selection changes, load details
        forces_listbox.row_selected.connect ((box, row) => {
            if (row != null) {
                var child = row.get_child() as Gtk.Label;
                var id = child.get_tooltip_text();
                if (id != null) load_force_details_task((string) id);
            }
        });

        // Start loading forces
        this.load_forces_into_list_box();

        this.set_child (grid);
    }
}
