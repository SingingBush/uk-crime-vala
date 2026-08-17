
using GLib;
using Json;
using Soup;

const string DEFAULT_BASE_URL = "https://data.police.uk/api";

class PoliceApi {

    private string baseUrl;

    public PoliceApi (string baseUrl = DEFAULT_BASE_URL) {
        this.baseUrl = baseUrl;
    }

    /**
     * @see <a href="https://data.police.uk/docs/method/crime-last-updated/">API doc: Last updated</a>
     * @return Month of the latest crime data in ISO date format. (The day is irrelevant and is only there to keep a standard formatted date)
     */
    public string getLastUpdatedDate() throws GLib.Error {
        string json_body = makeGetRequest(@"$(this.baseUrl)/crime-last-updated");

        //  Example response body: {"date":"2026-05-01"}
        var parser = new Json.Parser ();
        parser.load_from_data (json_body, -1);

        var root = parser.get_root().get_object();
        return root.get_string_member("date");
    }

    /**
     * @see <a href="https://data.police.uk/docs/method/senior-officers/">API doc: Senior officers</a>
     *
     * @param policeForce the {@link PoliceForce}
     * @return a list of senior officers for the given police force
     */
    public owned GLib.List<SeniorOfficer> getPoliceForceSeniorOfficers(PoliceForce policeForce) throws GLib.Error {
        string json_body = makeGetRequest(@"$(this.baseUrl)/forces/$(policeForce.id)/people");

        Json.Parser p = new Json.Parser();

        GLib.List<SeniorOfficer> officers = new GLib.List<SeniorOfficer>();

        p.array_element.connect ((pars, array, index) => {
            officers.append(
                Json.gobject_deserialize(typeof(SeniorOfficer), array.get_element (index)) as SeniorOfficer
            );
        });
        p.load_from_data(json_body, json_body.length);

        GLib.info(@"API returned $(officers.length()) officers for $(policeForce.id)");

        return (owned) officers;
    }

    /**
     * @see <a href="https://data.police.uk/docs/method/neighbourhoods/">API doc: List of neighbourhoods for a force</a>
     *
     * @param policeForce the {@link PoliceForce}
     * @return a list of neighbourhoods
     */
    public owned GLib.List<Neighbourhood> getPoliceForceNeighbourhoods(PoliceForce policeForce) throws GLib.Error{
        string json_body = makeGetRequest(@"$(this.baseUrl)/$(policeForce.id)/neighbourhoods");

        Json.Parser p = new Json.Parser();

        GLib.List<Neighbourhood> neighbourhoods = new GLib.List<Neighbourhood>();

        p.array_element.connect ((pars, array, index) => {
            neighbourhoods.append(
                Json.gobject_deserialize(typeof(Neighbourhood), array.get_element (index)) as Neighbourhood
            );
        });
        p.load_from_data(json_body, json_body.length);

        GLib.info(@"API returned $(neighbourhoods.length()) neighbourhoods");
            
        return (owned) neighbourhoods;
    }

    /**
     * @see <a href="https://data.police.uk/docs/method/neighbourhood/">API doc: Specific neighbourhood</a>
     *
     * @param policeForce the {@link PoliceForce}
     * @param id the neighbourhood id
     * @return a neighbourhood by id
     */
    public Neighbourhood getPoliceForceNeighbourhood(PoliceForce policeForce, string id) throws GLib.Error {
        string json_body = makeGetRequest(@"$(this.baseUrl)/$(policeForce.id)/id");
        Neighbourhood neighbourhood = Json.gobject_from_data(typeof(Neighbourhood), json_body, json_body.length) as Neighbourhood;

        GLib.info("API returned neighbourhood for %s : %s", policeForce.id, id);

        return neighbourhood;
    }

    public owned GLib.List<Crime> streetCrimeByLocation(string latitude, string longitude) throws GLib.Error {
        string json_body = makeGetRequest(@"$(this.baseUrl)/crimes-street/all-crime?lat=$(latitude)&lng=$(longitude)");

        Json.Parser p = new Json.Parser();

        GLib.List<Crime> crimes = new GLib.List<Crime>();

        p.array_element.connect ((pars, array, index) => {
            crimes.append(
                Json.gobject_deserialize(typeof(Crime), array.get_element (index)) as Crime
            );
        });
        p.load_from_data(json_body, json_body.length);

        GLib.info(@"API returned $(crimes.length()) crimes");
            
        return (owned) crimes;
    }

    public owned GLib.List<PoliceForce> getAllPoliceForces() throws GLib.Error {
        string json_body = makeGetRequest(@"$(this.baseUrl)/forces");

        Json.Parser p = new Json.Parser();

        GLib.List<PoliceForce> forces = new GLib.List<PoliceForce>();

        p.array_element.connect ((pars, array, index) => {
            forces.append(
                Json.gobject_deserialize(typeof(PoliceForce), array.get_element (index)) as PoliceForce
            );
        });
        p.load_from_data(json_body, json_body.length);

        GLib.info(@"API returned $(forces.length()) police forces");
            
        return (owned) forces;
    }

    public PoliceForceDetails getPoliceForceById(string policeForceId) throws GLib.Error {
        string json_body = makeGetRequest(@"$(this.baseUrl)/forces/$(policeForceId)");
        
        PoliceForceDetails details = Json.gobject_from_data(typeof(PoliceForceDetails), json_body, json_body.length) as PoliceForceDetails;

        GLib.info("API returned details for %s : '(%s)'", policeForceId, details.name);

        return details;
    }

    private string makeGetRequest(string url) throws GLib.Error {
        var session = new Soup.Session.with_options ("user_agent", "gtk4 crime app");
        session.timeout = 3;

        // todo: configure headers:
        // "Accept-Language", "en-GB"
        // "Content-Type", "application/json"
        // "Accept", "application/json"

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