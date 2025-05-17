using Gtk;

public class UkCrimeApp : ApplicationWindow {

    private PoliceApi api;

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
        this.set_default_size (350, 70);

        var grid  = new Grid();
        grid.orientation = Orientation.VERTICAL;
        grid.column_spacing = 2;
        grid.row_spacing = 1;

        var button = new Gtk.Button.with_label ("Call API");

        var label = new Gtk.Label("initial text");

        button.clicked.connect (() => {            
            try {
                GLib.List<PoliceForce> forces = api.getAllPoliceForces();
                GLib.info("received %u forces from the API:", forces.length());
                forces.foreach((pf) => GLib.debug("Force %s : %s", pf.id, pf.name));

                label.set_text(@"Found $(forces.length()) police forces");

                PoliceForce pf = forces.nth_data (1) as PoliceForce;
                PoliceForceDetails details = api.getPoliceForceById(pf.id);
                GLib.info ("%s (%s) '%s'", details.id, details.url, details.description);
            } catch (GLib.Error e) {
                GLib.error("Error using API: %s", e.message);
            }
        });

        grid.attach (button, 1, 1, 1, 1);
        grid.attach (label, 2, 1, 1, 1);

        this.set_child (grid);
    }
}
