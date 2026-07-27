using Gtk;

public class UkCrimeApp : Gtk.Application {

    public UkCrimeApp() {
        Object(
            application_id: "com.singingbush.ukcrime",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    public static int main (string[] args) {
        Gtk.init (); // With GTK3 this would have been Gtk.init (ref args);

        //GLib.info ("args: %s", args.join (","));

        UkCrimeApp app = new UkCrimeApp ();
        return app.run (args);
    }

    protected override void startup () {
        GLib.debug ("Starting UK Crime App");
        base.startup();
    }

    // The entry point for a GTK application
    protected override void activate () {
        // run the app with debug enabled: "G_MESSAGES_DEBUG=all ./ukcrime-gtk4"
        GLib.debug ("Activating UK Crime App");

        string baseUrl = Environment.get_variable ("POLICE_API_BASE") ?? DEFAULT_BASE_URL;

        var window = new MainWindow (this, new PoliceApi(baseUrl));
        window.present();
    }

    // performs shutdown tasks
    protected override void shutdown () {
        GLib.debug ("Shutting down UK Crime App");
        base.shutdown();
    }
}
