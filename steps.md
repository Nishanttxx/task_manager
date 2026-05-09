Project initialization and Core Auth.
Referencing the developmental flow blueprint provided (image_3.png):
Start with PHASE 1: FOUNDATIONAL CONFIGURATION. Initialize a new Flutter project named `task_manager_app` with the standard folder structure: `lib/models/`, `lib/screens/`, `lib/services/`, `lib/widgets/`.
Implement STEP 2: AUTHENTICATION SERVICE (Anonymous Sign-in).
Create the file `lib/services/auth_service.dart`. Implement the `signInAnonymously()` method, which uses `FirebaseAuth.instance.signInAnonymously()`. This must execute on app launch in `main.dart` and must be complete and robust. The comments must specify that this establishes the unique user `uid` and provides "Secure Access" *before* any other data services are utilized.
I will execute the necessary `flutterfire configure` command (STEP 1) on my terminal once you confirm the code structure is ready.

Defining Data Model and CRUD Backbone.
referencing image_3.png, we are now executing STEP 3 and STEP 4: CORE SERVICES (DATA LAYER).
Using the ground rules established, create:
1.  **`lib/models/task_model.dart`** (STEP 3): Define the exact structure of a task with fields: `id` (String), `title` (String), `description` (String), `date` (DateTime), `completed` (bool). You must implement the essential factory constructors for conversions: `fromMap(String id, Map<String, dynamic> map)` and `toMap()`, matching the visual dependency shown in the image. Full null safety is required.
2.  **`lib/services/firestore_service.dart`** (STEP 4): This is the backbone of the application's logic. It must enforce the user-specific path specified in the blueprint: `users/{uid}/tasks/...`. Inject the authenticated user’s `uid` (from STEP 2). Implement the four CRUD operations: **ADD, READ (STREAM), UPDATE, DELETE**, exactly as labeled. The READ operation must return a `Stream<List<TaskModel>>` for real-time updates.
Explain in comments that the security rule `if request.auth.uid == userId` must be applied in the Firebase console to enforce the user isolation defined in the architecture.

Integrating Modular Services.
Referencing image_3.png, implement PHASE 3: MODULAR INTEGRATION (Optional but Separate).
Build the **`lib/services/quote_service.dart`** (STEP 5). Use the `http` package to create an independent `fetchRandomQuote()` method, fetching data from the endpoint: `https://api.quotable.io/random`. This service must parse the response into a `QuoteModel` and handle basic network errors and loading states gracefully. It should not depend on Firebase, just as the diagram shows.

Building the HomeScreen (Primary Operational Screen).
referencing image_3.png, we are now executing PHASE 4, specifically STEP 6 and STEP 7.
1.  **State Management (STEP 6)**: Update `main.dart` to use a `StreamProvider<User?>` which listens to `FirebaseAuth.instance.authStateChanges()`. This injects the authentication state (derived in STEP 2) throughout the widget tree, as depicted in the navigation shell schematic. Also, add the provided `widgets/` as necessary.
2.  **HomeScreen Implementation (STEP 7)**: Build `lib/screens/home_screen.dart` with the UI structure shown in image_5.png (AppName Title, placeholder Quote section, and a simple list of tasks). This screen must visually connect the services:
    *   Fetch and display the motivational quote (calls STEP 5 Service).
    *   Stream and display the user's task list (calls STEP 4 CRUD Stream).
    *   Integrate the logic shown on the list tile in image_5.png: Checkboxes to complete tasks and a prominent Delete Icon to remove tasks (calling the relevant methods from STEP 4 Service).
Create the reusable `lib/widgets/task_tile.dart` used here, ensuring the edit logic (tapping the tile) is included.

Final Feature: Add/Edit Screen.
referencing image_3.png, execute STEP 8: FINAL FEATURE COMPLETION.
Build `lib/screens/add_task_screen.dart`. This screen must perfectly match the visual mockup shown in both image_3.png and image_5.png. It must contain:
    *   A form with validated inputs for **Title** and **Description** (specify maxLines 3).
    *   A **Date Picker** with a calendar icon.
    *   A large **Save Task Button**.
Implement the navigation logic:
    *   HomeScreen moves to this screen via the FloatingActionButton (+) shown in image_5.png.
    *   Saving the form must call the relevant `addTask()` or `updateTask()` methods from `FirestoreService` (STEP 4) and then successfully navigate the user back to the HomeScreen. Ensure the form pre-fills data if in "Edit Mode".

