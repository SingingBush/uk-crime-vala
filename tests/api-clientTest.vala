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

    assert_cmpuint ( result.length (), CompareOperator.EQ, 1);

    SeniorOfficer officer = result.nth_data (0) as SeniorOfficer;
    assert_nonnull (officer);
    assert_cmpstr (officer.name, CompareOperator.EQ, "Bobby");
    assert_cmpstr (officer.rank, CompareOperator.EQ, "Flat Foot");
}

public void test_getPoliceForceNeighbourhoods () {
    var port = Environment.get_variable ("WIREMOCK_PORT") ?? "8080";
    var api = new PoliceApi ("http://localhost:" + port + "/api");

    var result = api.getPoliceForceNeighbourhoods (TEST_FORCE_ID);
    assert_nonnull (result);

    assert_cmpuint ( result.length (), CompareOperator.EQ, 1);

    Neighbourhood neighbourhood = result.nth_data (0) as Neighbourhood;
    assert_nonnull (neighbourhood);

    assert_cmpstr (neighbourhood.id, CompareOperator.EQ, "suburb-id");
    assert_cmpstr (neighbourhood.name, CompareOperator.EQ, "Suburb Name");
    assert_null (neighbourhood.description);
    assert_null (neighbourhood.centre);
    assert_null (neighbourhood.url_force);
    assert_null (neighbourhood.population);
}

public void test_getPoliceForceNeighbourhood () {
    var port = Environment.get_variable ("WIREMOCK_PORT") ?? "8080";
    var api = new PoliceApi ("http://localhost:" + port + "/api");

    var result = api.getPoliceForceNeighbourhood (TEST_FORCE_ID, "suburb-id");
    assert_nonnull (result);
    assert_cmpstr (result.id, CompareOperator.EQ, "suburb-id");
    assert_cmpstr (result.name, CompareOperator.EQ, "Suburb Name");
    assert_cmpstr (result.description, CompareOperator.EQ, "blah blah blah");
    assert_nonnull (result.centre);
    assert_cmpstr (result.centre.latitude, CompareOperator.EQ, "12345");
    assert_cmpstr (result.centre.longitude, CompareOperator.EQ, "12345");
    assert_cmpstr (result.url_force, CompareOperator.EQ, "http://www.local.police.uk/town");
    assert_cmpstr (result.population, CompareOperator.EQ, "0");
}

public void test_getStreetCrimeByLocation () {
    var port = Environment.get_variable ("WIREMOCK_PORT") ?? "8080";
    var api = new PoliceApi ("http://localhost:" + port + "/api");

    var result = api.getStreetCrimeByLocation ("lat", "lng");
    assert_nonnull (result);

    assert_cmpuint ( result.length (), CompareOperator.EQ, 2);
    foreach (var c in result) {
        assert_true ( c is Crime );
        assert_cmpuint (c.id, CompareOperator.GT, 100000000);
        assert_nonnull (c.category);
        assert_nonnull (c.location);
        assert_nonnull (c.month);
    }
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
    Test.add_func ("/API Client/getLastUpdatedDate", test_getLastUpdatedDate);
    Test.add_func ("/API Client/getPoliceForceSeniorOfficers", test_getPoliceForceSeniorOfficers);
    Test.add_func ("/API Client/getPoliceForceNeighbourhoods", test_getPoliceForceNeighbourhoods);
    Test.add_func ("/API Client/getPoliceForceNeighbourhood", test_getPoliceForceNeighbourhood);
    Test.add_func ("/API Client/getStreetCrimeByLocation", test_getStreetCrimeByLocation);
    Test.add_func ("/API Client/getAllPoliceForces", test_getAllPoliceForces);
    Test.add_func ("/API Client/getPoliceForceById", test_getPoliceForceById);
    return Test.run ();
}