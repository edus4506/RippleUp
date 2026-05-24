<!-- Template file for README.md for LEIC-ES-2025-26 -->

> [!NOTE] In this file, you will find the structure you should follow to document your mobile app in the README.md file for LEIC-ES-2025-26. It is a single file with guidelines. You can add more sections, but for assessment reasons and automation, please make sure to include all sections of this template. Your professors will clarify about specificities of your app.

# _Ripple Up_ Development Report

[![Flutter CI](https://github.com/LEIC-ES-2025-26-2LEIC05/T5/actions/workflows/flutter.yml/badge.svg?branch=main)](https://github.com/LEIC-ES-2025-26-2LEIC05/T5/actions/workflows/flutter.yml)

> [!NOTE] The CI badge above may show a failing or inactive state. During the final stages of Sprint 3, the team exhausted the free GitHub Actions minutes available on the organisation account, which prevented the workflow from running on recent commits. All quality checks (formatting, static analysis, tests, and web build) were validated locally and passed before merging. See the [DevOps section of Sprint 3](#devops-and-deployment-1) for more details.

Welcome to the documentation of _Ripple Up_!

This Software Development Report, tailored for LEIC-ES-2025-26, provides comprehensive details about _Ripple Up_, starting from an high-level vision and going into low-level implementation decisions. 

It is organised by the following activities: 

* [Business modeling](#Business-Modelling) 
  * [Product Vision](#Product-Vision)
  * [Features and Assumptions](#Features-and-Assumptions)

* [Requirements](#Requirements)
  * [User stories](#User-stories)
  * [Domain model](#Domain-model)
  * [User interfaces](#User-interfaces)
  * [Validation of requirements through interviews](#Validation-of-requirements-through-interviews)

* [Architecture and Design](#Architecture-And-Design)
  * [Logical architecture](#Logical-Architecture)
  * [Physical architecture](#Physical-Architecture)
  * [Functional prototype](#Functional-Prototype)

* [Development Environment](#Development-Environment)
* [Tools Used](#Tools-Used)
* [Use of AI Tools](#Use-of-AI-Tools)

* [Project management](#Project-Management)
  * [Definition of Ready (DoR)](#Definition-of-Ready-DoR)
  * [Product Backlog Refinement](#Product-Backlog-Refinement)
  * [Enabling Specification](#Enabling-Specification)
  * [INVEST Criteria](#INVEST-Criteria)
  * [Definition of Done (DoD)](#Definition-of-Done-DoD)
  * [Sprint 0](#Sprint-0)
  * [Sprint 1](#Sprint-1)
  * [Sprint 2](#Sprint-2)
  * [Sprint 3](#Sprint-3)
  * [Final Release](#Final-Release)

Contributions are expected to be made exclusively by the initial team, but we may open them to the community, after the course, in all areas and topics: requirements, technologies, development, experimentation, testing, etc.

Please contact us!

Thank you!

* Artur Moreira - arturmoreira899@gmail.com
* Eduardo Santos - edu.santos4506@gmail.com
* David Gomes - david2006gomes@gmail.com
* Tiago Ribeiro - tiagoc8ribeiro@gmail.com
* Lourenço Paçô - lourencopaco06@gmail.com

---
## Business Modelling

Business modeling in software development involves defining the product's vision, understanding market needs, aligning features with user expectations, and setting the groundwork for strategic planning and execution.

### Product Vision

For people who want to make a positive impact in their communities, our platform is a collaborative event system that allows users to create, discover, and join humanitarian and community-help events.
<!-- 
Start by defining a clear and concise product vision for your app, to help members of the team, contributors, and users into focusing their often disparate views into a concise, visual, and short textual form. 

The vision should provide a "high concept" of the product for marketers, developers, and managers.

A product vision describes the essential of the product and sets the direction to where a product is headed, and what the product will deliver in the future. 

**We favor a catchy and concise statement, ideally one sentence.**

We suggest you use the product vision template described in the following link:
* [How To Create A Convincing Product Vision To Guide Your Team, by uxstudioteam.com](https://uxstudioteam.com/ux-blog/product-vision/)

To learn more about how to write a good product vision, please read:
* [Vision, by scrumbook.org](http://scrumbook.org/value-stream/vision.html)
* [Product Management: Product Vision, by ProductPlan](https://www.productplan.com/glossary/product-vision/)
* [20 Inspiring Vision Statement Examples (2019 Updated), by lifehack.org](https://www.lifehack.org/articles/work/20-sample-vision-statement-for-the-new-startup.html)
-->


### Features and Assumptions
 - User Profile – Users can view and edit their personal profile, including name and profile picture.
 - Event Creation – Users can create events by providing details such as title, description, start/end dates, capacity, location (country, district, city), and environmental objectives (UN SDGs).
 - Event Discovery – Users can browse and search for events by keyword, and filter by objectives, location, date range, and participant count.
 - Join / Leave Events – Users can register for events they are interested in and leave events if they change their plans.
 - Event Management – Event owners can edit or delete events they created and manage participant limits and event status.
 - Event Participants – Users can view the list of participants for any event.
 - Event Feedback – Users can leave a rating and comment review on events they attended, and sort or delete their reviews.
 - Event History – Users can view a record of past events they attended and their review history.
 - Event Notifications – Users receive in-app notifications for event participation changes, new events from followed users, direct messages, and 48-hour event reminders.
 - Event Chat – Participants of an event can communicate through a dedicated event chat, also accessible from the direct messages page.
 - Direct Messages – Users can exchange private 1-to-1 messages with other users.
 - Social Graph – Users can follow and unfollow other users, view their followers and following lists, and browse public profiles.
 - Discover – Users can search for other users and explore the platform through a dedicated discover page. The discover page also surfaces recommended events based on the activity of other users on the platform.
 - Event Categories – Events are classified by UN Sustainable Development Goals (SDGs 1–17) to improve search and discovery.
 - Image Support – Users can upload profile pictures and event cover images.
<!-- 
Indicate an  initial/tentative list of high-level features - high-level capabilities or desired services of the system that are necessary to deliver benefits to the users.
 - Feature XPTO - a few words to briefly describe the feature
 - Feature ABCD - ...
...

Optionally, indicate an initial/tentative list of assumptions that you are doing about the app and dependencies of the app to other systems.
-->

## Requirements

### User Stories

The system supports several user stories focused on enabling users to organize and participate in humanitarian events.

The main functionalities include:
- Creating and managing humanitarian events (create, edit, delete)
- Browsing, searching, and filtering events
- Joining and leaving events; viewing event participants
- Favouriting events and viewing joined events history
- Event chat for participant coordination
- Direct messages between users
- Social graph: follow/unfollow users, public profiles, followers/following lists
- Discover page and user search
- Event feedback and reviews
- In-app notification system

Each user story is documented and tracked in the GitHub Project board with the label "user story".
<!-- 
In this section you should describe all kinds of requirements for your module: functional and non-functional requirements.

For LEIC-ES-2025-26, the requirements will be gathered and documented as user stories. 

Please add in this section a concise summary of all the user stories (not each user story!).

**User stories as GitHub Project Items**
The user stories themselves should be created and described as items in your GitHub Project with the label "user story". 

A user story is a description of a desired functionality told from the perspective of the user or customer. A starting template for the description of a user story is *As a < user role >, I want < goal > so that < reason >.*

Name the item with either the full user story or a shorter name (recommended). In the “comments” field, add relevant notes, mockup images, and acceptance test scenarios, linking to the acceptance tests when available, and finally estimate value and effort.

**INVEST in good user stories**. 
You may add more details after, but the shorter and complete, the better. In order to decide if the user story is good, please follow the [INVEST guidelines](https://xp123.com/articles/invest-in-good-stories-and-smart-tasks/).

**User interface mockups**.
After the user story text, you should add a draft of the corresponding user interfaces, a simple mockup or draft, if applicable.

**Acceptance tests**.
For each user story you should write also the acceptance tests (textually in [Gherkin](https://cucumber.io/docs/gherkin/reference/)), i.e., a description of scenarios (situations) that will help to confirm that the system satisfies the requirements addressed by the user story.

**Value and effort**.
At the end, it is good to add a rough indication of the value of the user story to the customers (e.g. [MoSCoW](https://en.wikipedia.org/wiki/MoSCoW_method) method) and the team should add an estimation of the effort to implement it using points in a kind-of-a Fibonnacci scale (1,2,3,5,8,13,20,40, no idea).

-->

### Domain model

![UML Diagram](assets/Readme/uml.png)

The domain model of _RippleUP_ represents the core entities and relationships required to support the platform’s main functionality.

- **User** represents a platform user identified by a unique UID. Stores name, email, and profile picture URL. Users create events, participate in activities, exchange messages, follow other users, and receive notifications.
- **Event** represents an activity on the platform. Contains title, description, start and end dates, maximum participants, current participant count, status (`planning` / `occurring` / `done`), location (country, district, city), a list of environmental objectives (indices 1–17 mapping to the UN SDGs), and optional image URLs. Status is derived at runtime from the dates — it is not stored.
- **Participation** models the association between a user and an event, represented as a composite document ID `{eventId}_{userId}` in Firestore. Joining and leaving an event atomically updates the event’s participant count.
- **Review** models feedback left by a participant on a completed event. Stores rating, comment, and creation timestamp. Stored as a subcollection of each event document.
- **Message (Event Chat)** models communication between participants in the context of an event. Each message stores sender ID, text content, and timestamp, and is scoped to a specific event.
- **DirectChat / DirectMessage** models 1-to-1 private conversations between two users. A chat document (ID: `{userId1}_{userId2}`) tracks the last message and seen state. Messages are stored in a subcollection.
- **Follow** models the social graph. A follow document (ID: `{followerId}_{followedId}`) records a directional follow relationship between two users.
- **Notification** models in-app alerts. Types include `new_event` (a followed user created an event), `upcoming_event` (48-hour reminder), `new_follower` (someone followed the user), and `new_message` (new DM). Each notification is associated with one user.

Overall, the domain model supports the full application: discovering and participating in events, coordinating through chat, building a social graph, leaving feedback, and receiving relevant alerts.

### User interfaces

The main user interfaces of _Ripple Up_ were designed to support the core user flows of the application, namely browsing events, creating new events, filtering activities, and viewing event details.

The following mockups illustrate the main screens currently considered for the application:

<p align="center">
  <img src="assets/Mockups/feed.png" alt="Feed Mockup" width="250"/>
  <img src="assets/Mockups/event_creator.png" alt="Event Creator Mockup" width="250"/>
  <img src="assets/Mockups/filter_event.png" alt="Filter Mockup" width="250"/>
</p>


### Validation of requirements through interviews

To validate the requirements, we conducted two semi-structured interviews with potential target users of the application. The goal was to understand what users value in this type of platform, which information they need before joining an activity, and which features they consider most useful.

The interviews showed that users are more interested in activities with a clear purpose and visible impact. They also highlighted the importance of having complete information before participating, especially the activity description, location, schedule, and number of participants.

Another important conclusion was the usefulness of filtering features, particularly by interest and location, to help users find relevant activities more easily. The idea of a participant-only chat was also seen as useful for coordination after joining an event.

Based on this feedback, the Product Backlog was refined by reinforcing the priority of event filtering, detailed event information, and participant coordination features. Although only two interviews were conducted, they provided a useful initial validation of the main requirements.

<!-- 
To better understand the context of the software system, it is useful to have a simple UML class diagram with all and only the key concepts (names, attributes) and relationships involved of the problem domain addressed by your app. 
Also provide a short textual description of each concept (domain class). 

Example:
 <p align="center" justify="center">
  <img src="https://github.com/FEUP-LEIC-ES-2022-23/templates/blob/main/images/DomainModel.png"/>
</p>
-->


## Architecture and Design

The architecture of Ripple Up was designed to ensure scalability, maintainability, and clear separation of concerns. The system follows a layered approach, allowing independent development and testing of different components.

The application runs on mobile devices, allowing users to explore and participate in events. It is built with Flutter and designed to support integration with external cloud services for data persistence and additional functionalities.

The design and implementation were continuously reviewed and refined throughout the project to ensure consistency and ongoing improvement of the system.

<!--
The architecture of a software system encompasses the set of key decisions about its organization. 

A well written architecture document is brief and reduces the amount of time it takes new programmers to a project to understand the code to feel able to make modifications and enhancements.

To document the architecture requires describing the decomposition of the system in their parts (high-level components) and the key behaviors and collaborations between them. 

In this section you should start by briefly describing the components of the project and their interrelations. You should describe how you solved typical problems you may have encountered, pointing to well-known architectural and design patterns, if applicable.
-->


### Logical architecture
The system follows a layered logical architecture composed of three main components: the User Interface, Business Logic, and Data Access layers.

- The **User Interface (UI)** layer is responsible for handling user interactions and presenting visual elements. It captures user input and displays processed data in a user-friendly format. Implemented as Flutter widgets and pages following the MVVM pattern, with view models exposing state via `ChangeNotifier`.
- The **Business Logic** layer manages the core functionalities of the application. It processes user inputs, applies application rules, and coordinates operations between the UI and the data layer. Implemented as view models (`lib/viewModels/`) and service classes (`lib/services/`).
- The **Data Access** layer is responsible for communication with external services. This includes Firebase Auth for authentication, Cloud Firestore for all structured data (events, users, participations, messages, reviews, follows, notifications), and Supabase Storage for file storage (profile images and event images).

!["Logical Architecture"](assets/Readme/logical_architeture.png)
<!--
The purpose of this subsection is to document the high-level logical structure of the code (Logical View), using a UML diagram with logical packages, without the worry of allocating to components, processes or machines.

It can be beneficial to present the system in a horizontal decomposition, defining layers and implementation concepts, such as the user interface, business logic and concepts.

Example of _UML package diagram_ showing a _logical view_ of the Eletronic Ticketing System (to be accompanied by a short description of each package):

![LogicalView](https://user-images.githubusercontent.com/9655877/160585416-b1278ad7-18d7-463c-b8c6-afa4f7ac7639.png)
-->


### Physical architecture

The physical architecture of _RippleUP_ is based on a Flutter mobile client that communicates with two cloud backends: Firebase and Supabase.

!["Physical Architecture"](assets/Readme/physical_architeture.png)

The main physical nodes of the current application are:

- **User Device** – executes the Flutter application (Android, iOS, or web). Contains the UI, view models, and service/repository classes. No data is stored locally beyond Flutter’s runtime state; all persistence is delegated to cloud services.
- **Firebase** – provides two services:
  - **Firebase Auth** – handles user authentication (sign-up, login, password change, account deletion).
  - **Cloud Firestore** – the primary database. Stores all structured data: events, users, participations, reviews, direct chats, messages, follows, and notifications.
- **Supabase** – used exclusively for file storage. Two buckets: `profile-images` (user profile pictures) and `event-images` (event cover images). No Supabase Auth or Supabase Database is used.

The Flutter app communicates with Firebase directly via the FlutterFire SDK and with Supabase via the Supabase Flutter client. All reads and writes go through repository classes in `lib/data/repositories/`, keeping the data layer decoupled from the rest of the application.

<!--
The goal of this subsection is to document the high-level physical structure of the software system (machines, connections, software components installed, and their dependencies) using UML deployment diagrams (Deployment View) or component diagrams (Implementation View), separate or integrated, showing the physical structure of the system.

It should describe also the technologies considered and justify the selections made. Examples of technologies relevant for ESOF are, for example, frameworks for mobile applications (such as Flutter).

Example of _UML deployment diagram_ showing a _deployment view_ of the Eletronic Ticketing System (please notice that, instead of software components, one should represent their physical/executable manifestations for deployment, called artifacts in UML; the diagram should be accompanied by a short description of each node and artifact):

![DeploymentView](https://user-images.githubusercontent.com/9655877/160592491-20e85af9-0758-4e1e-a704-0db1be3ee65d.png)
-->


### Functional prototype

The application is a fully functional product backed by Firebase and Supabase, covering all planned Must-have features across three sprints.

The screenshots below are from the Sprint 1 release and illustrate the initial working prototype used to validate the core architecture and user flows.

<p align="center">
  <img src="assets/Functional_Prototype/feed_screen.png" alt="Feed Screen" width="250"/>
  <img src="assets/Functional_Prototype/create_event_screen.png" alt="Create Event Screen" width="250"/>
  <img src="assets/Functional_Prototype/filter_screen.png" alt="Filter Screen" width="250"/>
  <img src="assets/Functional_Prototype/event_details_screen.png" alt="Event Details Screen" width="250"/>
</p>

The Sprint 1 prototype validated the main event flow: listing events with status badges, creating events with objectives and location, filtering by multiple criteria, and viewing event details. Since then the application has evolved significantly — the full feature set is described in the sprint sections below.

<!--
To help on validating all the architectural, design and technological decisions made, we usually implement a functional prototype, a thin vertical slice of the system integrating as much technologies as we can.

In this subsection please describe which feature, or part of it, you have implemented, and how, together with a snapshot of the user interface, if applicable.

At this phase, instead of a complete user story, you can simply implement a small part of a feature that demonstrates thay you can use the technology, for example, show a screen with the app credits (name and authors).
-->

## Development Environment

### How to run the app

There are three ways to run _Ripple Up_:

#### 1. Web (local network)

You can run the app as a web server on your machine and access it from any device on the same Wi-Fi network (e.g., a phone):

```bash
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
```

Then on the other device open a browser and navigate to:

```
http://<your-machine-ip>:8080
```

To find your machine's local IP address:
- **Linux/macOS:** `ip a` or `ifconfig` — look for the `inet` address on your Wi-Fi interface (e.g., `192.168.1.x`)
- **Windows:** `ipconfig` — look for the IPv4 address under your Wi-Fi adapter

#### 2. Android APK

A pre-built APK is available as an asset attached to each GitHub Release:

1. Go to the [Releases page](https://github.com/LEIC-ES-2025-26-2LEIC05/T5/releases)
2. Download the `.apk` file from the latest release
3. On your Android device, enable "Install from unknown sources" in Settings → Security
4. Open the downloaded `.apk` to install and launch the app

#### 3. Run locally from source

**Prerequisites:**
- Flutter SDK (stable channel) — [install guide](https://docs.flutter.dev/get-started/install)
- Dart SDK (included with Flutter)
- Android Studio or Visual Studio Code with the Flutter extension
- A connected Android device, running emulator, or a Chromium-based browser for web
- `google-services.json` placed at `android/app/` (required for Firebase — contact the team to obtain it)
- Supabase credentials configured (required for image storage — contact the team)

**Setup and run:**

```bash
git clone https://github.com/LEIC-ES-2025-26-2LEIC05/T5.git
cd T5
flutter pub get
```

Run on Android (emulator or physical device):

```bash
flutter run
```

Run on web (Chrome):

```bash
flutter run -d chrome
```

### Quality checks

To run the same checks executed by CI locally:

```bash
dart format --set-exit-if-changed .
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
flutter build web --release
```

The same quality checks are also executed automatically through the GitHub Actions workflow on every push and pull request.

## Tools Used

The following tools and technologies were used during the development of _Ripple Up_:

- **Flutter** – framework used to develop the mobile application
- **Dart** – programming language used with Flutter
- **Provider** – state management solution used to connect UI components with application logic
- **Git and GitHub** – version control, collaboration, pull requests, issues, and project management
- **GitHub Projects** – Scrum board and backlog management
- **GitHub Actions** – continuous integration workflow for formatting, static analysis, tests, and web build validation
- **Firebase Authentication** – used for user authentication and account-related operations
- **Cloud Firestore** – used as the main database for application data such as events, users, participations, messages, favorites, and reviews
- **Supabase** – used for storage-related functionality through the application storage repository
- **AI tools** – support for debugging, documentation, test planning, and development workflow decisions

## Use of AI Tools

AI tools were used during the development of this project to assist with code structuring, debugging, and the creation of small tests during development, including support for unit testing.

All generated suggestions were carefully reviewed, adapted, and integrated into the project to ensure correctness and alignment with the application requirements.

AI was used as a support tool to improve productivity, while all design decisions and final implementations were validated by the development team.

## Project management

To manage the development of Ripple Up, the team followed an agile approach inspired by Scrum. Work was divided into multiple sprints, allowing continuous improvement of the application.

We used GitHub to organize tasks and track progress. Each task was associated with user stories.

#### Definition of Ready (DoR)

Before a user story is included in a sprint, it must satisfy the following criteria:

- Clearly described (who, what, why)
- Small enough to be completed within the sprint
- Has acceptance criteria defined
- Estimated using story points
- Dependencies identified (if any)

This ensures that backlog items are well-prepared and ready for development.

#### Product Backlog Refinement

The Product Backlog was continuously reviewed and refined throughout the project.

This process included:
- Adding and updating user stories based on project evolution
- Prioritizing items according to their value and importance
- Estimating effort using story points
- Clarifying requirements and splitting larger items into smaller tasks when needed

Refinement activities were supported by feedback gathered during requirement validation and ongoing development.

#### Enabling Specification

During development, additional technical tasks were identified and added to the backlog to support the implementation of user stories.

These tasks included improving data handling, refining UI components, and ensuring proper interaction between different layers of the application.

This helped ensure that the system remained functional and consistent as new features were developed.

#### INVEST Criteria

User stories were defined following the INVEST principles:

- Independent – user stories are self-contained and do not depend heavily on others  
- Negotiable – details can be refined during development  
- Valuable – each story delivers value to the end-user  
- Estimable – effort can be estimated using story points  
- Small – stories are small enough to be completed within a sprint  
- Testable – acceptance of each story can be verified  

This approach helped ensure that backlog items were clear, manageable, and valuable.

#### Definition of Done (DoD)

A task or user story is considered done when:

- The functionality is fully implemented
- The code is integrated into the main branch
- The feature is tested and working as expected
- The corresponding item is moved to "Done" in the Scrum board

This ensures consistency and quality across all delivered features.


<!--
Software project management is the art and science of planning and leading software projects, in which they are planned, implemented, monitored and controlled.

In the context of ESOF, we recommend each team to adopt a set of project management practices and tools capable of registering tasks, assigning tasks to team members, adding estimations to tasks, monitor tasks progress, and therefore being able to track their projects.

Common practices of managing agile software development with Scrum are: backlog management, release management, estimation, Sprint planning, Sprint development, acceptance tests, and Sprint retrospectives.

You can find below information and references related with the project management: 

* Backlog management: Product backlog and Sprint backlog in a [Github Projects board](https://github.com/orgs/FEUP-LEIC-ES-2023-24/projects/64);
* Release management: [v0](#), v1, v2, v3, ...;
* Sprint planning and retrospectives: 
  * plans: screenshots of Github Projects board at begin and end of each Sprint;
  * retrospectives: meeting notes in a document in the repository, addressing the following questions:
    * Did well: things we did well and should continue;
    * Do differently: things we should do differently and how;
    * Puzzles: things we don’t know yet if they are right or wrong;
    * list of a few improvements to implement next Sprint;

-->

### Sprint 0

The goal of Sprint 0 was to prepare the project foundation and align the team before starting development.

During this sprint, the team focused on:

- Defining the product vision and identifying the main features of the application
- Creating and organizing the GitHub repository and project board
- Setting up the development environment using Flutter
- Designing the initial architecture (layered structure: UI, Business Logic, Data)
- Creating initial user stories and prioritizing them 
- Designing the first UI mockups for the main screens (feed, event creation, filters)
- Establishing team workflow, including task assignment and version control strategy

This sprint ensured that the team had a clear direction and a structured plan for development.

### Sprint 1

#### Sprint Planning

The goal of Sprint 1 was to deliver a first functional increment of *Ripple Up*, focusing on the core user flow of discovering and participating in environmental events.

The selected user stories for this sprint focused on the core functionalities of the application:

- Event browsing (feed and filtering)
- Event details visualization
- Event participation (join and leave events)
- Event creation and management (create, delete, set participant limits, define dates and status)
- Basic user features (login and account-related actions)

These items were selected to deliver a complete and functional user flow while ensuring the scope was feasible within the sprint effort.

At the beginning of the sprint, all selected items were placed in the "Sprint Backlog" column, with no tasks in progress or completed.

<p align="center">
  <img src="assets/scrumboard/sprint1_start_1.png" width="400"/>
  <img src="assets/scrumboard/sprint1_start_2.png" width="400"/>
</p>

---

#### Sprint Development

During the sprint, development followed an incremental approach where tasks were self-assigned and moved across the board:

- From **Sprint Backlog** → **In Progress**
- From **In Progress** → **Done**

The implementation focused on delivering a vertical slice of the application, integrating UI, business logic, and data layers.

Main functionalities implemented:
- Event listing (feed)
- Event creation with detailed inputs (name, description, capacity, dates, objectives, location)
- Event filtering based on multiple criteria (objectives, participants, location)
- Event details visualization
- Event participation (join and leave events)
- Event management features (delete event, set participant limits, define event dates and status)
- Basic user features (login and account-related actions)

---

#### Testing

Basic testing was performed to validate core functionalities such as event creation, browsing, and participation. User acceptance was verified through manual testing based on defined scenarios.

---

#### Sprint Review

At the end of Sprint 1, a functional product increment was achieved.
Feedback was collected during the sprint review from team members and peers. The feedback highlighted the importance of improving data persistence and enhancing user experience, which will be addressed in future sprints.

The application now allows users to:
- Browse environmental events
- View detailed information about each event
- Create and manage events
- Filter events according to user preferences
- Join and leave events
- Favourite events
- Interact with event properties such as participant limits, dates, and status

This increment delivers value to end-users by enabling meaningful participation in environmental initiatives, directly supporting the product vision.

<p align="center">
  <img src="assets/scrumboard/sprint1_end_1.png" width="400"/>
  <img src="assets/scrumboard/sprint1_end_2.png" width="400"/>
</p>

---

#### Release

A release was created in GitHub for Sprint 1:

- **Version:** v1 - Sprint 1  
- Includes a functional version of the application  
- Can be executed on a mobile device or emulator

---

#### Sprint Retrospective

**Did well:**
- Clear and well-structured architecture with separation of concerns (UI, ViewModels, and data layer)
- Successful delivery of a functional prototype with a complete user flow
- Implementation of core features end-to-end (event creation, browsing, filtering, and participation)

**Do differently:**
- Improve task distribution and collaboration within the team
- Break down user stories into smaller and more manageable tasks
- Compare planned vs completed work to better estimate future sprints
- Plan the sprint scope more carefully to better match the available effort

**Puzzles:**
- How to design and integrate a proper data persistence solution (database/backend)
- How to effectively manage task distribution and coordination within the team during development

### Sprint 2

#### Sprint Planning

The goal of Sprint 2 was to extend the first functional increment of *Ripple Up* by improving user interaction, event participation, communication, feedback, profile management, and overall application quality.

The selected backlog items for this sprint focused on:

- Improving event location handling
- Adding communication between event participants
- Adding event feedback and review functionality
- Improving user profile and account management
- Adding permissions for event-related actions
- Improving completed event filtering and joined events visualization
- Improving UI consistency through reusable components
- Improving quality assurance and development workflow

At the beginning of the sprint, the selected Product Backlog Items were moved into the Sprint Backlog and assigned according to team availability.

<p align="center">
  <img src="assets/scrumboard/sprint2_start_1.png" width="400"/>
  <img src="assets/scrumboard/sprint2_start_2.png" width="400"/>
</p>

---

#### Sprint Development

During Sprint 2, the team continued following an incremental development process. Tasks were developed in separate branches and integrated through pull requests after implementation and validation.

Main functionalities implemented during this sprint:

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

These features improved the application by making event participation more complete, adding post-event feedback, improving account-related actions, and making the interface easier to maintain.

---

#### Testing and Quality Assurance

During Sprint 2, the team increased the automated test coverage of the application and improved the CI workflow used to validate the project.

The project currently contains 14 test files organized by responsibility:

- `test/services/` – tests for service logic, such as event filtering and review management
- `test/viewModels/` – tests for view model behavior, including events, messages, and reviews
- `test/views/dialogs/` – widget tests for dialogs such as event details and event filtering
- `test/views/pages/` – widget tests for pages such as home, settings, feedback, profile editing, and password change
- `test/views/widgets/` – widget tests for reusable UI components such as current events and review cards

Current test structure:

```txt
test
├── services
│   ├── event_filter_service_test.dart
│   └── review_service_test.dart
├── viewModels
│   ├── event_view_model_test.dart
│   ├── messageViewModel_test.dart
│   └── review_viewModel_test.dart
└── views
    ├── dialogs
    │   ├── event_details_dialog_test.dart
    │   └── event_filter_dialog_test.dart
    ├── pages
    │   ├── change_password_page_test.dart
    │   ├── edit_profile_page_test.dart
    │   ├── feedback_page_test.dart
    │   ├── home_page_test.dart
    │   └── settings_page_test.dart
    └── widgets
        ├── current_events_widget_test.dart
        └── review_card_test.dart
```

Automated tests can be executed with:

```bash
flutter test
```

Static analysis is used to detect possible code issues before merging changes:

```bash
flutter analyze --no-fatal-infos --no-fatal-warnings
```

Code formatting is checked using Dart's formatter:

```bash
dart format --set-exit-if-changed .
```

Although the project does not currently use a separate `integration_test/` directory, several widget tests validate interactions between UI components, view models, and mocked application logic.

---

#### Acceptance Tests

Acceptance tests were used to validate whether the implemented features satisfy the expected user interactions.

The detailed acceptance criteria for each Product Backlog Item were documented in the corresponding GitHub Project items. Some scenarios were validated manually, while others were supported by Flutter widget tests located under `test/views/`.

Examples of acceptance scenarios validated during Sprint 2:

```gherkin
Feature: Create event review

Scenario: User creates a review for a completed event
  Given the user participated in a completed event
  When the user opens the feedback page and submits a review
  Then the review should be created and displayed in the event feedback section
```

```gherkin
Feature: View joined events

Scenario: User views events they joined
  Given the user has joined one or more events
  When the user opens the joined events section
  Then the system should display the events joined by that user
```

```gherkin
Feature: Change password

Scenario: User changes their password
  Given the user is authenticated
  When the user enters the required password information and confirms the change
  Then the system should process the password change request
```

These acceptance tests helped confirm that the implemented features were aligned with the expected user behavior and delivered value to end-users.

---

#### Bugs, Defects, Fixes and Improvements

Bugs, defects, fixes, and improvements identified during development and testing are documented in a separate bug log to keep the README concise.

The full bug log can be found in [`BUGS.md`](BUGS.md).

During Sprint 2, three new defects were added to the bug log:

- **BUG-04** — City field was not reset after changing district
- **BUG-05** — Review list was not immediately updated after deleting a review
- **BUG-06** — Flutter web server failed when executed from the wrong directory

Each bug entry includes its description, category, priority, reproduction steps, expected and actual behavior, implemented fix, and verification status.

---

#### DevOps and Deployment

The project uses GitHub Actions for Continuous Integration.

The workflow runs automatically on every push and pull request. It is divided into four jobs:

- **Format** – installs dependencies and checks Dart formatting with `dart format --set-exit-if-changed .`
- **Analyze** – runs static analysis with `flutter analyze --no-fatal-infos --no-fatal-warnings`
- **Test** – runs the automated test suite with `flutter test`
- **Build Web** – validates that the application can be built for web release

The CI workflow helps ensure that new contributions are formatted correctly, do not introduce static analysis issues, pass the automated tests, and can still be built successfully.

The application can be built locally for web using:

```bash
flutter build web --release
```

During Sprint 2, the application was validated through automated CI checks and local Flutter execution.

---

#### Branching Strategy

During Sprint 2, the team followed a GitHub Flow-based workflow.

The `main` branch was used as the stable branch of the project. New features, fixes, and improvements were developed in separate branches created from `main`.

Feature branches used descriptive names related to the work being implemented, for example:

- `feat/expand-event-locations`
- `feat/join-event`
- `feat/delete-reviews`

After development, changes were submitted through pull requests. Before being merged, each pull request had to pass the available quality checks, including formatting, static analysis, automated tests, and web build validation.

After a pull request was merged, the corresponding branch was deleted locally and remotely to keep the repository organized.

This workflow helped the team isolate changes, review work before integration, and keep the main branch stable throughout the sprint.

---

#### Use of AI Tools During Sprint 2

During Sprint 2, AI tools were used as support for documentation, debugging, test planning, and development workflow decisions.

AI assistance was used for:

- Drafting GitHub issue and pull request descriptions
- Suggesting commit messages
- Explaining Flutter, Git, and CI-related errors
- Supporting README and changelog documentation
- Helping identify possible bugs and improvements
- Supporting the creation of test and acceptance test descriptions

Example prompts used during the sprint:

| Prompt | Purpose |
|---|---|
| "Generate a commit message for the event location filtering feature" | Commit message support |
| "Explain why the Flutter web server fails when running from the build/web directory" | Debugging support |
| "Suggest a README section for documenting CI, tests and quality metrics" | Documentation support |
| "Create bug descriptions for Sprint 2" | Bug documentation support |
| "Explain Flutter format CI failure" | CI/debugging support |

All AI-generated suggestions were reviewed, adapted, and validated by the team before being included in the project.

When AI-assisted code was used, it was committed separately when applicable, and the corresponding Product Backlog Items were labeled with `MisterAI`.

---

#### Sprint Review

At the end of Sprint 2, a more complete and refined product increment was achieved, building on the core functionality developed in the previous sprint. The sprint focused on improving usability, interaction, and overall application consistency, while also addressing system organization and preparing the foundation for future enhancements such as real-time features and improved responsiveness.

The application now allows users to:

- Access and manage their personal profile
- Participate in event-specific chats with other users
- Leave feedback and reviews on events
- Sort and manage reviews dynamically
- View and filter completed events
- Access joined events in a dedicated view
- Interact with improved event permissions and controls
- Navigate the application more smoothly with a consistent and standardized UI
- Change their account password securely
- Access a definitions page for better understanding of the platform

This increment delivers additional value to end-users by improving interaction, personalization, and engagement within the platform.

<p align="center">
  <img src="assets/scrumboard/sprint2_end_1.png" width="400"/>
  <img src="assets/scrumboard/sprint2_end_2.png" width="400"/>
  <img src="assets/scrumboard/sprint2_end_3.png" width="400"/>

</p>

---

#### Release

The Sprint 2 release was published as a GitHub Release:

- **Version:** v2 — Sprint 2
- Includes all Sprint 2 features: event locations, activity chat, definitions page, change password, event feedback and reviews (create, delete, sort), user profile page, event permissions, completed-event filtering, and view joined events
- `CHANGELOG.md` updated with all changes introduced in this sprint
- Can be executed on a mobile device, emulator, or web browser using `flutter run`

---

#### Sprint Retrospective

**Did well:**
- Bigger user stories were divided into smaller ones to avoid overwork on some team members
- The major good principles for a good software development like separation of concerns, modularity, reusability, and clean architecture were followed, along with good communication between all team members
- Significant improvements in UI consistency and overall application workflow
- Reusable components/widgets were introduced, improving maintainability and scalability

**Do differently:**
- Allocate more time for testing and validation of features before completion
- Enhance coordination when working on interdependent features (e.g., frontend and backend integration)
- Define clearer acceptance criteria for user stories to avoid rework

**Puzzles:**
- How to implement real-time features to provide a smoother and more interactive user experience
 - How to efficiently manage synchronization between frontend and backend for dynamic data (like reviews and event updates)

### Sprint 3

#### Sprint Planning

The goal of Sprint 3 was to complete the _Ripple Up_ platform by adding social features, improving UI across all screens, and delivering a polished product increment ready for final evaluation.

The selected backlog items for this sprint focused on:

- Social features: follow/unfollow users, public profiles, followers/following lists
- Messaging: 1-to-1 direct messages, event chat accessible from DMs
- Notifications: event join/leave, new events to followers, DM notifications, 48-hour event reminders
- UI overhaul: feed/home, authentication screens, create event, filter dialog, DMs, event details
- New functionality: event participants page, edit event details, discover page, user search
- Quality: test structure reorganisation, additional unit and acceptance tests

At the beginning of the sprint, the selected Product Backlog Items were moved into the Sprint Backlog.

<p align="center">
  <img src="assets/scrumboard/sprint3_start_1.png" width="400"/>
  <img src="assets/scrumboard/sprint3_start_2.png" width="400"/>
  <img src="assets/scrumboard/sprint3_start_3.png" width="400"/>
  <img src="assets/scrumboard/sprint3_start_4.png" width="400"/>
</p>

---

#### Sprint Development

During Sprint 3, the team continued following an incremental development process with feature branches and pull requests. Development was organised around the following merged pull requests:

- **PR #119 / #121** — Direct messages (1-to-1 DMs, chat bubbles, conversation list)
- **PR #120** — Discover page and user search
- **PR #115** — Follow / unfollow users and public profiles
- **PR #117** — Notification system (event, follow, DM, 48h reminder)
- **PR #123** — Notification dropdown UI and notification chat event
- **PR #124** — New bottom navigation bar (4 tabs + floating action button)
- **PR #127** — Bug fixes: event chat Firebase query, message send permission
- **PR #128** — Event participants page
- **PR #129** — Test architecture refactored into domain subdirectories
- **PR #130** — UI/Home: event card and top bar redesign
- **PR #132** — Event filter dialog redesign (new look, checkboxes, date filter)
- **PR #133** — Edit event functionality for event owners
- **PR #134** — Bug fixes: event search delay, DMs complexity, home events complexity
- **PR #136** — Create event page UI overhaul (wheel time picker, new icons, hover effects)
- **PR #137** — Auth pages, direct messages, and event chat UI
- **PR #138** — Recommended events in the discover page (based on other users' participation activity)

Main functionalities implemented during this sprint:

- Social graph: follow/unfollow, public profile viewing, followers/following list
- 1-to-1 direct messages with real-time updates
- Event chat accessible from the DMs page
- Notification system with multiple types (event, follow, DM, reminder)
- Event participants page (list of joined users)
- Edit event details (available to event owner)
- Discover page with user search and recommended events (surfaced from other users' participation history)
- Reviews history page
- Splash screen and loading states
- Image support (event cover images and profile pictures via Supabase)
- New bottom navigation bar
- UI overhaul of all major screens

---

#### Testing and Quality Assurance

During Sprint 3, the team significantly expanded test coverage and reorganised the test structure into a domain-driven directory layout.

The test suite now contains **233 tests** — all passing.

Current test structure:

```txt
test/
├── unit_tests/
│   ├── services/
│   │   ├── filter/         # event_filter_service_test.dart
│   │   ├── messages/       # direct_chat_service_test.dart
│   │   ├── reviews/        # review_service_test.dart
│   │   ├── search/         # event_search_service_test.dart, user_search_service_test.dart
│   │   ├── social/         # notification_service_test.dart
│   │   └── sort/           # sort_review_service_test.dart
│   └── viewModels/
│       ├── events/         # event_viewModel_test.dart, favorite_event_viewModel_test.dart
│       ├── messages/       # messageViewModel_test.dart
│       ├── reviews/        # review_viewModel_test.dart
│       ├── search/         # search_users_viewModel_test.dart
│       └── social/         # followers_following_viewModel_test.dart,
│                           # notification_viewModel_test.dart,
│                           # public_profile_viewModel_test.dart
└── acceptance_tests/
    ├── dialogs/            # event_filter_dialog_test.dart,
    │                       # event_details_dialog_test.dart
    ├── pages/
    │   ├── authentication/ # login_page_test.dart
    │   ├── discover/       # discover_page_test.dart, search_users_page_test.dart
    │   ├── events/         # create_event_page_test.dart, feedback_page_test.dart,
    │   │                   # feedback_page_sort_test.dart
    │   ├── messages/       # direct_messages_page_test.dart
    │   ├── settings/       # settings_page_test.dart, edit_profile_page_test.dart,
    │   │                   # change_password_page_test.dart, edit_event_page_test.dart
    │   └── social/         # followers_following_page_test.dart
    └── widgets/
        ├── profile_tabs/   # current_events_widget_test.dart
        ├── bottom_nav_test.dart
        ├── event_card_test.dart
        ├── notification_dropdown_test.dart
        └── review_card_test.dart

integration_test/
├── followers_following_test.dart
└── create_and_join_event_test.dart
```

Tests can be executed with:

```bash
flutter test test/unit_tests/        # unit tests only
flutter test test/acceptance_tests/  # acceptance tests only
flutter test test/                   # all 233 tests
flutter test integration_test/       # requires connected device + Firebase credentials
```

Static analysis and formatting are verified as part of the CI pipeline on every push and pull request.

---

#### Acceptance Tests

Acceptance tests validate whether the Sprint 3 features satisfy the expected user interactions. Automated acceptance tests are located under `test/acceptance_tests/`. The scenarios below represent the key new features delivered in this sprint.

```gherkin
Feature: View event participants

Scenario: User views the list of participants of an event
  Given the user is viewing an event's details
  When the user taps the participants button
  Then the system should display a list of users who joined the event
```

```gherkin
Feature: Edit event

Scenario: Event owner edits event details
  Given the user is the creator of an event
  When the user opens the edit event page and modifies the event title
  Then the updated title should be reflected in the event feed
```

```gherkin
Feature: Send direct message

Scenario: User sends a direct message to another user
  Given the user is on the direct messages page
  When the user opens a conversation and sends a message
  Then the message should appear in the conversation immediately
```

```gherkin
Feature: Follow a user

Scenario: User follows another user from their public profile
  Given the user is viewing a public profile
  When the user taps the Follow button
  Then the Follow button should change to Unfollow
  And the followed user's follower count should increase
```

```gherkin
Feature: Receive notification

Scenario: User receives a notification when someone joins their event
  Given the user has created an event
  When another user joins that event
  Then the creator should receive a notification in their notification dropdown
```

These acceptance tests helped confirm that the implemented features delivered value in line with the expected user behaviour.

---

#### Bugs, Defects, Fixes and Improvements

Bugs, defects, fixes, and improvements identified during development and testing are documented in [`BUGS.md`](BUGS.md).

During Sprint 3, six new defects were identified and resolved:

- **BUG-07** — Event search lag caused by missing debounce in `EventViewModel`
- **BUG-08** — Users could send messages in event chats they had not joined
- **BUG-09** — Firebase query for EventChat returned wrong results due to an incorrect Firestore path
- **BUG-10** — "Seen" status was not updated when opening an event chat from the DMs page
- **BUG-11** — Excessive rebuild complexity in the DMs page caused jank
- **BUG-12** — Redundant work in the home events list degraded performance

All six defects were resolved before merging into `main`.

---

#### DevOps and Deployment

The project continues to use GitHub Actions for Continuous Integration.

The CI workflow runs automatically on every push and pull request and is divided into four jobs:

- **Format** – checks Dart formatting with `dart format --set-exit-if-changed .`
- **Analyze** – runs static analysis with `flutter analyze --no-fatal-infos --no-fatal-warnings`
- **Test** – runs the full test suite with `flutter test`
- **Build Web** – validates that the application builds successfully for web release with `flutter build web --release`

All four jobs must pass before a pull request can be merged into `main`.

During the final stages of Sprint 3, the team encountered a limitation with the free GitHub Actions minutes available on the organisation account. The monthly quota was exhausted, which caused the CI workflow to stop running on new commits and pull requests. As a result, some of the later PRs in the sprint were merged without automated CI validation.

To compensate, all quality checks were run locally before merging:

```bash
dart format --set-exit-if-changed .
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
flutter build web --release
```

All checks passed locally. The CI workflow remains correctly configured and will resume running normally once the Actions minutes quota is renewed.

The application can be run locally using:

```bash
flutter run             # default device
flutter run -d chrome   # web (browser)
flutter run -d android  # Android emulator or device
```

Prerequisites:
- Flutter SDK (stable channel)
- A `google-services.json` file placed at `android/app/` (required for Firebase; not included in the repository)
- The Supabase URL and anon key set as environment variables or in a local config file (required for image storage)

---

#### Branching Strategy

During Sprint 3, the team continued following a GitHub Flow-based workflow.

The `main` branch was kept stable throughout the sprint. All new features, bug fixes, and UI improvements were developed in separate branches and integrated through pull requests.

Branch naming conventions used during Sprint 3:

- `UI/<screen-name>` — UI overhaul branches (e.g., `UI/auth`, `UI/create_event`, `UI/Home`)
- `feat/<feature-name>` — new feature branches (e.g., `feat/notifications`, `feat/follows`)
- `bug/<description>` — bug fix branches (e.g., `bug/complexity`, `Bug/DM-Querys`)
- `<feature-name>` — standalone feature branches (e.g., `edit_event`, `participants`, `directMessages`)

Each pull request was reviewed by at least one other team member before being merged, in addition to passing all CI checks. After merging, branches were deleted to keep the repository organised.

---

#### Use of AI Tools During Sprint 3

During Sprint 3, AI tools were used selectively to support specific tasks — primarily documentation, debugging, and test planning. The team maintained ownership of all design decisions and implementation.

**AI-labelled Product Backlog Items (MisterAI):**

The following PBIs involved AI-assisted development. These items are labelled `MisterAI` in the GitHub Project board, and their AI-generated code contributions were committed in separate commits when applicable:

| # | Title | AI usage |
|---|---|---|
| #95 | User Profile Viewing | Structure and layout of `PublicProfilePage` |
| #96 | Follow / Unfollow Users | Follow/unfollow repository and ViewModel logic |
| #102 | RippleUp Logo | Logo design and asset integration |
| #105 | See Followers/Following in Profile | `FollowersFollowingPage` structure and ViewModel |
| #116 | General UI | UI consistency pass across multiple screens |
| #119 | Direct Messages | `DirectMessagesPage` layout and chat bubble structure |
| #11 | Discover Related Activities | `RecommendedEventRepository` and `RecommendedEventsSection` widget structure |

**Prompts used during Sprint 3:**

| Prompt | Purpose |
|---|---|
| "Explain why the Firestore query for subcollection messages returns empty results when the collection path includes a dynamic segment" | Debugging BUG-09 |
| "Write Gherkin acceptance scenarios for an event participants page feature" | Acceptance test documentation |
| "Suggest a layout for a direct messages conversation list in Flutter using ListView.builder and ListTile" | UI structure for #119 |
| "What is the correct way to structure a ChangeNotifierProvider with a constructor-injected repository in Flutter Provider?" | Architecture clarification |
| "Generate a commit message for a fix that adds a 300ms debounce to the event search query" | Commit message support |
| "Review this README section for Sprint 3 and suggest improvements for the DevOps paragraph" | Documentation review |

All AI-generated suggestions were reviewed and validated by the team before being integrated. No AI-generated code was merged without understanding and adapting it to the project's architecture and conventions.

---

#### Sprint Review

At the end of Sprint 3, a significantly more complete product increment was delivered. The application now covers the full set of planned Must-have features and a substantial portion of Should-have and Could-have items.

The application now allows users to:

- Discover and follow other users; view public profiles and followers/following lists
- Exchange direct messages with other users in real time
- Participate in event chats accessible from the DMs page
- Receive notifications for event activity, follows, DMs, and upcoming events
- View the full list of participants for any event
- Edit events they created
- Search for events by keyword in the feed
- Browse a discover page with user search and recommended events based on platform activity
- Upload and display profile pictures and event cover images
- Navigate the application through a redesigned bottom navigation bar
- Use consistently redesigned screens across all major flows

<p align="center">
  <img src="assets/scrumboard/sprint3_end_1.png" width="400"/>
  <img src="assets/scrumboard/sprint3_end_2.png" width="400"/>
  <img src="assets/scrumboard/sprint3_end_3.png" width="400"/>
  <img src="assets/scrumboard/sprint3_end_4.png" width="400"/>
</p>

---

#### Release

The Sprint 3 release was published as a GitHub Release:

- **Version:** v3 — Sprint 3
- Includes all Sprint 3 features: social graph, direct messages, event chat in DMs, notifications, participants page, edit event, discover page with recommended events, image support, UI overhaul across all screens
- `CHANGELOG.md` updated with all changes introduced in this sprint
- Can be executed locally with `flutter run`, on Android via the APK attached to the GitHub Release, or on web via `flutter run -d chrome`

---

#### Sprint Retrospective

**Did well:**
- Large scope managed effectively by splitting work across focused branches and PRs
- UI consistency improved significantly across all screens by the end of the sprint
- Test suite restructured into a maintainable domain-driven layout and coverage increased to 233 tests
- Social features (follows, DMs, notifications) integrated cleanly with the existing architecture

**Do differently:**
- Start UI overhaul tasks earlier in the sprint to allow more review time
- Coordinate more explicitly between teams working on overlapping areas (e.g., DMs page and event chat)
- Track WiP limits more strictly to avoid multiple large PRs open at the same time

**Puzzles:**
- How to handle real-time message delivery consistently across different network conditions
- How to balance Firestore read costs with real-time updates in features like notifications and DMs

### Final Release
