# Portfolio Project — Stage 2 Project Charter

## Project Name

**Asalah — A Gamified Value-Based Financial Literacy App**

## Introduction

This document presents the Project Charter for Stage 2 of the Portfolio Project. In Stage 1, the team formed the project group, brainstormed several MVP ideas, evaluated them, and selected **Asalah** as the final project concept.

Stage 2 focuses on formalizing the project at a high level by defining its purpose, SMART objectives, stakeholders, team roles, scope, risks, and high-level project plan. This Project Charter will serve as a reference document to guide the team during the upcoming technical documentation and MVP development stages.

---

## Task 0: Define Project Objectives

### 0.1 Project Purpose

The purpose of the Asalah project is to create a culturally aligned, gamified financial literacy platform that helps Saudi families teach children responsibility, positive values, and basic money management habits. The project is important because many children are exposed to digital consumption, online purchases, and reward-based entertainment at a young age, while parents may not always have a structured or engaging tool to teach financial responsibility at home.

Asalah aims to solve this problem by allowing parents to create meaningful tasks and reward children with virtual points called **Noor Points**. Through this points-based system, children can learn the value of earning, saving, and responsible spending in a safe, family-centered, and culturally relevant environment.

### 0.2 Project Objectives

The MVP of Asalah aims to achieve the following objectives:

1. **Enhance children’s understanding of earning, saving, and responsible spending by introducing a non-monetary points system called Noor Points within the MVP.**

2. **Support parents in teaching cultural, behavioral, and value-based habits by allowing them to create and assign structured tasks for their children.**

3. **Deliver a gamified experience that motivates children to stay engaged by allowing them to complete tasks, track their progress, earn Noor Points, and request rewards.**

---

## Task 1: Identify Stakeholders and Team Roles

### 1.1 Stakeholders

The Asalah project involves both internal and external stakeholders. Internal stakeholders are directly involved in planning, developing, testing, and documenting the MVP. External stakeholders are individuals or groups who may be affected by the project, use the platform, or provide guidance, feedback, and evaluation.

| Stakeholder Type | Stakeholder                        | Role / Interest in the Project                                                                                     |
| ---------------- | ---------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| Internal         | Project team members               | Responsible for planning, designing, developing, testing, and documenting the MVP.                                 |
| Internal         | Course instructors and supervisors | Provide project guidance, review progress, and evaluate the final deliverables.                                    |
| External         | Saudi parents                      | Primary users of the platform who create tasks, assign Noor Points, approve completed tasks, and manage rewards.   |
| External         | Children aged 6–16                 | Secondary users who complete tasks, earn Noor Points, track progress, and request rewards.                         |
| External         | Family members and close relatives | Participate in early feedback and usability evaluation to help improve the app experience.                         |
| External         | Banks and financial institutions   | Potential future partners for later versions, but not included in the MVP.                                         |
| External         | Schools and educational entities   | Potential future partners for educational programs or financial literacy initiatives, but not included in the MVP. |

### 1.2 Team Roles and Responsibilities

The team roles were assigned based on each member’s technical strengths, interests, and expected contribution to the MVP. These roles help organize responsibilities and support accountability during the project.

| Team Member      | Role                                                         | Responsibilities                                                                                                                                                                                               |
| ---------------- | ------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Mnar Alzahrani   | Backend Developer                                            | Develops backend logic, handles server-side functionality, supports API creation, and helps connect application features with the database.                                                                    |
| Manar Althqfi    | Backend Developer                                            | Supports backend development, implements server-side features, assists with API logic, and contributes to backend testing.                                                                                     |
| Mariam Backroush | Project Manager, Database Design and Management              | Coordinates project planning and progress tracking, organizes team tasks, designs and manages the database structure, and supports data storage for users, tasks, points, and rewards.                         |
| Norah Aljuhani   | Team Lead, Frontend Development and Frontend-Backend Testing | Supports team coordination and technical direction, designs and develops user-facing interfaces, supports the parent and child interface flow, and tests the connection between frontend and backend features. |

### 1.3 Collaboration Responsibilities

Although each member has a main role, the team will follow a collaborative approach throughout the project. All members are expected to participate in discussions, attend team meetings, provide feedback, update progress regularly, and support problem-solving when challenges appear.

The team will continue using WhatsApp for daily communication, Google Meet for regular meetings, and GitHub for file sharing, documentation, and version control.

---

## Task 2: Define Scope

### 2.1 Scope Overview

The scope of the Asalah MVP is to deliver the essential features needed to demonstrate the project’s main concept: helping Saudi parents teach children responsibility, positive values, and basic financial habits through tasks, Noor Points, and parent-approved rewards.

The MVP will focus on a simple parent-and-child experience. Parents will be able to create tasks, assign points, approve completed tasks, and manage rewards. Children will be able to view their tasks, complete them, earn Noor Points, track progress, and request rewards. Advanced features and external integrations will be excluded from the MVP to keep the project realistic and achievable within the project timeline.

### 2.2 In-Scope Items

The MVP will include the following core features and deliverables:

