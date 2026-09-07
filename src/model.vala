
/**
 * base class for API data that has string values for id and name.
 * eg: PoliceForce, PoliceForceDetails, and Neighbourhood
 */
public abstract class NamedData : GLib.Object {
    public string id { get; set; }

    public string name { get; set; }
}

public class PoliceForce : NamedData {}

/*
 * When requesting a police force by id further details are returned
 */
public class PoliceForceDetails : PoliceForce {
    public string telephone { get; set; } // fairly pointless as it's always 101

    public string url { get; set; } // only populated when getting single object

    public string description { get; set; } // either null or a description which may have basic html tags such as <p>
}

public class Neighbourhood : NamedData {
    public string description { get; set; } // usually null

    public string population { get; set; }

    public string url_force { get; set; }

    public Location centre { get; set; }
}

public class SeniorOfficer : GLib.Object {
    public string name { get; set; }

    public string rank { get; set; }

    public Gee.HashMap<string,string> contact_details { get; set; }

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