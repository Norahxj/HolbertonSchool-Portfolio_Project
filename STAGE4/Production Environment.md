# Production Environment

## Overview

The project was developed, deployed, and tested using both local and production environments. During development, local environments were used for implementing and debugging new features, while the deployed production environment was used to validate complete application workflows before delivery.

---

# Deployment Architecture

The MVP was deployed using a cloud-based architecture to allow team members to access, test, and validate the application in a production-like environment.

| Component | Platform            |
| --------- | ------------------- |
| Frontend  | Firebase Hosting    |
| Backend   | Render              |
| Database  | Supabase PostgreSQL |

---

# Frontend

The Flutter Web application is deployed using Firebase Hosting.

**Production URL**

https://asalah-26b7d.web.app

The deployed frontend communicates directly with the production backend during integration and end-to-end testing.

---

# Backend

The backend is deployed on Render.

**Production API**

https://holbertonschool-portfolio-project-22a6.onrender.com

The production backend hosts the Flask REST API used by the Flutter application.

---

# Database

The production database is hosted on Supabase using PostgreSQL.

All application data, including users, children, tasks, task assignments, wishlists, rewards, and Noor Points, is stored in the production database.

---

# Testing Environments

Two environments were used throughout development.

## Local Environment

Used for:

* Feature development.
* UI implementation.
* Backend development.
* Debugging.
* Local API testing.
* Initial integration testing.

## Production Environment

Used for:

* Integration testing.
* End-to-end workflow verification.
* API validation against the deployed backend.
* Final testing before project submission.
* Production readiness verification.

Testing was performed using both the locally running backend and the deployed Render backend to ensure consistent behavior across development and production environments.

---

# Production Verification

The deployed application was verified by testing the following features:

* Parent registration and login.
* Child login.
* Child management.
* Task creation.
* Task assignment.
* Task completion.
* Parent approval and rejection.
* Wishlist management.
* Weekly Rewards.
* Noor Points functionality.

Successful API responses and complete workflow execution confirmed that the production environment was operating correctly.

---

# Production Readiness

Before the final project submission, the production environment was verified to ensure that:

* All backend APIs were accessible.
* The Flutter application successfully communicated with the production backend.
* Authentication and authorization functioned correctly.
* Database operations (Create, Read, Update, Delete) behaved as expected.
* End-to-end workflows completed successfully without critical issues.
* Major bugs identified during testing were resolved.

The successful verification of these checks confirmed that the MVP was ready for demonstration and deployment.

---

# Conclusion

Using separate local and production environments enabled the team to develop, test, and validate the application efficiently throughout the four development sprints. Continuous deployment and production verification ensured that the final MVP was stable, fully integrated, and ready for presentation.
