using GLib;

private const string TEST_FORCE_ID = "FORCE-ID";

public void test_getAllPoliceForces () {
    var api = new PoliceApi ("http://localhost:8080/api");
    
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
    var api = new PoliceApi ("http://localhost:8080/api");

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