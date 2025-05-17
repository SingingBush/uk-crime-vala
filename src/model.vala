

public class PoliceForce : GLib.Object {

    public string id { get; set; }

    public string name { get; set; }

}

/*
 * When requesting a police force by id further details are returned
 */
public class PoliceForceDetails : PoliceForce {
    public string telephone { get; set; } // fairly pointless as it's always 101

    public string url { get; set; } // only populated when getting single object

    public string description { get; set; } // either null or a description which may have basic html tags such as <p>
}