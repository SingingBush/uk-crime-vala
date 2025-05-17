
using GLib;
using Json;
using Soup;

class PoliceApi {

    private const string API_BASE = "https://data.police.uk/api";

    public GLib.List<PoliceForce> getAllPoliceForces() throws GLib.Error {
        string url = "%s/forces".printf (API_BASE);
        string json_body = makeGetRequest(url);

        Json.Parser p = new Json.Parser();

        GLib.List<PoliceForce> forces = new GLib.List<PoliceForce>();

        p.array_element.connect ((pars, array, index) => {
            forces.append(
                Json.gobject_deserialize(typeof(PoliceForce), array.get_element (index)) as PoliceForce
            );
        });
        p.load_from_data(json_body, json_body.length);
            
        return (owned) forces;
    }

    public PoliceForceDetails getPoliceForceById(string policeForceId) throws GLib.Error {
        string url = "%s/forces/%s".printf (API_BASE, policeForceId);

        string json_body = makeGetRequest(url);
        
        return Json.gobject_from_data(typeof(PoliceForceDetails), json_body, json_body.length) as PoliceForceDetails;
    }

    private string makeGetRequest(string url) throws GLib.Error {
        var session = new Soup.Session.with_options ("user_agent", "gtk4 crime app");
        session.timeout = 3;

        var message = new Soup.Message ("GET", url);

        try {
            GLib.info("Calling API: %s", url);
            GLib.Bytes response = session.send_and_read(message);
            return (string)response.get_data();
        } catch (GLib.Error e) {
            GLib.error("Failed to call API: %s", e.message);
        }
    }
}