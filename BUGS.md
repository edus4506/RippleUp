# Bug Log

This file documents defects found during development and testing, together with their resolution and verification status.

---

## BUG-01 — Ambiguous widget match in participant limit test

**Category:** Testing / UI Test  
**Status:** Fixed  
**Priority:** Medium

**Description:**  
The participant limit automated test failed because the test was trying to locate a widget using duplicated text, which caused an ambiguous match.

**Steps to reproduce:**
1. Run the participant limit test.
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
The test was run again after the fix and passed successfully.

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
2. Observe warnings in `create_event_page.dart` and `event_filter_dialog.dart`.

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

## BUG-04 — City field was not reset after changing district

**Category:** Feature / Event Location  
**Status:** Fixed  
**Priority:** Medium

**Description:**  
When creating or filtering an event, changing the selected district did not always reset the selected city. This could leave an invalid city selected for the new district.

**Steps to reproduce:**
1. Open the event creation form or event filter dialog.
2. Select a district and then select a city from that district.
3. Change the district to a different one.
4. Observe the selected city field.

**Expected result:**  
When the district changes, the city field should reset and only show cities that belong to the newly selected district.

**Actual result:**  
The previously selected city could remain selected, even if it did not belong to the new district.

**Cause:**  
The city dropdown state was not always updated when the parent district value changed.

**Fix implemented:**  
The location selection logic was updated so that changing the district resets the selected city and reloads the correct list of available cities.

**Verification:**  
The event creation and filtering flows were tested again by changing districts and confirming that the city dropdown was correctly reset.

---

## BUG-05 — Review list was not immediately updated after deleting a review

**Category:** Feature / Reviews  
**Status:** Fixed  
**Priority:** Medium

**Description:**  
After a user deleted one of their reviews, the review could still appear on the feedback page until the page was refreshed or reopened.

**Steps to reproduce:**
1. Open the feedback page of an event.
2. Create or select an existing review made by the current user.
3. Delete the review.
4. Observe the review list.

**Expected result:**  
After deletion, the review should immediately disappear from the list.

**Actual result:**  
The deleted review could remain visible temporarily, creating the impression that the deletion had failed.

**Cause:**  
The review list state was not being refreshed immediately after the delete operation.

**Fix implemented:**  
The review deletion flow was updated to refresh the review list after a successful delete operation.

**Verification:**  
The feedback page was tested again by deleting reviews and confirming that the list updated immediately after the operation.

---

## BUG-06 — Flutter web server failed when executed from the wrong directory

**Category:** Development Environment / Execution  
**Status:** Fixed  
**Priority:** Low

**Description:**  
During development, the Flutter web server produced errors when Flutter commands were executed from inside generated build folders instead of the project root.

**Steps to reproduce:**
1. Navigate into a generated build folder, such as `build/web`.
2. Run Flutter commands from that directory.
3. Try to clean, build, or run the web server.

**Expected result:**  
Flutter commands should be executed correctly from the project root, where `pubspec.yaml` is located.

**Actual result:**  
Flutter failed to locate the expected project structure and produced errors related to invalid working directories or missing files.

**Cause:**  
The commands were executed from the wrong directory instead of the Flutter project root.

**Fix implemented:**  
The team documented the correct development workflow and ensured that Flutter commands are executed from the project root directory.

**Verification:**  
The commands were rerun from the project root and the web server/build workflow executed correctly.

---

## Summary

The defects above were identified during development and testing activities and were resolved before integration into the main branch. Their correction improved the reliability of the test suite, the consistency of event location handling, the review management experience, the overall code quality of the project, and the stability of the local development workflow.
