

public class PoliceForce : GLib.Object {

    //public PoliceForce(string id, string name) {
    //    this.id = id;
    //    this.name = name;
    //}

    public string id { get; set; }

    public string name { get; set; }

}

/*
 * When requesting a police force by id further details are returned
 */
public class PoliceForceDetails : PoliceForce {

    //public PoliceForceDetails(string id, string name) {
    //    base(id, name);
    //}

    public string telephone { get; set; } // fairly pointless as it's always 101

    public string url { get; set; } // only populated when getting single object

    public string description { get; set; } // either null or a description which may have basic html tags such as <p>
}

public class Neighbourhood : GLib.Object {
    public string id { get; set; }

    public string name { get; set; }

    public string description { get; set; } // usually null

    public string population { get; set; }

    public string url_force { get; set; }
}

public class SeniorOfficer : GLib.Object {
    public string name { get; set; }

    public string rank { get; set; }

    // there's a Map of str,str for contact_details

    public string bio { get; set; } // usually null
}

public class Location : GLib.Object {
    public string latitude { get; set; }
    public string longitude { get; set; }
}

public class OutcomeStatus : GLib.Object {
    public string category { get; set; }
    public string date { get; set; } // month only
}

public class Crime : GLib.Object {
    public uint id { get; set; } // todo: check number type
    public string category { get; set; }
    public string location_type { get; set; }
    public Location location { get; set; }
    public string location_subtype { get; set; }
    public string context { get; set; }
    public OutcomeStatus outcome_status { get; set; }
    public string persistent_id { get; set; }
    public string month { get; set; }
}