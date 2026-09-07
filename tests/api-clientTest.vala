using GLib;

private const string TEST_FORCE_ID = "FORCE-ID";

public void test_getLastUpdatedDate () {
    var port = Environment.get_variable ("WIREMOCK_PORT") ?? "8080";
    var api = new PoliceApi ("http://localhost:" + port + "/api");

    var result = api.getLastUpdatedDate ();
    assert_nonnull (result);
    assert_cmpstr ( result, CompareOperator.EQ, "2026-07-01");
}

public void test_getPoliceForceSeniorOfficers () {
    var port = Environment.get_variable ("WIREMOCK_PORT") ?? "8080";
    var api = new PoliceApi ("http://localhost:" + port + "/api");

    var result = api.getPoliceForceSeniorOfficers (TEST_FORCE_ID);
    assert_nonnull (result);
}

public void test_getPoliceForceNeighbourhoods () {
    var port = Environment.get_variable ("WIREMOCK_PORT") ?? "8080";
    var api = new PoliceApi ("http://localhost:" + port + "/api");

    var result = api.getPoliceForceNeighbourhoods (TEST_FORCE_ID);
    assert_nonnull (result);
}

public void test_getPoliceForceNeighbourhood () {
    var port = Environment.get_variable ("WIREMOCK_PORT") ?? "8080";
    var api = new PoliceApi ("http://localhost:" + port + "/api");

    var result = api.getPoliceForceNeighbourhood (TEST_FORCE_ID, "suburb");
    assert_nonnull (result);
}

public void test_streetCrimeByLocation () {
    var port = Environment.get_variable ("WIREMOCK_PORT") ?? "8080";
    var api = new PoliceApi ("http://localhost:" + port + "/api");

    var result = api.streetCrimeByLocation ("lat", "lng");
    assert_nonnull (result);
}

public void test_getAllPoliceForces () {
    var port = Environment.get_variable ("WIREMOCK_PORT") ?? "8080";
    var api = new PoliceApi ("http://localhost:" + port + "/api");
    
    var result = api.getAllPoliceForces ();
    assert_nonnull (result);

    assert_cmpuint ( result.length (), CompareOperator.EQ, 2);
    foreach (var pf in result) {
        assert_true ( pf is PoliceForce );
        assert_nonnull (pf);
        assert_nonnull (pf.id);
        assert_nonnull (pf.name);
    }
}

public void test_getPoliceForceById () {
    var port = Environment.get_variable ("WIREMOCK_PORT") ?? "8080";
    var api = new PoliceApi ("http://localhost:" + port + "/api");

    var result = api.getPoliceForceById (TEST_FORCE_ID);
    assert_nonnull (result);
    assert_true ( result is PoliceForceDetails );
    assert_nonnull (result);
    assert_nonnull (result.id);
    assert_nonnull (result.name);
    assert_nonnull (result.url);
    assert_nonnull (result.telephone);
    assert_nonnull (result.description);
}

public int main (string[] args) {
    Test.init (ref args);

    // test names need to start with '/'
    Test.add_func ("/API Client/getAllPoliceForces", test_getAllPoliceForces);
    Test.add_func ("/API Client/getPoliceForceById", test_getPoliceForceById);
    return Test.run ();
}