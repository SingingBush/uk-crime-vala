using Gtk;

class MainWindow : ApplicationWindow {
    //private Gtk.Button button;
    //private Gtk.Label label;

    private PoliceApi api;

    public MainWindow (Gtk.Application app, PoliceApi api) {
        base.application = app;

        // rather than passing the API client in perhaps worth having a background service that can also cache data.
        // see: https://docs.vala.dev/sample-code/gtk4-samples/synchronising-widgets.html
        this.api = api;

        this.title = "UK Crime";
        //this.titlebar = new Gtk.HeaderBar.with_title ("UK Crime").show_title_buttons (true);
        this.set_default_size (350, 70);

        var grid  = new Grid();
        grid.orientation = Orientation.VERTICAL;
        grid.column_spacing = 2;
        grid.row_spacing = 1;

        var button = new Gtk.Button.with_label ("Call API");

        var label = new Gtk.Label("initial text");

        button.clicked.connect (() => {            
            try {
                GLib.List<PoliceForce> forces = this.loadForces();
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

    private GLib.List<PoliceForce> loadForces() {
        try {
            GLib.List<PoliceForce> forces = api.getAllPoliceForces();
            GLib.info("received %u forces from the API:", forces.length());
            forces.foreach((pf) => GLib.debug("Force %s : %s", pf.id, pf.name));

            return forces;

            //  label.set_text(@"Found $(forces.length()) police forces");

            //  PoliceForce pf = forces.nth_data (1) as PoliceForce;
            //  PoliceForceDetails details = api.getPoliceForceById(pf.id);
            //  GLib.info ("%s (%s) '%s'", details.id, details.url, details.description);
        } catch (GLib.Error e) {
            GLib.error("Error using API: %s", e.message);
        }
    }
}