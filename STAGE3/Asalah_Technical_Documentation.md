# Asalah - Technical Documentation

## Stage 3: Portfolio Project - Technical Documentation

---

## 1. Introduction

**Asalah** is a gamified value-based financial literacy platform designed for Saudi families. The project helps parents teach children responsible financial habits through meaningful tasks, rewards, and a points-based system called **Noor Points**.

This technical documentation translates the project objectives and requirements into a detailed technical plan for the MVP. It includes user stories, mockup planning, system architecture, components, backend classes, database design, sequence diagrams, API specifications, source control management, quality assurance strategies, and technical justifications.

The goal of this document is to provide a clear blueprint for building the Asalah MVP and to align the team on the project’s technical direction.

---
## 2. MVP Scope

The MVP is designed to provide a core functional loop for parents and children to manage tasks, Noor Points, the Wishlist, and rewards. It consists of two primary interfaces:

### 2.1 Parent Interface Features
*   **Authentication:** Register and secure login.
*   **Child Management:** Create and manage child profiles.
*   **Task Management:** Create, assign, and track tasks.
*   **Point System:** Assign specific Noor Points to individual tasks.
*   **Task Review:** Review, approve, or reject completed tasks.
*   **Reward Management:** Create and manage weekly rewards available for the child.
*   **Progress Tracking:** View and monitor individual child progress.

### 2.2 Child Interface Features
*   **Dashboard:** View assigned tasks.
*   **Interaction:** Mark tasks as completed to trigger parent review.
*   **Balance:** View current Noor Points balance.
*   **Wishlist:** Manage the list of desired items/wishes the child is collecting points for.
*   **Rewards:** View available rewards set by the parents.
*   **Progress:** Track personal task completion and point accumulation.

### 2.3 Features Out of Scope (Future Versions)
To ensure the MVP is completed within the project timeline, the following features are reserved for future updates:
*   **AI:** AI-generated task suggestions.
*   **Communication:** Push notifications.
*   **Gamification:** Advanced badges and complex achievements.
*   **Social:** Family challenges.
*   **Analytics:** Advanced behavioral analytics.
*   **Personalization:** Avatar customization.
*   **Financial:** Real-money payment integration.
---

## 3. User Stories and Mockups

### 3.1 Purpose

The purpose of this section is to define the main MVP features from the user’s perspective. User stories help the team understand what each user needs to do in the application and why each feature matters.

Since Asalah includes a mobile user interface, mockups will be created for the main screens to visualize the user experience before implementation.

---
## 3.2 User Types

| User Type | Description |
| --------- | ----------- |
| **Parent** | The administrator of the account. Responsible for managing child profiles, defining tasks with assigned Noor Points, approving task completions, creating reward pools, and monitoring overall behavioral progress. |
| **Child** | The end-user who interacts with the task list, marks tasks as completed, tracks their accumulated Noor Points, maintains a personalized "Wishlist," and views available rewards to work toward. |
---

## 3.3 Prioritized User Stories

The user stories are prioritized using the MoSCoW method:

* **Must Have:** Required for the MVP.
* **Should Have:** Important but not critical for the first version.
* **Could Have:** Nice to include if time allows.
* **Won’t Have:** Not planned for the MVP.

---
## 1. Must Have User Stories

| Priority | User Story |
| :--- | :--- |
| **Must Have** | As a parent, I want to create a master account and add multiple child accounts (with email and password), so that each child has their own profile. |
| **Must Have** | As a parent, I want to receive a verification code on my device when my child logs in, so that I can approve their access and secure the application. |
| **Must Have** | As a child, I want to log in using the email and password my parents made for me and wait for their verification, so that I can access my screen safely. |
| **Must Have** | As a child, I want to see only my assigned tasks on my screen, so that I know exactly what I need to do. |
| **Must Have** | As a parent, I want to categorize tasks into Financial, Religious, and Daily lists, so that I can teach my child financial sense and the value of things. |
| **Must Have** | As a parent, I want to set the task frequency to daily, weekly, or just once a day, so that I can customize the routine for my child. |
| **Must Have** | As a child, I want to click "I completed the task" so that it goes to a "Pending" status, instead of giving me points right away. |
| **Must Have** | As a parent, I want to review the tasks my child marked as completed, so that I can click "Yes" and change its status to Completed. |
| **Must Have** | As a parent, I want an "Automatic Approval" option when creating a task, so that it skips the Pending status and gives points automatically. |
| **Must Have** | As a parent, I want to provide feedback using Emojis and a side comment box after confirming a task, so that I can motivate my child. |
| **Must Have** | As a child, I want to receive Noor Points instantly into my dashboard after parent approval, so that I can see my balance grow. |
| **Must Have** | As a child, I want to put exactly 5 wishes in my Wishlist, so that I can save my Noor Points to buy them. |
| **Must Have** | As a parent, I want to review my child's 5 wishes and approve between 1 and 3, so that I can control achievable goals. |
| **Must Have** | As a parent, I want to set a goal (e.g., 5,000 points) for the wishlist, so that I can teach my child commitment. |
| **Must Have** | As a child, I want to view available rewards every Thursday under 5 categories, regardless of parent approval status. |
| **Must Have** | As a parent, I want to choose from 5 system reward categories or write a custom reward, so that I can tailor the incentive. |
| **Must Have** | As a parent, I want to approve or deny the weekly reward based on my child's consistency, so that I can teach commitment. |
| **Must Have** | As a user, I want full support for the Arabic language, so that Saudi families can use the app comfortably. |
| **Must Have** | As a parent, I want to view each child’s progress history, so that I can understand their development. |
| **Must Have** | As a child, I want to see my total Noor Points balance, so that I can track my progress toward rewards. |
| **Must Have** | As a child, I want to view my previously completed tasks, so that I can feel proud of my achievements. |
| **Must Have** | As a parent, I want to edit or delete tasks, so that I can manage responsibilities when circumstances change. |
| **Must Have** | As a parent, I want to edit or delete rewards, so that I can manage incentives easily. |
| **Must Have** | As a child, I want to see a "Progress Star" for Noor Points, so that I can visually track my growth. |
| **Must Have** | As a user, I want to switch between Arabic and English languages, so that I have flexible usage options. |

