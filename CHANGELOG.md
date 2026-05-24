
## v0 - Sprint 0

### Added
- Initial project setup using Flutter
- Definition of product vision and main features
- Creation of GitHub repository and project board
- Initial user stories and backlog organization
- First UI mockups (feed, event creation, filtering)
- Initial system architecture (UI, Business Logic, Data layers)

### Improved
- Project structure and organization
- Team workflow and task management process

---

## v1 - Sprint 1

### Added
- Event listing (feed)
- Event creation with detailed inputs (name, description, capacity, dates, objectives, location)
- Event filtering based on multiple criteria (objectives, participants, location)
- Event details visualization
- Join and leave event functionality
- Favourite events
- Event management features (delete event, set participant limits, define event dates and status)
- Basic user features (login and account-related actions)

### Improved
- UI consistency across screens
- Interaction flow between features
- Overall user experience

---

## v2 - Sprint 2

### Added
- Event locations with improved location selection
- Activity chat for event participants
- Definitions page
- Change password functionality
- Event feedback page
- Backend support for event reviews
- Create review functionality
- Delete review functionality
- Review sorting functionality
- User profile page
- Event permissions
- Completed event filtering
- View joined events functionality
- Reusable widgets for improved UI structure

### Improved
- Application workflow and navigation
- Event-related user interactions
- Review and feedback experience
- Application language standardized to English
- Overall UI consistency and maintainability

### Fixed
- Fixed inconsistencies in event location handling
- Fixed permission-related issues in event actions
- Fixed review management behavior by allowing users to delete their own reviews
- Fixed language inconsistencies by standardizing the application interface to English

---

## v3 - Sprint 3

### Added
- Follow / unfollow users
- Public profile page with user events and follow state
- Followers / following list page
- 1-to-1 direct messages with real-time updates
- Event chat accessible from the direct messages page
- Notification system: event join/leave, new event to creator's followers, DM notifications, 48-hour event reminder
- Notification dropdown UI
- Event participants page (list of joined users)
- Edit event details (available to event owner)
- Discover page with user search
- Reviews history page
- Splash screen and loading states
- Image support for event cover images and profile pictures
- New bottom navigation bar (4 tabs + centred floating action button)
- New routes: `/participants`, `/edit-event`

### Improved
- Create event page: wheel time picker, new top bar, circle create button, hover effects on objectives, improved date icons and photo icon
- Event filter dialog: redesigned with checkboxes, date range filter, updated colour scheme
- Home / event feed: redesigned event card and top bar
- Auth pages (login and register): full UI redesign
- Direct messages page: redesigned conversation list and chat UI
- Top bar: consistency pass across all pages
- Test structure: reorganised into domain subdirectories under `unit_tests/` and `acceptance_tests/`
- Test coverage: 233 tests — all passing

### Fixed
- Event search lag: added 300ms debounce to `EventViewModel.updateSearchQuery`
- Users could send messages in event chats they had not joined
- Firebase query for EventChat returned empty results due to incorrect Firestore collection path
- "Seen" status not updating when opening event chat from DMs page
- Excessive rebuild complexity in DMs page causing jank
- Redundant work in home events list degrading performance with large datasets
