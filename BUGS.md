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

---

## BUG-07 — Event search caused noticeable UI lag

**Category:** Feature / Event Feed  
**Status:** Fixed  
**Priority:** Medium

**Description:**  
The event search in the feed fired a listener notification on every keystroke, causing unnecessary rebuilds and visible lag in the results list.

**Steps to reproduce:**
1. Open the home feed.
2. Type quickly in the search field.
3. Observe the results list updating with a noticeable delay.

**Expected result:**  
Results should update smoothly without excessive rebuilds.

**Actual result:**  
Each keystroke triggered an immediate notification, resulting in lag and redundant processing.

**Cause:**  
`EventViewModel.updateSearchQuery` called `notifyListeners` immediately without any debounce.

**Fix implemented:**  
A 300ms debounce was added to `updateSearchQuery` so that listeners are only notified after the user stops typing.

**Verification:**  
Search was tested manually and confirmed to feel responsive without triggering excessive rebuilds.

---

## BUG-08 — Users could send messages in event chats they had not joined

**Category:** Feature / Event Chat  
**Status:** Fixed  
**Priority:** High

**Description:**  
The event chat accessible from the DMs page did not check whether the current user was a participant in the event before allowing them to send messages.

**Steps to reproduce:**
1. Obtain the chat ID of an event the current user has not joined.
2. Navigate to the event chat from the DMs page.
3. Attempt to send a message.

**Expected result:**  
Non-participants should not be able to send messages in an event chat.

**Actual result:**  
The send button was active and messages could be submitted by any user regardless of participation.

**Cause:**  
Participation was not verified before enabling the message input.

**Fix implemented:**  
A participation check was added before allowing message submission in the event chat.

**Verification:**  
Tested with a user who is not a participant — the input is now blocked for non-participants.

---

## BUG-09 — Firebase query for EventChat returned wrong or empty results

**Category:** Feature / Event Chat / Firebase  
**Status:** Fixed  
**Priority:** High

**Description:**  
The Firestore query used to fetch event chat messages from the DMs page pointed to the wrong collection path, causing messages not to load.

**Steps to reproduce:**
1. Join an event that has existing chat activity.
2. Open the DMs page and tap the event chat entry.
3. Observe that messages are missing or the page appears blank.

**Expected result:**  
Event chat messages should load correctly.

**Actual result:**  
The query returned empty results because it targeted the wrong Firestore collection path.

**Cause:**  
The collection reference in the EventChat repository was constructed incorrectly.

**Fix implemented:**  
The Firestore collection path in the EventChat query was corrected to point to the right subcollection.

**Verification:**  
Event chat messages load correctly from the DMs page after the fix.

---

## BUG-10 — "Seen" status not updating in event DMs

**Category:** Feature / DMs  
**Status:** Fixed  
**Priority:** Medium

**Description:**  
When a user read an event chat message via the DMs page, the "seen" indicator was not updated, so messages appeared perpetually unread in the conversation list.

**Steps to reproduce:**
1. Receive an event chat message.
2. Open the event chat from the DMs page.
3. Return to the DMs list and observe the unread indicator.

**Expected result:**  
The message should be marked as seen after the chat is opened.

**Actual result:**  
The unread indicator persisted even after the chat was viewed.

**Cause:**  
The seen state update call was not triggered when the event chat was opened from the DMs page.

**Fix implemented:**  
The seen update call was added to the event chat open flow in the DMs page.

**Verification:**  
Opening the event chat now correctly clears the unread indicator in the DMs list.

---

## BUG-11 — Excessive rebuild complexity in DMs page caused performance issues

**Category:** Performance / DMs  
**Status:** Fixed  
**Priority:** Medium

**Description:**  
The DMs page was rebuilding large portions of the widget tree too frequently, causing jank when the conversation list updated.

**Steps to reproduce:**
1. Open the DMs page with several active conversations.
2. Receive a new message or wait for a list update.
3. Observe frame drops or sluggish scrolling.

**Expected result:**  
The DMs list should update smoothly without visible frame drops.

**Actual result:**  
Unnecessary full-list rebuilds caused noticeable performance degradation.

**Cause:**  
State management in the DMs page was not scoped correctly, triggering wider rebuilds than needed.

**Fix implemented:**  
`direct_messages_page.dart` was refactored to reduce rebuild scope and avoid redundant computations on each update.

**Verification:**  
The DMs page scrolls and updates smoothly after the refactor.

---

## BUG-12 — Excessive complexity in home events list

**Category:** Performance / Event Feed  
**Status:** Fixed  
**Priority:** Medium

**Description:**  
The home events list performed redundant work on each rebuild, leading to slow list updates when the event dataset was larger.

**Steps to reproduce:**
1. Open the home feed with a sizeable list of events.
2. Scroll or trigger a state update (e.g., join an event).
3. Observe sluggish rendering or delayed list refresh.

