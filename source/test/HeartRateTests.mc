using Toybox.Test;

//! Unit tests for HeartRateManager functionality
module HeartRateTests {

    //! Test that HeartRateManager initializes with correct default state
    (:test)
    function testHeartRateManagerInitialState(logger) {
        var comm = new CommManager();
        var hrManager = new HeartRateManager(comm);

        // Initial state should be not streaming and no HR available
        Test.assertEqual(hrManager.isCurrentlyStreaming(), false);
        Test.assertEqual(hrManager.isAvailable(), false);
        // Use assert instead of assertEqual for null comparison
        Test.assert(hrManager.getCurrentHR() == null);

        logger.debug("HeartRateManager initialized with correct defaults");
        return true;
    }

    //! Test that getCurrentHR returns null when not streaming
    (:test)
    function testGetCurrentHRWhenNotStreaming(logger) {
        var comm = new CommManager();
        var hrManager = new HeartRateManager(comm);

        var hr = hrManager.getCurrentHR();
        // Use assert instead of assertEqual for null comparison
        Test.assert(hr == null);

        logger.debug("getCurrentHR correctly returns null when not streaming");
        return true;
    }

    //! Test that isAvailable returns false initially
    (:test)
    function testIsAvailableInitiallyFalse(logger) {
        var comm = new CommManager();
        var hrManager = new HeartRateManager(comm);

        Test.assertEqual(hrManager.isAvailable(), false);

        logger.debug("isAvailable correctly returns false initially");
        return true;
    }

    //! Test that stopStreaming works when not streaming
    (:test)
    function testStopStreamingWhenNotStreaming(logger) {
        var comm = new CommManager();
        var hrManager = new HeartRateManager(comm);

        // Should not throw an error when stopping while not streaming
        hrManager.stopStreaming();

        Test.assertEqual(hrManager.isCurrentlyStreaming(), false);
        Test.assertEqual(hrManager.getUnavailableReason(), "");

        logger.debug("stopStreaming handles not-streaming state gracefully");
        return true;
    }
}