| In-Scope Item                     | Description                                                                                                        |
| --------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| Parent registration and login     | Parents can create an account and access the parent interface.                                                     |
| Child profile creation            | Parents can add and manage child profiles.                                                                         |
| Parent interface                  | Parents can create tasks, assign Noor Points, approve or reject completed tasks, and manage rewards.               |
| Child interface                   | Children can view assigned tasks, mark tasks as completed, track Noor Points, and request rewards.                 |
| Task management                   | Parents can create value-based tasks related to responsibility, culture, positive habits, and financial awareness. |
| Noor Points system                | Children earn virtual, non-monetary points after parent-approved task completion.                                  |
| Reward redemption request         | Children can request to redeem rewards, and parents can approve or reject the request.                             |
| Basic progress dashboard          | Parents and children can view simple progress information, such as completed tasks and earned points.              |
| Basic frontend-backend connection | The MVP will include basic integration between user interfaces, backend logic, and database storage.               |

### 2.3 Out-of-Scope Items

The MVP will not include the following features:

| Out-of-Scope Item                     | Reason for Exclusion                                                           |
| ------------------------------------- | ------------------------------------------------------------------------------ |
| Real-money transactions               | The MVP focuses on virtual learning points, not actual financial transfers.    |
| Banking or digital wallet integration | These features require external partnerships and higher security requirements. |
| Payment gateways                      | Payments are not needed for the first version of the app.                      |
| AI-based task suggestions             | This is an advanced feature that may be considered in future versions.         |
| Advanced analytics                    | The MVP will only include basic progress tracking.                             |
| Public social or community features   | The first version will focus on family use only.                               |
| School or institutional partnerships  | These may be explored in future expansion, but they are not part of the MVP.   |
| Features for users older than 16      | The child experience will focus on children aged 6–16.                         |

---

## Task 3: Identify Risks

### 3.1 Risk Overview

The Asalah project may face several risks during planning, design, development, testing, and documentation. These risks may be related to technical challenges, time management, team coordination, unclear requirements, user adoption, privacy, cultural sensitivity, or future scalability. Identifying these risks early helps the team prepare mitigation strategies and reduce their impact on the project.

### 3.2 Risks and Mitigation Plans

| Risk                                      | Description                                                                                                                             | Mitigation Plan                                                                                                                                         |
| ----------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Challenges with new technologies          | Some team members may face difficulty using new frameworks, tools, libraries, or development environments during the project.           | Allocate time for learning, use tutorials and official documentation, divide tasks based on strengths, and support each other during implementation.    |
| Timeline delays                           | Academic workload, technical issues, or unclear tasks may delay progress.                                                               | Create a clear timeline, divide work into weekly tasks, track progress during meetings, and prioritize MVP features first.                              |
| Uneven team commitment                    | Different levels of availability or participation may affect the team’s progress.                                                       | Assign clear responsibilities, follow up regularly, document each member’s tasks, and discuss blockers during team meetings.                            |
| Scope creep                               | The team may be tempted to add advanced features beyond the MVP, such as AI suggestions, advanced analytics, or banking integration.    | Follow the approved MVP scope, keep advanced features in the future enhancements section, and review the scope before adding any new feature.           |
| Frontend-backend integration issues       | Errors may occur when connecting the parent and child interfaces with backend APIs and database functions.                              | Define API requirements early, test integration gradually, document endpoints clearly, and communicate frequently between frontend and backend members. |
| Database design issues                    | The database structure may need changes if relationships between parents, children, tasks, points, and rewards are not planned clearly. | Design the database schema before development, review relationships as a team, and keep the structure simple for the MVP.                               |
| Unclear requirements                      | Some project details may become unclear during development, especially around user flows, task approval, and reward redemption.         | Discuss unclear points in meetings, update documentation regularly, and refer back to the Project Charter and MVP scope.                                |
| User adoption challenge                   | Parents may not use the app consistently if they feel that creating tasks or approving progress takes too much time.                    | Keep the user experience simple, reduce unnecessary steps, and design task creation and approval flows to be quick and clear.                           |
| Child engagement risk                     | Children may lose interest if the app experience feels too simple, repetitive, or not motivating enough.                                | Include basic gamification elements such as Noor Points, progress tracking, and rewards to keep the experience engaging within the MVP.                 |
| Parent-child usage imbalance              | Parents and children may not use the app equally; for example, children may complete tasks but parents may delay approvals.             | Design clear notifications or status indicators in future versions, and keep the approval process simple in the MVP.                                    |
| Privacy and child data concerns           | The app involves children’s profiles and progress information, which must be handled carefully.                                         | Collect only necessary information, avoid sensitive data, limit the MVP to family use, and design the system with basic privacy awareness.              |
| Cultural sensitivity risk                 | Faith-based, cultural, or value-based tasks must be presented respectfully and appropriately.                                           | Keep task categories general, allow parents to customize tasks, and avoid forcing specific religious or cultural actions in the app.                    |
| Reward fairness issue                     | Children may feel that rewards or Noor Points are unfair if parents assign points inconsistently.                                       | Allow parents to define point values clearly and encourage simple, transparent task rules.                                                              |
| Usability challenges for younger children | Younger users may find some screens, wording, or actions difficult to understand.                                                       | Use simple language, clear buttons, child-friendly layouts, and visual progress indicators.                                                             |
| Technical performance issues              | The app may become slow or unstable if data handling, backend logic, or database queries are not optimized.                             | Test core features regularly, keep the MVP lightweight, and avoid unnecessary complexity in the first version.                                          |
| Future scalability challenge              | If the app grows in the future, it may need stronger architecture, better security, and more advanced user management.                  | Build the MVP with a clean structure, document the system clearly, and keep future expansion in mind without overbuilding the first version.            |