---

## 2. Should Have User Stories

| Priority | User Story |
| :--- | :--- |
| **Should Have** | As a parent, I want to receive in-app notifications when a task is completed, so that I can review it promptly. |
| **Should Have** | As a parent, I want to view simple weekly performance statistics, so that I can identify the most consistent tasks. |
| **Should Have** | As a child, I want to see a progress bar for each wish, so that I know how many points I need to reach my goal. |
| **Should Have** | As a parent, I want an option to "Freeze Points," so that I can temporarily stop rewards if needed. |
| **Should Have** | As a user, I want a "Dark Mode" option, so that I can reduce eye strain during evening use. |
| **Should Have** | As a parent, I want to receive short weekly financial education tips, so that I can better guide my child. |

---

## 3. Could Have User Stories

| Priority | User Story |
| :--- | :--- |
| **Could Have** | As a parent, I want to export child performance reports (PDF), so that I can print or share them. |
| **Could Have** | As a parent, I want to create "Bonus Tasks" with double points, so that I can motivate my child for special efforts. |
| **Could Have** | As a child, I want to earn "Achievement Badges" for streaks, so that I feel more engaged. |
| **Could Have** | As a child, I want a "Forgot Password" feature via email, so that I can recover my account independently. |

---

## 4. Won’t Have for MVP

| Priority | User Story |
| :--- | :--- |
| **Won’t Have** | As a parent, I want AI-generated task suggestions, so that I can receive automatic task ideas. |
| **Won’t Have** | As a family, I want to join family challenges, so that multiple children can compete. |
| **Won’t Have** | As a parent, I want advanced behavior analytics reports, so that I can study long-term trends. |
| **Won’t Have** | As a child, I want to customize my avatar, so that I can personalize my profile. |
| **Won’t Have** | As a user, I want real-time Push Notifications outside the app, so that I stay updated. |
---

## 3.4 Mockups

Mockups will be created using **Figma** because it is collaborative, accessible, and suitable for mobile application design.

The mockups will follow these design principles:

* Arabic-first interface
* Right-to-left layout
* Lavender as the primary color
* Gold star as the Noor Points visual symbol
* Simple child-friendly language
* Clear navigation for parents and children
* Calm and family-friendly visual style

### Main Mockup Screens

| Screen                      | Description                                                    |
| --------------------------- | -------------------------------------------------------------- |
| Welcome / Onboarding Screen | Introduces Asalah and explains its purpose.                    |
| Login Screen                | Allows parents to log in securely.                             |
| Register Screen             | Allows parents to create a new account.                        |
| Parent Dashboard            | Shows children, tasks, pending approvals, points, and rewards. |
| Child Profiles Screen       | Allows the parent to view and manage child profiles.           |
| Create Child Profile Screen | Allows the parent to add a child profile.                      |
| Task Management Screen      | Allows the parent to view, create, edit, and delete tasks.     |
| Create Task Screen          | Allows the parent to create and assign a task.                 |
| Task Review Screen          | Allows the parent to approve or reject completed tasks.        |
| Reward Management Screen    | Allows the parent to create and manage rewards.                |
| Child Dashboard             | Shows the child’s tasks, Noor Points, progress, and rewards.   |
| Assigned Tasks Screen       | Allows the child to view and complete assigned tasks.          |
| Noor Points Screen          | Shows the child’s current Noor Points balance and progress.    |
| Rewards Store Screen        | Shows available rewards.                                       |
| Reward Request Screen       | Allows the child to request a reward.                          |

---

## 4. System Architecture

### 4.1 Purpose

The purpose of this section is to define the high-level architecture of the Asalah MVP and show how the main components interact.

