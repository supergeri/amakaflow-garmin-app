using Toybox.Test;

//! Unit tests for CommManager functionality
module CommManagerTests {

    //! Test that CommManager initializes with correct default state
    (:test)
    function testCommManagerInitialState(logger) {
        var comm = new CommManager();

        Test.assertEqual(comm.isPhoneConnected(), false);
        Test.assertEqual(comm.retryCount, 0);

        logger.debug("CommManager initialized with correct defaults");
        return true;
    }

    //! Test getDebugStatus format
    (:test)
    function testGetDebugStatus(logger) {
        var comm = new CommManager();

        var status = comm.getDebugStatus();

        // Status should contain Phone and App indicators
        Test.assert(status.find("Phone:") != null);
        Test.assert(status.find("App:") != null);
        Test.assert(status.find("Attempts:") != null);

        logger.debug("getDebugStatus returns formatted string: " + status);
        return true;
    }

    //! Test retry count increments on transmit error
    (:test)
    function testRetryCountIncrementsOnError(logger) {
        var comm = new CommManager();

        Test.assertEqual(comm.retryCount, 0);

        // Simulate transmit error
        comm.onTransmitError();
        Test.assertEqual(comm.retryCount, 1);

        comm.onTransmitError();
        Test.assertEqual(comm.retryCount, 2);

        logger.debug("Retry count increments correctly on errors");
        return true;
    }

    //! Test retry count resets on successful transmit
    (:test)
    function testRetryCountResetsOnSuccess(logger) {
        var comm = new CommManager();

        // Simulate errors
        comm.onTransmitError();
        comm.onTransmitError();
        Test.assertEqual(comm.retryCount, 2);

        // Simulate success
        comm.onTransmitComplete();
        Test.assertEqual(comm.retryCount, 0);
        Test.assertEqual(comm.isPhoneConnected(), true);

        logger.debug("Retry count resets on successful transmit");
        return true;
    }

    //! Test that isConnected updates on transmit complete
    (:test)
    function testIsConnectedUpdatesOnComplete(logger) {
        var comm = new CommManager();

        Test.assertEqual(comm.isPhoneConnected(), false);

        comm.onTransmitComplete();
        Test.assertEqual(comm.isPhoneConnected(), true);

        logger.debug("isConnected updates correctly on transmit complete");
        return true;
    }

    //! Test that isConnected updates on transmit error
    (:test)
    function testIsConnectedUpdatesOnError(logger) {
        var comm = new CommManager();

        // First set connected
        comm.onTransmitComplete();
        Test.assertEqual(comm.isPhoneConnected(), true);

        // Then simulate error
        comm.onTransmitError();
        Test.assertEqual(comm.isPhoneConnected(), false);

        logger.debug("isConnected updates correctly on transmit error");
        return true;
    }

    //! Test MAX_RETRIES constant
    (:test)
    function testMaxRetriesConstant(logger) {
        var comm = new CommManager();

        Test.assertEqual(comm.MAX_RETRIES, 3);

        logger.debug("MAX_RETRIES is set to 3");
        return true;
    }
}
