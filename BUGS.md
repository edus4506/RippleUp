# Bug Log

This file documents defects found during development and testing, together with their resolution and verification status.

---

## BUG-01 — Ambiguous widget match in participant limit test

**Category:** Testing / UI Test  
**Status:** Fixed  
**Priority:** Medium

**Description:**  
The participant limit integration test failed because the test was trying to locate a widget using duplicated text, which caused an ambiguous match.

**Steps to reproduce:**
1. Run the participant limit integration test.
2. Open the activity list.
3. The test searches for an event using a text finder that matches more than one widget.

**Expected result:**  
The test should identify exactly one widget corresponding to the intended event.

**Actual result:**  
The test failed because more than one widget matched the same text.

**Cause:**  
The UI contained repeated text values, making the finder too generic.

**Fix implemented:**  
Specific widget keys were added and the test was updated to target the intended widget directly.

**Verification:**  
The integration test was run again after the fix and passed successfully.

---

## BUG-02 — Create event widget test failed because dropdown fields were off-screen

**Category:** Testing / UI Test  
**Status:** Fixed  
**Priority:** Medium

**Description:**  
The create event widget test failed when trying to interact with dropdown fields that were outside the visible area of the dialog.

**Steps to reproduce:**
1. Run the create event widget test.
2. Open the create event dialog.
3. Fill the text fields.
4. Try to tap the country, district, or city dropdowns directly.

**Expected result:**  
The test should interact with the dropdown fields and continue normally.

**Actual result:**  
The test failed because the tap did not hit the intended widget, since it was not visible on screen.

**Cause:**  
The create event dialog uses a scrollable layout, and the dropdowns were positioned below the visible viewport during test execution.

**Fix implemented:**  
The test was updated to scroll inside the dialog and ensure the dropdown widgets were visible before interacting with them.

**Verification:**  
The widget test was rerun and passed successfully after the fix.

---

## BUG-03 — Deprecated DropdownButtonFormField property generated analyzer warnings

**Category:** Code Quality / Maintainability  
**Status:** Fixed  
**Priority:** Low

**Description:**  
The project generated analyzer warnings because `DropdownButtonFormField` was using the deprecated `value` property.

**Steps to reproduce:**
1. Run `dart analyze`.
2. Observe warnings in `create_event_page.dart` and `event_filter_page.dart`.

**Expected result:**  
The analyzer should complete without warnings related to deprecated API usage.

**Actual result:**  
Analyzer warnings were shown indicating that `value` is deprecated and should be replaced with `initialValue`.

**Cause:**  
The code was using an outdated property that had been deprecated in the current Flutter version.

**Fix implemented:**  
All affected `DropdownButtonFormField` widgets were updated to use `initialValue` instead of `value`.

**Verification:**  
`dart analyze` was run again after the fix and completed successfully without those warnings.

---

## Summary

The defects above were identified during development and testing activities and were resolved before integration into the main branch. Their correction improved both the reliability of the test suite and the overall code quality of the project.