**Expected result:**  
The feed should render efficiently regardless of the number of events.

**Actual result:**  
Redundant operations on each rebuild degraded performance with a larger event dataset.

**Cause:**  
The `EventViewModel` and `events_page.dart` were not caching intermediate results effectively between rebuilds.

**Fix implemented:**  
The home events query and list rendering were optimised in `event_viewModel.dart` and `events_page.dart`.

**Verification:**  
The home feed renders smoothly with an extended event list after the fix.

---

## BUG-13 — Event creation only uploaded the first selected image

**Category:** Feature / Event Creation
**Status:** Fixed
**Priority:** Medium

**Description:**
When creating an event and selecting multiple images, only the first image was uploaded and stored. Subsequent selections were silently discarded.

**Steps to reproduce:**
1. Open the create event page.
2. Select multiple images for the event.
3. Submit the form.
4. Open the created event and observe the images.

**Expected result:**
All selected images should be uploaded and displayed.

**Actual result:**
Only the first image was stored; all other selections were ignored.

**Cause:**
The image upload logic iterated incorrectly, stopping after the first successful upload.

**Fix implemented:**
The upload flow in the event creation page was corrected to upload all selected images.

**Verification:**
Tested by selecting multiple images when creating an event and confirming all images appear on the event details screen.

---

## BUG-14 — Completed events appearing in the main feed without explicit filter

**Category:** Feature / Event Feed
**Status:** Fixed
**Priority:** Medium

**Description:**
Events with status "done" (past events) appeared in the main event feed alongside active events, even when no filter was applied.

**Steps to reproduce:**
1. Open the home feed.
2. Do not apply any filter.
3. Observe that past events (status "done") appear mixed with upcoming and ongoing events.

**Expected result:**
The default feed should show only planning and occurring events. Done events should only appear when the "show completed events" filter is explicitly enabled.

**Actual result:**
Completed events were returned by the default query and displayed without filtering.

**Cause:**
The default event query did not exclude events with status "done".

**Fix implemented:**
The feed query was updated to exclude done events by default, showing them only when the completed filter is active.

**Verification:**
The home feed was tested without filters and confirmed to show only planning and occurring events.

---

## BUG-15 — Edited event details not immediately reflected in the feed

**Category:** Feature / Edit Event
**Status:** Fixed
**Priority:** Medium

**Description:**
After editing an event, the changes were saved to Firestore but the event card in the feed continued to show the old details until the user manually refreshed the page.

**Steps to reproduce:**
1. Open an event created by the current user.
2. Edit the event title or other details and save.
3. Return to the feed and observe the event card.

**Expected result:**
The updated event details should be immediately visible in the feed.

**Actual result:**
The feed continued to show the pre-edit values until a manual reload.

**Cause:**
The event list state was not invalidated after a successful edit, so the cached version remained displayed.

**Fix implemented:**
The edit event flow was updated to trigger a feed refresh after successfully saving changes.

**Verification:**
Editing an event and returning to the feed now immediately reflects the updated details.

---

## BUG-16 — Participant limit could be set below current occupancy

**Category:** Feature / Event Management
**Status:** Fixed
**Priority:** High

**Description:**
When editing an event, the owner could reduce the participant limit to a value lower than the number of users who had already joined, creating an inconsistent state.

**Steps to reproduce:**
1. Create an event and have multiple users join it.
2. Edit the event and reduce the participant limit below the current number of participants.
3. Save the changes.

**Expected result:**
The system should reject a participant limit lower than the current number of joined participants and show an error.

**Actual result:**
The change was accepted and saved, resulting in an event where the reported occupancy exceeded the limit.

**Cause:**
No validation was performed on the new participant limit value during the edit flow.

**Fix implemented:**
A validation check was added to prevent the limit from being set below the current participant count.

**Verification:**
Attempting to reduce the limit below current occupancy now shows a validation error and blocks saving.

---

## BUG-17 — Search users returning incomplete results

**Category:** Feature / User Search
**Status:** Fixed
**Priority:** Medium

**Description:**
The user search on the discover page returned fewer results than expected for certain queries, missing users whose names matched the search term.

**Steps to reproduce:**
1. Open the discover page.
2. Search for a user by name.
3. Observe that some matching users are not returned.

**Expected result:**
All users whose names contain the search term should be returned.

**Actual result:**
Some matching users were missing from the results.

**Cause:**
The query construction had an error that caused some results to be filtered out incorrectly.

**Fix implemented:**
The user search query was corrected to return all users matching the search term.

**Verification:**
Searching for known users by name now consistently returns the expected results.

---

## Summary

The defects above were identified during development and testing activities and were resolved before integration into the main branch. Their correction improved the reliability of the test suite, the consistency of event location handling, the review management experience, the overall code quality of the project, the stability of the local development workflow, the runtime performance of the event feed and direct messages page, and the correctness of event creation, feed filtering, edit event flow, participant limit validation, and user search.
