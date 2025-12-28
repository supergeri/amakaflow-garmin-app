using Toybox.Test;

//! Unit tests for WorkoutState functionality
module WorkoutStateTests {

    //! Test that WorkoutState initializes with idle phase
    (:test)
    function testWorkoutStateInitialPhase(logger) {
        var state = new WorkoutState();

        Test.assertEqual(state.phase, "idle");
        Test.assertEqual(state.isIdle(), true);
        Test.assertEqual(state.isActive(), false);
        Test.assertEqual(state.isRunning(), false);
        Test.assertEqual(state.isPaused(), false);

        logger.debug("WorkoutState initialized with idle phase");
        return true;
    }

    //! Test that isActive returns true for running state
    (:test)
    function testIsActiveWhenRunning(logger) {
        var state = new WorkoutState();

        var msg = {
            "phase" => "running",
            "stepName" => "Push Ups",
            "stepType" => "reps",
            "stepIndex" => 0,
            "stepCount" => 5
        };
        state.update(msg);

        Test.assertEqual(state.isActive(), true);
        Test.assertEqual(state.isRunning(), true);
        Test.assertEqual(state.isPaused(), false);
        Test.assertEqual(state.isIdle(), false);

        logger.debug("isActive correctly returns true when running");
        return true;
    }

    //! Test that isActive returns true for paused state
    (:test)
    function testIsActiveWhenPaused(logger) {
        var state = new WorkoutState();

        var msg = {
            "phase" => "paused",
            "stepName" => "Rest",
            "stepType" => "timed",
            "stepIndex" => 1,
            "stepCount" => 5
        };
        state.update(msg);

        Test.assertEqual(state.isActive(), true);
        Test.assertEqual(state.isPaused(), true);
        Test.assertEqual(state.isRunning(), false);

        logger.debug("isActive correctly returns true when paused");
        return true;
    }

    //! Test that isActive returns false for idle state
    (:test)
    function testIsActiveWhenIdle(logger) {
        var state = new WorkoutState();

        var msg = {
            "phase" => "idle"
        };
        state.update(msg);

        Test.assertEqual(state.isActive(), false);
        Test.assertEqual(state.isIdle(), true);

        logger.debug("isActive correctly returns false when idle");
        return true;
    }

    //! Test that isActive returns false for ended state
    (:test)
    function testIsActiveWhenEnded(logger) {
        var state = new WorkoutState();

        var msg = {
            "phase" => "ended",
            "stepName" => "Cool Down",
            "stepIndex" => 4,
            "stepCount" => 5
        };
        state.update(msg);

        Test.assertEqual(state.isActive(), false);

        logger.debug("isActive correctly returns false when ended");
        return true;
    }

    //! Test workout state transition from idle to running
    (:test)
    function testTransitionIdleToRunning(logger) {
        var state = new WorkoutState();

        // Initially idle
        Test.assertEqual(state.isIdle(), true);
        var wasActive = state.isActive();
        Test.assertEqual(wasActive, false);

        // Transition to running
        var msg = {
            "phase" => "running",
            "stepName" => "Warm Up",
            "stepType" => "timed",
            "remainingMs" => 60000,
            "stepIndex" => 0,
            "stepCount" => 5
        };
        state.update(msg);

        var isNowActive = state.isActive();
        Test.assertEqual(isNowActive, true);

        // Verify transition detected
        Test.assertEqual(wasActive, false);
        Test.assertEqual(isNowActive, true);
        Test.assertNotEqual(wasActive, isNowActive);

        logger.debug("Transition from idle to running detected correctly");
        return true;
    }

    //! Test workout state transition from running to ended
    (:test)
    function testTransitionRunningToEnded(logger) {
        var state = new WorkoutState();

        // Start in running state
        var startMsg = {
            "phase" => "running",
            "stepName" => "Exercise",
            "stepType" => "reps",
            "stepIndex" => 0,
            "stepCount" => 1
        };
        state.update(startMsg);
        var wasActive = state.isActive();
        Test.assertEqual(wasActive, true);

        // Transition to ended
        var endMsg = {
            "phase" => "ended"
        };
        state.update(endMsg);

        var isNowActive = state.isActive();
        Test.assertEqual(isNowActive, false);

        // Verify transition detected
        Test.assertEqual(wasActive, true);
        Test.assertEqual(isNowActive, false);
        Test.assertNotEqual(wasActive, isNowActive);

        logger.debug("Transition from running to ended detected correctly");
        return true;
    }