Asalah will use a **client-server architecture**. The Flutter mobile application will communicate with the Flask backend through RESTful API requests using JSON. The backend will process business logic, interact with the database through Flask-SQLAlchemy, and return JSON responses to the frontend.

---

## 4.2 High-Level System Architecture Diagram
 
 ![alt text](<high Diagram.drawio.png>)

---

## 4.3 System Architecture Explanation

The system architecture is divided into clear layers:

| Layer                    | Description                                                                                  |
| ------------------------ | -------------------------------------------------------------------------------------------- |
| Users                    | Parent and child users who interact with the mobile application.                             |
| Frontend Layer           | Flutter mobile app containing parent screens, child screens, shared screens, and API client. |
| Backend Layer            | Flask REST API that receives requests and returns JSON responses.                            |
| Business Logic Layer     | Handles application rules such as task approval, reward redemption, and points calculation.  |
| Data Access Layer        | Uses Flask-SQLAlchemy ORM to connect backend models to database tables.                      |
| Database Layer           | Stores users, children, tasks, rewards, redemptions, and Noor Points transactions.           |
| Future External Services | Services that may be added later but are not required for the MVP.                           |

---

## 4.4 System Architecture Justification

Flutter was selected because it supports cross-platform mobile development from one codebase. This allows the team to build a consistent mobile experience for Android and iOS.

Python Flask was selected because it is lightweight, flexible, and suitable for building RESTful APIs for an MVP.

Flask-SQLAlchemy was selected because it allows the team to represent database tables as Python models and interact with the database in a cleaner way.

A layered architecture was selected because it separates responsibilities between the frontend, backend API, business logic, data access, and database. This improves maintainability, testing, and future scalability.

---

## 5. Components, Classes, and Database Design

### 5.1 Purpose

The purpose of this section is to define the internal structure of the Asalah MVP. This includes frontend components, backend classes, database tables, and relationships.

---

### 5.2 Frontend Components