### 3.3 Risk Management Approach

The team will manage risks by reviewing progress regularly, communicating issues early, and keeping the project focused on the approved MVP scope. If a risk appears during development, the team will discuss it, decide on a practical solution, and update the project documentation when needed.

---

## Task 4: Develop a High-Level Plan

### 4.1 High-Level Plan Overview

The Asalah project will be developed through five main stages. Each stage has a clear purpose and deliverable to help the team move from idea development to final project completion. This high-level plan will guide the team’s progress and help ensure that the project remains organized, realistic, and aligned with the MVP scope.

### 4.2 Project Timeline

| Stage   | Phase                       | Status    | Key Activities                                                                                                                                           | Main Deliverables                                                                             |
| ------- | --------------------------- | --------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| Stage 1 | Idea Development            | Completed | Formed the team, brainstormed ideas, evaluated possible MVP concepts, selected the final project idea, and refined the Asalah concept.                   | Stage 1 Report, selected MVP idea, initial MVP scope, idea evaluation, and initial workflows. |
| Stage 2 | Project Charter Development | Current   | Define the project purpose, SMART objectives, stakeholders, team roles, scope, risks, and high-level plan.                                               | Project Charter document.                                                                     |
| Stage 3 | Technical Documentation     | Upcoming  | Define system requirements, user stories, technical architecture, database design, API planning, and system workflows.                                   | Technical documentation, diagrams, user stories, database schema, and API plan.               |
| Stage 4 | MVP Development             | Upcoming  | Build the parent interface, child interface, backend logic, database structure, Noor Points system, task management, reward system, and basic dashboard. | Functional MVP prototype with core features.                                                  |
| Stage 5 | Project Closure             | Upcoming  | Test the MVP, fix major issues, prepare final documentation, review project outcomes, and present the final project.                                     | Final report, final presentation, tested MVP, and project closure summary.                    |

### 4.3 Key Milestones

| Milestone                         | Description                                                                                                       |
| --------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| Team and idea finalized           | The team selected Asalah as the final MVP concept after research, brainstorming, and evaluation.                  |
| Project Charter completed         | The team defines the project objectives, stakeholders, roles, scope, risks, and high-level plan.                  |
| Technical documentation completed | The team prepares the technical foundation needed before development begins.                                      |
| Core MVP features developed       | The team builds the main parent and child features, including tasks, Noor Points, rewards, and progress tracking. |
| MVP tested and refined            | The team tests the frontend, backend, database, and user flows to ensure the MVP works correctly.                 |
| Final project submitted           | The team submits the final deliverables and presents the completed project.                                       |

### 4.4 Simple Timeline

| Timeline          | Stage                                | Expected Focus                                                                    |
| ----------------- | ------------------------------------ | --------------------------------------------------------------------------------- |
| May 03 – May 16   | Stage 1: Idea Development            | Team formation, brainstorming, idea evaluation, and final MVP selection.          |
| May 17 – June 13  | Stage 2: Project Charter Development | Project purpose, objectives, stakeholders, scope, risks, and high-level planning. |
| June 14 – June 27 | Stage 3: Technical Documentation     | Requirements, user stories, diagrams, database design, and API planning.          |
| June 28 – July 25 | Stage 4: MVP Development             | Frontend, backend, database, integration, and MVP feature implementation.         |
| July 26 – July 30 | Stage 5: Project Closure             | Testing, final improvements, documentation, presentation, and submission.         |

---

## Project Charter Summary

This Project Charter defines the foundation for the Asalah MVP. It explains the project purpose, identifies the main objectives, documents stakeholders and team roles, defines what is included and excluded from the MVP, lists potential risks with mitigation plans, and provides a high-level project timeline.

Asalah was selected because it addresses a meaningful problem for Saudi families: helping children build financial awareness, responsible habits, and value-based behavior in an engaging and culturally relevant way. The MVP will focus on a parent-and-child experience using tasks, Noor Points, rewards, and simple progress tracking.

This charter will guide the team in the next stages of the project, especially during technical documentation and MVP development.

---

## Conclusion

Stage 2 helped the team turn the Asalah idea into a structured project plan. By defining the project objectives, stakeholders, roles, scope, risks, and timeline, the team now has a clearer understanding of what needs to be delivered and how the work will progress.

The next stage will focus on technical documentation, including system requirements, user stories, diagrams, database planning, API planning, and system workflows. These documents will prepare the team for building the Asalah MVP in the development stage.