    //! Test update with step details
    (:test)
    function testUpdateStepDetails(logger) {
        var state = new WorkoutState();

        var msg = {
            "phase" => "running",
            "stepName" => "Jumping Jacks",
            "stepType" => "reps",
            "stepIndex" => 2,
            "stepCount" => 8,
            "targetReps" => 20,
            "roundInfo" => "Round 2 of 3"
        };
        state.update(msg);

        Test.assertEqual(state.stepName, "Jumping Jacks");
        Test.assertEqual(state.stepType, "reps");
        Test.assertEqual(state.stepIndex, 2);
        Test.assertEqual(state.stepCount, 8);
        Test.assertEqual(state.targetReps, 20);
        Test.assertEqual(state.roundInfo, "Round 2 of 3");

        logger.debug("Step details updated correctly");
        return true;
    }

    //! Test update with timed step
    (:test)
    function testUpdateTimedStep(logger) {
        var state = new WorkoutState();

        var msg = {
            "phase" => "running",
            "stepName" => "Rest",
            "stepType" => "timed",
            "remainingMs" => 30000,
            "stepIndex" => 3,
            "stepCount" => 8
        };
        state.update(msg);

        Test.assertEqual(state.stepName, "Rest");
        Test.assertEqual(state.stepType, "timed");
        Test.assertEqual(state.remainingMs, 30000);

        logger.debug("Timed step details updated correctly");
        return true;
    }

    //! Test reset functionality
    (:test)
    function testReset(logger) {
        var state = new WorkoutState();

        // Set some state
        var msg = {
            "phase" => "running",
            "stepName" => "Exercise",
            "stepIndex" => 5,
            "stepCount" => 10,
            "targetReps" => 15
        };
        state.update(msg);

        // Reset
        state.reset();

        Test.assertEqual(state.phase, "idle");
        Test.assertEqual(state.stepName, "");
        Test.assertEqual(state.stepIndex, 0);
        Test.assertEqual(state.stepCount, 0);
        Test.assertEqual(state.targetReps, 0);
        Test.assertEqual(state.isIdle(), true);

        logger.debug("Reset correctly clears all state");
        return true;
    }

    //! Test getFormattedTime for various durations
    (:test)
    function testGetFormattedTime(logger) {
        var state = new WorkoutState();

        // Test 30 seconds
        state.update({"remainingMs" => 30000});
        Test.assertEqual(state.getFormattedTime(), "0:30");

        // Test 1 minute 30 seconds
        state.update({"remainingMs" => 90000});
        Test.assertEqual(state.getFormattedTime(), "1:30");

        // Test 5 minutes
        state.update({"remainingMs" => 300000});
        Test.assertEqual(state.getFormattedTime(), "5:00");

        // Test 0 seconds (for reps)
        state.update({"remainingMs" => 0});
        Test.assertEqual(state.getFormattedTime(), "--:--");

        logger.debug("getFormattedTime formats correctly");
        return true;
    }

    //! Test getProgress calculation
    (:test)
    function testGetProgress(logger) {
        var state = new WorkoutState();

        // Step 1 of 4 = 25%
        state.update({"stepIndex" => 0, "stepCount" => 4});
        var progress = state.getProgress();
        Test.assert(progress >= 0.24 && progress <= 0.26);

        // Step 2 of 4 = 50%
        state.update({"stepIndex" => 1, "stepCount" => 4});
        progress = state.getProgress();
        Test.assert(progress >= 0.49 && progress <= 0.51);

        // Step 4 of 4 = 100%
        state.update({"stepIndex" => 3, "stepCount" => 4});
        progress = state.getProgress();
        Test.assert(progress >= 0.99 && progress <= 1.01);

        logger.debug("getProgress calculates correctly");
        return true;
    }

    //! Test getStepProgressText
    (:test)
    function testGetStepProgressText(logger) {
        var state = new WorkoutState();

        state.update({"stepIndex" => 2, "stepCount" => 8});
        Test.assertEqual(state.getStepProgressText(), "3 of 8");

        state.update({"stepIndex" => 0, "stepCount" => 5});
        Test.assertEqual(state.getStepProgressText(), "1 of 5");

        logger.debug("getStepProgressText formats correctly");
        return true;
    }
}