| Component | Description |
| :--- | :--- |
| **WelcomeScreen** | Introduces the application and provides main entry points. |
| **LoginScreen** | Handles login for both Parent (using parent credentials) and Child (using child email and password via the "I am a Child" option). |
| **RegisterScreen** | Handles parent account registration. |
| **ParentDashboard** | Overview of all children, pending task reviews, and household progress. |
| **ChildProfilesScreen** | Lists and manages child profiles linked to the parent account. |
| **CreateChildProfileScreen** | Form for the parent to create a child profile (including setting the child's unique email and password). |
| **TaskManagementScreen** | Displays active tasks, status, and assignment oversight. |
| **CreateTaskScreen** | Form to create tasks, set Noor Points, and define approval requirements. |
| **TaskReviewScreen** | Allows parents to approve/reject tasks by reviewing daily feedback (emoji/comment). |
| **RewardManagementScreen** | Displays and manages the rewards set by the parents. |
| **CreateRewardScreen** | Form for parents to add new rewards to the rewards pool. |
| **ChildDashboard** | Main interface for the child showing Noor Points balance, active tasks, and quick stats. |
| **AssignedTasksScreen** | List of current tasks assigned to the child with the ability to mark them as completed. |
| **WishlistScreen** | Dedicated screen for the child to add, manage, and track progress toward their personal wishlist items. |
| **NoorPointsScreen** | Detailed view of point accumulation history. |
| **RewardsStoreScreen** | Displays available rewards set by the parent; allows the child to request redemptions. |
| **ProgressScreen** | Visual tracking of task completion and behavioral progress over time. |
---
## 5.3 Backend Classes

The backend is developed using Python Flask and Flask-SQLAlchemy. All core business objects inherit from the `BaseModel` to ensure consistency and maintain audit trails.

### BaseModel (Abstract)
The foundation for all entities, providing standard metadata.

| Attribute | Type | Description |
| :--- | :--- | :--- |
| id | UUID | Unique identifier. |
| createdAt | DateTime | Timestamp of creation. |
| updatedAt | DateTime | Timestamp of the last update. |

---

### User Class
Represents the parent account responsible for managing the system.

| Attribute | Type | Description |
| :--- | :--- | :--- |
| firstName | String | Parent's first name. |
| lastName | String | Parent's last name. |
| email | String | Email address (login identifier). |
| hash_password | String | Encrypted password. |
| isActive | Boolean | Account active status. |

* **Methods**: `createChild()`, `createTask()`, `approveTask()`, `sendFeedback()`, `createReward()`.

---

### Child Class
Represents a child profile linked to a parent.

| Attribute | Type | Description |
| :--- | :--- | :--- |
| parentId | UUID | Foreign key referencing the User. |
| firstName | String | Child's first name. |
| lastName | String | Child's last name. |
| email | String | Child's login email. |
| hash_password | String | Encrypted password. |
| totalPoints | Integer | Accumulated "Noor Points" balance. |

* **Methods**: `viewTasks()`, `completeTask()`, `viewWishlist()`, `viewRewards()`.

---

### Task Class
Represents tasks assigned to a child by the parent.

| Attribute | Type | Description |
| :--- | :--- | :--- |
| childId | UUID | Foreign key referencing the Child. |
| title | String | Task title. |
| description | String | Task description. |
| category | String | Task category. |
| points | Integer | Assigned Noor Points. |
| status | String | Current task status. |
| frequency | String | Task recurrence frequency. |
| requiresApproval | Boolean | Indicates if parent approval is needed. |

* **Methods**: `complete()`, `approve()`.

---

### DailyFeedback Class
Stores feedback linked to a specific completed task.

| Attribute | Type | Description |
| :--- | :--- | :--- |
| taskId | UUID | Foreign key referencing the Task. |
| emoji | String | Visual feedback indicator. |
| comment | String | Detailed feedback text. |

* **Methods**: `addFeedback()`.

---

### Wishlist Class
Manages the items a child wishes to obtain with points.

| Attribute | Type | Description |
| :--- | :--- | :--- |
| childId | UUID | Foreign key referencing the Child. |
| itemName | String | Name of the desired item. |
| targetPoints | Integer | Points required for the item. |
| status | String | Current status of the wish. |

* **Methods**: `addItem()`, `removeItem()`.

---

### Reward Class
Defines the rewards created by parents for children.

| Attribute | Type | Description |
| :--- | :--- | :--- |
| childId | UUID | Foreign key referencing the Child. |
| title | String | Reward title. |
| category | String | Reward category. |
| source | String | Source or provider of the reward. |
| status | String | Reward availability status. |

* **Methods**: `create()`, `approve()`.

---

## 5.4 Database Design

The system utilizes a relational database structure to maintain integrity between all entities defined in the class diagram.

| Table | Purpose |
| :--- | :--- |
| Users | Stores parent account details and system management. |
| Children | Stores child profile data and point balances. |
| Tasks | Manages task assignments and completion statuses. |
| Wishlist | Tracks child goals and target points. |
| Rewards | Stores available reward items. |
| DailyFeedback | Links qualitative feedback to completed tasks. |
---

## 5.5 ER Digraam

![alt text](ER-digraammm.png)

---

## 5.6 Database Design Justification

A relational database was selected because Asalah contains structured data with clear relationships. One parent can have many children, each child can have many tasks, and each child can have a history of Noor Points transactions.

The `noor_points_transactions` table is separated from the `children` table because the application needs to track the history of how points were earned, redeemed, or adjusted. This improves transparency and makes progress tracking more accurate.

---

## 6. High-Level Sequence Diagrams

### 6.1 Purpose

The purpose of this section is to illustrate how the application components interact during key Asalah MVP use cases, ensuring a seamless flow between parents, children, and the backend infrastructure.

The sequence diagrams involve the following components:

| Component | Description |
| :--- | :--- |
| **Parent** | The parent user managing the account and household. |
| **Child** | The child user interacting with assigned tasks and rewards. |
| **Flutter App** | The cross-platform mobile frontend. |
| **Flask API** | The backend server handling business logic and authentication. |
| **Database** | The persistent storage layer (SQLAlchemy models). |

The key interaction scenarios selected are:

1. **User Authentication:** Unified login flow for both Parent and Child accounts.
2. **Task Creation:** Parent defines a task, assigns points, and sets approval requirements.
3. **Task Lifecycle:** Child completes a task, provides daily feedback, and Parent performs approval.
4. **Reward Redemption:** Child requests reward redemption based on accumulated Noor Points.

---

## 6.2 Parent Login Sequence Diagram

```mermaid
sequenceDiagram
    title Use Case 1: Parent Login

    actor Parent
    participant FlutterApp as Flutter App
    participant FlaskAPI as Flask API
    participant Database as Database

    Parent->>FlutterApp: Enter email and password
    FlutterApp->>FlaskAPI: POST /api/login { email, password }
    FlaskAPI->>Database: Search for user by email
    Database-->>FlaskAPI: Return user record

    alt Valid credentials
        FlaskAPI->>FlaskAPI: Check password hash
        FlaskAPI-->>FlutterApp: 200 OK { message, user, token }
        FlutterApp-->>Parent: Redirect to Parent Dashboard
    else Invalid email or password
        FlaskAPI-->>FlutterApp: 401 Unauthorized { error }
        FlutterApp-->>Parent: Display login error message
    end
```

---
## 6.3 chaild Login Sequence Diagram

```mermaid
sequenceDiagram
    title Use Case: Child Login

    actor Child
    actor Parent
    participant FlutterApp as Flutter App
    participant FlaskAPI as Flask API
    participant Database as Database

    Child->>FlutterApp: Select "I am a Child"
    Child->>FlutterApp: Enter email and password
    FlutterApp->>FlaskAPI: POST /api/child-login

    FlaskAPI->>Database: Find child by email
    Database-->>FlaskAPI: Return child record

    alt Valid credentials
        FlaskAPI->>FlaskAPI: Verify password hash
        FlaskAPI-->>Parent: Send verification request

        Parent->>FlutterApp: Approve child login
        FlutterApp->>FlaskAPI: Confirm approval

        FlaskAPI-->>FlutterApp: 200 OK { child, token }
        FlutterApp-->>Child: Redirect to Child Dashboard

    else Invalid credentials
        FlaskAPI-->>FlutterApp: 401 Unauthorized
        FlutterApp-->>Child: Display login error
    end
```
---
## 6.3 Parent Creates Task Sequence Diagram

```mermaid
sequenceDiagram
    title Use Case 2: Parent Creates a Task

    actor Parent
    participant FlutterApp as Flutter App
    participant FlaskAPI as Flask API
    participant Database as Database

    Parent->>FlutterApp: Open Create Task Screen
    Parent->>FlutterApp: Enter task details
    FlutterApp->>FlaskAPI: POST /api/tasks { child_id, title, description, points_value, due_date }

    FlaskAPI->>FlaskAPI: Validate required fields
    FlaskAPI->>FlaskAPI: Validate points value
    FlaskAPI->>Database: Check that child belongs to parent
    Database-->>FlaskAPI: Return child record

    alt Valid task data
        FlaskAPI->>Database: Insert new task record with status pending
        Database-->>FlaskAPI: Return created task
        FlaskAPI-->>FlutterApp: 201 Created { message, task }
        FlutterApp-->>Parent: Display task in Task Management Screen
    else Missing or invalid fields
        FlaskAPI-->>FlutterApp: 400 Bad Request { error }
        FlutterApp-->>Parent: Display validation error
    else Child does not belong to parent
        FlaskAPI-->>FlutterApp: 403 Forbidden { error }
        FlutterApp-->>Parent: Display access error
    end
```
---

## 6.4 Child Completes Task and Parent Approves It Sequence Diagram

```mermaid
sequenceDiagram
    title Use Case 3: Child Completes Task and Parent Approves It

    actor Child
    actor Parent
    participant FlutterApp as Flutter App
    participant FlaskAPI as Flask API
    participant Database as Database

    Child->>FlutterApp: Open Assigned Tasks Screen
    Child->>FlutterApp: Mark task as completed
    FlutterApp->>FlaskAPI: POST /api/tasks/{task_id}/complete

    FlaskAPI->>Database: Find task by task_id
    Database-->>FlaskAPI: Return task record
    FlaskAPI->>FlaskAPI: Validate task belongs to child

    alt Task is valid
        FlaskAPI->>Database: Update task status to completed
        Database-->>FlaskAPI: Confirm task update
        FlaskAPI-->>FlutterApp: 200 OK { message, task }
        FlutterApp-->>Child: Show task as waiting for parent approval
    else Invalid task
        FlaskAPI-->>FlutterApp: 404 or 403 Error { error }
        FlutterApp-->>Child: Display task error message
    end

    Parent->>FlutterApp: Open Task Review Screen
    Parent->>FlutterApp: Approve completed task
    FlutterApp->>FlaskAPI: POST /api/tasks/{task_id}/approve

    FlaskAPI->>Database: Find task by task_id
    Database-->>FlaskAPI: Return task record
    FlaskAPI->>FlaskAPI: Validate task status is completed
    FlaskAPI->>FlaskAPI: Validate parent owns task

    alt Task can be approved
        FlaskAPI->>Database: Update task status to approved
        FlaskAPI->>Database: Add Noor Points to child balance
        FlaskAPI->>Database: Insert Noor Points transaction
        Database-->>FlaskAPI: Return updated task and points balance
        FlaskAPI-->>FlutterApp: 200 OK { message, task, points_balance }
        FlutterApp-->>Parent: Show task approved successfully
        FlutterApp-->>Child: Update Noor Points balance
    else Task already approved
        FlaskAPI-->>FlutterApp: 409 Conflict { error }
        FlutterApp-->>Parent: Display duplicate approval error
    end
```

---

## 6.5 Reward Redemption Sequence Diagram

```mermaid
sequenceDiagram
    title Use Case 4: Child Requests Reward Redemption

    actor Child
    participant FlutterApp as Flutter App
    participant FlaskAPI as Flask API
    participant Database as Database

    Child->>FlutterApp: Open Rewards Store Screen
    Child->>FlutterApp: Select reward
    Child->>FlutterApp: Request redemption

    FlutterApp->>FlaskAPI: POST /api/rewards/{reward_id}/redeem { child_id }

    FlaskAPI->>Database: Find reward by reward_id
    Database-->>FlaskAPI: Return reward details

    FlaskAPI->>Database: Find child by child_id
    Database-->>FlaskAPI: Return child points balance

    FlaskAPI->>FlaskAPI: Validate reward is available
    FlaskAPI->>FlaskAPI: Check if child has enough Noor Points

    alt Child has enough points
        FlaskAPI->>Database: Insert redemption record with status requested
        Database-->>FlaskAPI: Return redemption request
        FlaskAPI-->>FlutterApp: 201 Created { message, redemption }
        FlutterApp-->>Child: Display request submitted message
    else Not enough Noor Points
        FlaskAPI-->>FlutterApp: 400 Bad Request { error }
        FlutterApp-->>Child: Display more points needed message
    else Reward unavailable
        FlaskAPI-->>FlutterApp: 400 Bad Request { error }
        FlutterApp-->>Child: Display reward unavailable message
    end
```

---

## 6.6 Sequence Diagram Justification

The selected sequence diagrams illustrate the core MVP interactions of the **Asalah** system. These include:

- Parent authentication.
- Task creation by the parent.
- Task completion by the child and subsequent parent approval.
- Automatic Noor Points update.
- Weekly reward evaluation.

These flows form the backbone of **Asalah's** value proposition because they tightly connect:

- **Responsibility** (Tasks)
- **Accountability** (Parent Approval)
- **Motivation** (Noor Points)
- **Positive Reinforcement** (Weekly Rewards)

---

## 7. Internal API Overview

The Asalah application uses a RESTful API architecture to manage communication between the Flutter frontend and the Flask backend.

| Item | Format |
| :--- | :--- |
| **Protocol** | HTTPS |
| **API Style** | REST |
| **Request/Response** | JSON |
| **Authentication** | Token-based (JWT) |
| **Base URL** | `/api` |

---

## 7.1 Authentication Endpoints

| Endpoint | Method | Purpose |
| :--- | :--- | :--- |
| `/api/register` | `POST` | Register parent account. |
| `/api/login` | `POST` | Parent login (returns token). |
| `/api/child-login` | `POST` | Child login (returns token). |

---

## 7.2 Child Profile Endpoints

| Endpoint | Method | Purpose |
| :--- | :--- | :--- |
| `/api/children` | `GET` | List all children. |
| `/api/children` | `POST` | Create a new child profile. |
| `/api/children/<id>` | `GET` | Get specific child profile. |
| `/api/children/<id>` | `PUT` | Update child profile details. |
| `/api/children/<id>` | `DELETE` | Delete a child profile. |

---

## 7.3 Task & Feedback Endpoints

| Endpoint | Method | Purpose |
| :--- | :--- | :--- |
| `/api/tasks` | `POST` | Create a new task. |
| `/api/tasks` | `GET` | Get all tasks (filtered by child/parent). |
| `/api/tasks/<id>` | `GET` | Get specific task details. |
| `/api/tasks/<id>` | `PUT` | Update task. |
| `/api/tasks/<id>` | `DELETE` | Delete task. |
| `/api/tasks/<id>/complete` | `POST` | Child marks task as completed. |
| `/api/tasks/<id>/feedback` | `POST` | Submit daily feedback (emoji/comment). |
| `/api/tasks/<id>/approve` | `POST` | Parent approves task and awards points. |
| `/api/tasks/<id>/reject` | `POST` | Parent rejects task. |

### Example Feedback JSON
```json
{
  "emoji": "🌟",
  "comment": "Great job today!"
}

```
---
# 7.4 Wishlist Endpoints

| Endpoint | Method | Purpose |
| :--- | :---: | :--- |
| `/api/wishlist` | `GET` | Retrieve the child's wishlist. |
| `/api/wishlist` | `POST` | Add a new wishlist item. |
| `/api/wishlist/<id>` | `PUT` | Update a wishlist item. |
| `/api/wishlist/<id>` | `DELETE` | Remove a wishlist item. |

## Example Wishlist Item JSON

```json
{
  "title": "New Coloring Book",
  "cost_in_points": 120
}
```

---

# 7.5 Weekly Rewards Endpoints

*(No Redeem – No Points – Weekly Approval System)*

## Weekly Rewards Logic

- Rewards appear to the child every Thursday.
- Rewards depend on task completion.
- Parent decides whether to **Approve** or **Reject** the reward.
- No redeeming process is required.
- No points are deducted.
- Points are only used for the Wishlist.

## Endpoints

| Endpoint | Method | Purpose |
| :--- | :---: | :--- |
| `/api/rewards/week` | `GET` | Get the current week's rewards for the child. |
| `/api/rewards/generate` | `POST` | Generate weekly rewards (Thursday). |
| `/api/rewards/<id>/approve` | `POST` | Parent approves the reward. |
| `/api/rewards/<id>/reject` | `POST` | Parent rejects the reward. |

## Example Weekly Reward JSON

```json
{
  "reward_name": "Choose Friday Movie",
  "description": "Child gets to pick the family movie.",
  "week_start": "2026-06-25",
  "week_end": "2026-07-01",
  "status": "PENDING"
}
```

## Example Approve JSON

```json
{
  "status": "APPROVED",
  "note": "Great job finishing all tasks this week!"
}
```

---

# 7.6 Noor Points & Progress Endpoints

| Endpoint | Method | Purpose |
| :--- | :---: | :--- |
| `/api/children/<id>/points` | `GET` | Get the child's current point balance. |
| `/api/children/<id>/history` | `GET` | Get point transaction history. |
| `/api/children/<id>/progress` | `GET` | Get weekly/monthly progress summary. |

## Example Points JSON

```json
{
  "total_points": 340,
  "earned_from_tasks": 300,
  "earned_from_feedback": 40
}
```

---

# 7.7 Common Error Responses

| Status Code | Description |
| :---: | :--- |
| `400` | Bad Request. |
| `401` | Unauthorized. |
| `403` | Forbidden. |
| `404` | Not Found. |
| `500` | Internal Server Error. |

---

# 7.8 API Design Justification

The API follows RESTful principles to ensure scalability, maintainability, and a clean architecture. JSON is used as the standard data format because it integrates seamlessly with Flutter applications. Authentication is secured using JWT to protect both parent and child sessions.

Unlike traditional reward systems, weekly rewards are not redeemed using points. Instead, they are automatically generated based on the child's completed tasks, and the parent simply approves or rejects them. This approach encourages positive behavior while avoiding a marketplace-style reward system.

Points are reserved exclusively for the Wishlist feature, providing children with long-term motivation to consistently complete tasks and achieve their goals.

---

## 8. Source Control Management Strategy

### 8.1 Purpose

The purpose of this section is to define how the team will manage source code and collaborate during development.

The team will use **Git** for version control and **GitHub** for repository hosting, pull requests, code reviews, and documentation.

---

## 8.2 Branching Strategy

| Branch        | Purpose                                                                 |
| ------------- | ----------------------------------------------------------------------- |
| `main`        | Stable production-ready version of the project.                         |
| `development` | Main working branch where completed features are merged before release. |
| `feature/*`   | Branches created for individual features.                               |
| `fix/*`       | Branches created for bug fixes.                                         |
| `docs/*`      | Branches created for documentation updates.                             |

### Branch Name Examples

```bash
feature/user-authentication
feature/create-child-profile
feature/task-management
feature/noor-points-system
feature/reward-redemption
fix/login-validation-error
docs/stage-3-technical-documentation
```

---

## 8.3 Git Workflow

The team will follow this workflow:

```txt
Create branch from development
        |
Work on feature or fix
        |
Commit changes regularly
        |
Push branch to GitHub
        |
Open Pull Request
        |
Code review
        |
Merge into development
        |
Run QA testing
        |
Merge stable version into main
```

---

## 8.4 Commit Strategy

The team will make regular commits with clear and meaningful messages.

Example commit messages:

```bash
git commit -m "Add parent registration endpoint"
git commit -m "Create child profile model"
git commit -m "Build parent dashboard screen"
git commit -m "Implement task approval logic"
git commit -m "Add Noor Points transaction table"
git commit -m "Add Swagger API documentation"
git commit -m "Update technical documentation"
```

### Commit Guidelines

* Commit small and meaningful changes.
* Use clear messages.
* Avoid committing broken code to shared branches.
* Pull latest changes before starting work.
* Do not commit passwords, tokens, or secrets.
* Use `.gitignore` to exclude unnecessary files.

---

## 8.5 Pull Request and Code Review Strategy

Each completed feature should be submitted through a Pull Request before being merged into `development`.

Pull Requests should include:

* Clear title
* Short description
* Related feature or issue
* Screenshots for frontend changes
* API request/response examples for backend changes
* Swagger documentation updates for API changes
* Testing notes

Before merging, reviewers should check:

* Code matches the requirement
* Code is readable and organized
* API endpoints return clear JSON responses
* Swagger documentation is updated
* Database changes are correct
* No sensitive data is included
* Documentation is updated when needed

---

## 8.6 SCM Justification

Git and GitHub were selected because they support team collaboration, version control, branching, pull requests, code reviews, and project history tracking.

A simple branching strategy was selected because Asalah is an MVP project. It gives the team structure without adding unnecessary complexity.

---

## 9. Quality Assurance Strategy

### 9.1 Purpose

Quality Assurance will be used to confirm that Asalah works correctly, securely, and consistently before deployment.

Testing will cover:

* Backend APIs
* Frontend screens
* Database operations
* Frontend-backend integration
* Complete user flows
* Arabic interface and RTL layout

---

## 9.2 Testing Types

| Testing Type            | Purpose                                                                     |
| ----------------------- | --------------------------------------------------------------------------- |
| Unit Testing            | Test individual backend functions and frontend components.                  |
| API Testing             | Test backend endpoints and JSON responses.                                  |
| Swagger-Based Testing   | Test endpoints using interactive Swagger UI.                                |
| Integration Testing     | Test communication between Flutter frontend and Flask backend.              |
| Manual UI Testing       | Test Arabic interface, RTL layout, navigation, and usability.               |
| End-to-End Testing      | Test full user flows from registration to reward redemption.                |
| User Acceptance Testing | Confirm that the MVP is understandable and useful for parents and children. |

---

## 9.3 Testing Tools

| Area                | Tool                                  | Purpose                                                                |
| ------------------- | ------------------------------------- | ---------------------------------------------------------------------- |
| Backend Testing     | Pytest                                | Test Flask backend logic, models, and business rules.                  |
| API Documentation   | Swagger / OpenAPI                     | Document endpoints, request bodies, parameters, responses, and errors. |
| API Testing         | Swagger UI                            | Test endpoints directly from the browser.                              |
| API Testing         | Postman                               | Test API requests and scenarios manually.                              |
| Frontend Testing    | Flutter Test                          | Test Flutter widgets and frontend logic.                               |
| Integration Testing | Swagger UI / Postman / Manual Testing | Verify frontend-backend communication.                                 |
| Database Testing    | Flask-SQLAlchemy / Test Database      | Test models, relationships, and queries.                               |

---

## 9.4 Key QA Flows

### Task Completion and Noor Points Flow

```txt
Parent registers or logs in
        |
Parent creates child profile
        |
Parent creates task
        |
Child views assigned task
        |
Child marks task as completed
        |
Parent reviews completed task
        |
Parent approves task
        |
Noor Points are added to child balance
        |
Noor Points transaction is created
```

### Reward Redemption Flow

```txt
Parent creates reward
        |
Child views rewards store
        |
Child requests reward
        |
System checks Noor Points balance
        |
Parent reviews redemption request
        |
Parent approves redemption
        |
Noor Points are deducted
        |
Redeemed points transaction is created
```

---

## 9.5 QA Checklist Before Merging

Before merging a feature into `development`, the team should confirm:

* Feature works locally
* Code does not break existing features
* Required fields are validated
* Error messages are clear
* API responses are in JSON format
* Swagger documentation is updated for new or changed endpoints
* Swagger UI testing has been performed for backend endpoint changes
* Database changes work correctly
* Frontend screens display correct data
* Arabic layout is readable
* No sensitive data is committed
* Documentation is updated if needed

---

## 9.6 QA Justification

Pytest was selected because it works well with Python and Flask applications.

Swagger/OpenAPI was added because it provides interactive API documentation and allows the team to test backend endpoints directly from the browser.

Postman supports detailed API request testing and repeated test scenarios.

Flutter Test supports testing Flutter widgets and frontend logic.

Manual UI testing is necessary because Asalah has an Arabic-first, child-friendly interface that requires visual and usability review.

---

## 10. Deployment Plan

### 10.1 Development Environment

The development environment will be used by the team while building features.

```txt
Flutter app running on emulator or physical device
Flask backend running locally
Local development database
Swagger UI available for local API testing
```

---

## 10.2 Staging Environment

The staging environment will be used to test the application before release.

```txt
Stable development branch
Test database
Backend deployed to a test server or shared environment
Flutter app connected to staging API
Swagger UI available for API verification
```

---

## 10.3 Production Environment

The production environment will be used for the final stable MVP release.

```txt
main branch
Production backend server
Production database
Final mobile app build
```

---

## 10.4 Deployment Workflow

```txt
Feature branch completed
        |
Pull Request opened
        |
Code review completed
        |
Swagger API documentation checked
        |
Feature merged into development
        |
QA testing on development
        |
Stable version merged into main
        |
Deploy backend and database
        |
Build final Flutter app
        |
Run final MVP testing
        |
Release MVP
```

---

## 11. Technical Justifications Summary

| Technical Decision           | Justification                                                                               |
| ---------------------------- | ------------------------------------------------------------------------------------------- |
| Flutter frontend             | Supports cross-platform mobile development from one codebase.                               |
| Python Flask backend         | Lightweight, flexible, and suitable for RESTful MVP APIs.                                   |
| Flask-SQLAlchemy             | Simplifies database interaction using Python models.                                        |
| Relational database          | Fits structured data and relationships between users, children, tasks, rewards, and points. |
| REST API                     | Separates frontend and backend clearly.                                                     |
| JSON format                  | Lightweight and easy to use between mobile app and backend.                                 |
| Swagger/OpenAPI              | Documents and tests backend APIs interactively.                                             |
| Git and GitHub               | Supports collaboration, branching, pull requests, and code review.                          |
| MoSCoW prioritization        | Helps focus the MVP on essential features first.                                            |
| Arabic-first design          | Matches the target users: Saudi families.                                                   |
| Lavender visual identity     | Provides a calm, friendly, family-oriented design.                                          |
| Gold star Noor Points symbol | Represents growth, achievement, and motivation.                                             |

---

## 12. Conclusion

This technical documentation provides a complete blueprint for building the Asalah MVP. It defines user stories, mockups, system architecture, frontend components, backend classes, database design, sequence diagrams, API specifications, source control management, quality assurance strategies, deployment planning, and technical justifications.

The planned system is simple enough for MVP development while still supporting future growth. By separating the frontend, backend, business logic, data access, and database layers, the team can work collaboratively and build a clear, maintainable, and testable application.

The MVP focuses on the core value of Asalah: helping Saudi families teach children financial responsibility through tasks, Noor Points, rewards, and positive parent-child interaction.
