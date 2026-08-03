# Report: Results Summary

## Project Information

**Project Name:** Asalah  
**Project Type:** Holberton School Portfolio Project  
**Program:** Software Engineering Foundations  
**Stage:** Stage 5 — Project Closure  

## Team Members

| Team Member | Role |
|---|---|
| [Mnar Alzahrani](https://github.com/mnarzaid247-stack) | Backend Developer |
| [Manar Althqfi](https://github.com/manaralthqfiu) | Backend Developer |
| [Mariam Backroush](https://github.com/MariamBB-a) | Project Manager, Database Design and Management |
| [Norah Aljuhani](https://github.com/Norahxj) | Team Lead, Frontend Development and Frontend-Backend Testing |

---

## Project Overview

Asalah is a gamified, value-based financial literacy platform designed for Saudi families. It helps parents teach children responsibility, positive habits, and basic money-management concepts through meaningful tasks, a non-monetary points system called **Noor Points**, wishlists, and parent-managed rewards.

The project was developed as a full-stack minimum viable product consisting of a Flutter Web frontend, a Python Flask backend, and a PostgreSQL database.

The MVP provides two connected user experiences: one for parents and one for children.

### Parent Experience

Parents can:

- Register and log in securely.
- Create and manage child profiles.
- Create tasks and assign them to children.
- Define each task's category, frequency, and Noor Points value.
- Review tasks submitted by children.
- Approve completed tasks or return them for another attempt.
- Monitor completed tasks and Noor Points.
- Review children's wishlist goals.
- Create and approve weekly rewards.

### Child Experience

Children can:

- Log in using their child access information.
- View their assigned tasks.
- Mark tasks as completed for parent review.
- Earn Noor Points after parent approval.
- View completed tasks and progress information.
- Create and manage wishlist goals.
- Work toward available rewards and request them.

The MVP focuses on providing a safe, parent-controlled, and culturally relevant learning experience without using real-money transactions.

---

## Portfolio Project Deliverables

### Live Landing Page

[Open the Asalah landing page](https://manaralthqfiu.github.io/landing-page/)

### Live MVP

[Open the deployed Asalah application](https://asalah-26b7d.web.app)

### Demo Video

[Watch the Asalah demo video](https://www.youtube.com/shorts/m_2an96Q1G0)

### Project Presentation

[View the Asalah project presentation](https://canva.link/90cj1r84wg2lqnl)

### Project Repository

[View the Asalah Portfolio Project repository](https://github.com/Norahxj/HolbertonSchool-Portfolio_Project)

### Production Backend

[Open the deployed Flask REST API](https://holbertonschool-portfolio-project-22a6.onrender.com)

---

## Project Journey Overview

The Asalah project progressed through five structured stages, beginning with team formation and idea development and ending with a functional, tested, and deployed MVP.

### Stage 1: Team Formation and Idea Development

The team formed its working group, assigned initial roles, brainstormed possible software ideas, evaluated the available options, and selected Asalah as the final portfolio project concept.

The idea was refined around the needs of Saudi families, value-based learning, financial awareness, responsibility, and child-friendly gamification.

### Stage 2: Project Charter Development

The team defined:

- The project's purpose.
- Main objectives.
- Target users and stakeholders.
- Team roles.
- MVP scope.
- Out-of-scope features.
- Risks and mitigation strategies.
- Milestones.
- A high-level project plan.

This stage provided a shared reference for decision-making and helped the team control the project scope.

### Stage 3: Technical Documentation

The team translated the project charter into a technical implementation plan.

The documentation covered:

- User stories.
- Functional and non-functional requirements.
- Frontend and backend architecture.
- Database entities and relationships.
- API planning.
- Main application workflows.
- Sequence diagrams.
- Testing strategy.
- Source-control practices.

### Stage 4: MVP Development and Execution

The MVP was developed through four one-week sprints:

1. Authentication, backend foundation, database models, and child management.
2. Task creation, task assignment, task completion, and frontend-backend integration.
3. Parent review, task-status management, Noor Points, and progress-related screens.
4. Wishlist goals, weekly rewards, final integration testing, bug fixing, performance improvements, and deployment preparation.

### Stage 5: Project Closure

The final stage evaluates the delivered results, records the lessons learned, summarizes the team's retrospective highlights, and prepares the project for final submission, demonstration, and handover.

---

## MVP Feature Completion

| Feature | Planned | Delivered | Status |
|---|---:|---:|---|
| Parent registration and login | Yes | Yes | Complete |
| Child profile creation and management | Yes | Yes | Complete |
| Child login | Yes | Yes | Complete |
| Parent dashboard | Yes | Yes | Complete |
| Child task interface | Yes | Yes | Complete |
| Task creation | Yes | Yes | Complete |
| Task editing and deletion | Yes | Yes | Complete |
| Task assignment | Yes | Yes | Complete |
| Task-completion submission | Yes | Yes | Complete |
| Parent task review | Yes | Yes | Complete |
| Task approval and return for another attempt | Yes | Yes | Complete |
| Task-status updates | Yes | Yes | Complete |
| Noor Points calculation and updates | Yes | Yes | Complete |
| Points dashboard | Yes | Yes | Complete |
| Completed-tasks history | Yes | Yes | Complete |
| Wishlist creation and management | Yes | Yes | Complete |
| Parent approval of wishlist goals | Yes | Yes | Complete |
| Weekly rewards | Yes | Yes | Complete |
| Weekly reward approval | Yes | Yes | Complete |
| Basic progress tracking | Yes | Yes | Complete |
| Frontend-backend integration | Yes | Yes | Complete |
| Frontend and backend validation | Yes | Yes | Complete |
| API testing | Yes | Yes | Complete |
| Flutter widget testing | Yes | Yes | Complete |
| Integration and end-to-end testing | Yes | Yes | Complete |
| Regression testing | Yes | Yes | Complete |
| Production deployment | Yes | Yes | Complete |
| Testing and production documentation | Yes | Yes | Complete |

---

## Project Objectives Evaluation

| Project Objective | Target | Final Result |
|---|---|---|
| Introduce children to earning, saving, and responsible spending through Noor Points | Provide a non-monetary points system connected to meaningful task completion | Noor Points were implemented and are awarded after parent-approved task completion. Children can track their points and work toward wishlist goals and rewards. |
| Help parents teach cultural, behavioral, and value-based habits | Allow parents to create structured tasks, assign them to children, and define their points values | Parents can create and manage tasks, select categories and frequencies, assign tasks to children, and control the approval process. |
| Deliver a motivating and gamified child experience | Allow children to complete tasks, track progress, earn points, and request rewards | The child experience includes assigned tasks, completion submission, Noor Points, completed-task information, wishlist goals, and weekly rewards. |
| Provide a controlled parent-child workflow | Require parent review before task completion affects points or rewards | The full workflow from child completion to parent approval or return for another attempt was implemented and tested. |
| Deliver a connected full-stack MVP | Integrate the user interface, backend APIs, and persistent database storage | The Flutter frontend communicates with the deployed Flask REST API, and project data is stored in PostgreSQL. |
| Validate the MVP before final delivery | Test core components and complete user journeys | API, validation, widget, integration, end-to-end, regression, and production-environment testing were completed and documented. |

---

## Key Project Outcomes

- The team delivered a functional full-stack MVP for both parent and child users.
- The application supports secure parent authentication and controlled child access.
- Parents can create children, tasks, wishlist goals, and weekly rewards.
- Children can view and complete assigned tasks and work toward selected goals.
- Parent approval controls task status and Noor Points awards.
- Noor Points provide a safe, non-monetary way to demonstrate earning and saving concepts.
- The frontend is connected to real backend APIs rather than static sample data.
- Data is stored in a production PostgreSQL database.
- Task, approval, points, wishlist, and reward workflows were integrated into one application.
- Frontend validation was aligned with backend business rules.
- The team completed API, widget, integration, end-to-end, regression, and production testing.
- Major integration bugs were corrected before final delivery.
- The frontend and backend were deployed to cloud platforms.
- The team created an Arabic landing page explaining the project, its value, its features, and its members.
- The team prepared a final presentation and demonstration video.

---

## Testing Results

The team used several testing approaches throughout development:

- Swagger-based API testing.
- Manual frontend testing.
- Frontend validation testing.
- Flutter widget testing.
- Frontend-backend integration testing.
- End-to-end workflow testing.
- Regression testing after changes and bug fixes.
- Production-environment verification.

The documented Flutter widget tests completed successfully with the following result:

```text
00:02 +3: All tests passed!
```

The main end-to-end task workflow was also completed successfully:

1. The parent logs in.
2. The parent adds a child.
3. The parent creates and assigns a task.
4. The child logs in and completes the task.
5. The parent reviews the submitted task.
6. The parent approves it or returns it for another attempt.
7. Noor Points are updated when appropriate.
8. The user interface refreshes and displays the latest data.

---

## Deployment Results

| Component | Technology or Platform |
|---|---|
| Frontend | Flutter Web deployed through Firebase Hosting |
| Backend | Python Flask REST API deployed through Render |
| Database | PostgreSQL hosted through Supabase |
| Source Control | Git and GitHub |

The deployed environment was checked for the following workflows:

- Parent registration and login.
- Child creation and management.
- Child login.
- Task creation and assignment.
- Task-completion submission.
- Parent approval or return for another attempt.
- Noor Points updates.
- Wishlist management.
- Weekly reward management.

---

## Technical Stack Delivered

| Layer | Technology | Purpose |
|---|---|---|
| Frontend | Flutter Web and Dart | Build the parent and child user interfaces |
| UI Framework | Flutter Material | Create screens, forms, navigation, and reusable components |
| State Management | Provider-based controllers | Manage frontend state and coordinate user actions |
| API Client | Dio | Send authenticated requests and inspect request and response logs |
| Backend | Python Flask | Implement REST APIs and business logic |
| API Structure | Flask-RESTX | Organize API namespaces, resources, and documentation |
| ORM | Flask-SQLAlchemy | Define models and manage database operations |
| Database | PostgreSQL | Store users, children, tasks, assignments, points, wishlists, and rewards |
| Production Database | Supabase | Host the PostgreSQL database |
| Authentication | JWT-based authentication | Protect parent and child workflows |
| Frontend Hosting | Firebase Hosting | Deploy the Flutter Web application |
| Backend Hosting | Render | Deploy the Flask REST API |
| API Testing | Swagger | Verify endpoints, payloads, validation, and response codes |
| Frontend Testing | Flutter Test | Test widget rendering, interactions, validation, navigation, and state updates |
| Version Control | Git and GitHub | Manage branches, commits, pull requests, reviews, and collaboration |
| Documentation | Markdown and technical diagrams | Record planning, architecture, testing, and project closure |

---

## Deferred Enhancements

The following ideas were intentionally kept outside the final MVP or identified for future development:

- Arabic and English language switching.
- A visual progress-star growth system.
- Emoji-based feedback.
- A full analytics dashboard.
- Achievement badges.
- Streaks and levels.
- Family challenges.
- AI-based task suggestions.
- School and educational partnerships.
- Bank, wallet, or savings-account integrations.
- Real-money transactions or payment gateways.
- More advanced accessibility improvements.
- Additional responsive-design optimization.
- Additional performance optimization.

Keeping these features outside the MVP allowed the team to prioritize the complete parent-child task, points, wishlist, and reward workflows.

---

## Final Results Summary

The Asalah team successfully transformed the original project concept into a functional, tested, and deployed full-stack MVP.

The application demonstrates the project's main purpose by enabling parents to teach children responsibility, positive habits, and introductory financial awareness through meaningful tasks, Noor Points, wishlist goals, and controlled rewards.

The final solution includes:

- A working parent experience.
- A working child experience.
- Secure authentication.
- Connected frontend and backend systems.
- Persistent database storage.
- Tested task and approval workflows.
- A non-monetary points system.
- Wishlist and reward features.
- Cloud deployment.
- Technical and project documentation.
- A public landing page.
- A final presentation.
- A demonstration video.

The project met the core objectives defined for the MVP while keeping larger optional enhancements available for future development.
