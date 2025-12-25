#!/bin/bash
# Verification script to check if Garmin and iOS code are in sync
# Run this before deploying to catch missing fields

echo "=== AmakaFlow Sync Verification ==="
echo ""

# Check Garmin WorkoutState.mc for targetReps
echo "1. Checking Garmin WorkoutState.mc..."
if grep -q "var targetReps" source/WorkoutState.mc; then
    echo "   ✓ targetReps field exists"
else
    echo "   ✗ MISSING: targetReps field in WorkoutState.mc"
fi

if grep -q "var roundInfo" source/WorkoutState.mc; then
    echo "   ✓ roundInfo field exists"
else
    echo "   ✗ MISSING: roundInfo field in WorkoutState.mc"
fi

# Check Garmin WorkoutRemoteView.mc
echo ""
echo "2. Checking Garmin WorkoutRemoteView.mc..."
if grep -q 'dict.put("targetReps"' source/WorkoutRemoteView.mc; then
    echo "   ✓ targetReps in getDisplayState()"
else
    echo "   ✗ MISSING: targetReps in getDisplayState()"
fi

# Check iOS WorkoutState.swift
IOS_PATH="../amakaflow-ios-app/amakaflow-ios-app/AmakaFlow"
echo ""
echo "3. Checking iOS WorkoutState.swift..."
if grep -q "let targetReps:" "$IOS_PATH/Engine/WorkoutState.swift"; then
    echo "   ✓ targetReps property exists"
else
    echo "   ✗ MISSING: targetReps in WorkoutState.swift"
fi

# Check iOS GarminConnectManager.swift
echo ""
echo "4. Checking iOS GarminConnectManager.swift..."
if grep -q '"targetReps":' "$IOS_PATH/Services/GarminConnectManager.swift"; then
    echo "   ✓ targetReps in buildStateMessage()"
else
    echo "   ✗ MISSING: targetReps in GarminConnectManager buildStateMessage()"
fi

# Check iOS FlattenedInterval.swift
echo ""
echo "5. Checking iOS FlattenedInterval.swift..."
if grep -q "let targetReps:" "$IOS_PATH/Engine/FlattenedInterval.swift"; then
    echo "   ✓ targetReps property exists"
else
    echo "   ✗ MISSING: targetReps in FlattenedInterval.swift"
fi

# Check iOS WorkoutEngine.swift
echo ""
echo "6. Checking iOS WorkoutEngine.swift..."
if grep -q "targetReps: currentStep" "$IOS_PATH/Engine/WorkoutEngine.swift"; then
    echo "   ✓ targetReps in buildCurrentState()"
else
    echo "   ✗ MISSING: targetReps in WorkoutEngine buildCurrentState()"
fi

echo ""
echo "=== Version Check ==="
GARMIN_VERSION=$(grep 'APP_VERSION' source/AmakaFlowApp.mc | sed 's/.*"\(.*\)".*/\1/')
echo "Garmin app version: $GARMIN_VERSION"

echo ""
echo "=== Summary ==="
echo "If all checks pass (✓), rebuild BOTH:"
echo "  1. Garmin IQ file: monkeyc -o bin/AmakaFlow.iq ..."
echo "  2. iOS app in Xcode: Cmd+R"
echo ""
echo "Then deploy BOTH to devices!"
