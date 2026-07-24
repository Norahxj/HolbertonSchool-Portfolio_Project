# Bug Tracking

## Purpose

Bug tracking was used throughout all four sprints to identify, document, prioritize, and resolve issues discovered during development. The team continuously monitored application behavior, discussed reported issues, and verified fixes before merging changes into the development branch to maintain application stability.

---

# Bug Tracking Process

## Bug Identification

Bugs were identified through several methods, including:

* Team member feedback during development.
* Manual testing of frontend and backend features.
* Reviewing backend API documentation.
* Swagger API testing.
* Pull Request reviews.
* Flutter debug logs and Dio request/response logs.

---

# Sprint 1

## Focus

Backend foundation and authentication.

### Common Issues

* Validation errors in authentication requests.
* Database model adjustments.
* API response formatting.
* Authentication endpoint verification.

### Resolution

* Updated validation rules.
* Improved API responses.
* Re-tested endpoints using Swagger before merging.

---

# Sprint 2

## Focus

Task management and frontend integration.

### Common Issues

* API request body mismatches.
* Task assignment data synchronization.
* UI validation inconsistencies.
* State management issues during API integration.

### Resolution

* Updated request models.
* Improved frontend validation.
* Verified requests using Dio logs.
* Performed integration testing after each fix.

---

# Sprint 3

## Focus

Parent approval workflow and Noor Points.

### Common Issues

* Approval status synchronization.
* Noor Points calculation.
* Expired access tokens during testing.
* Incorrect task status updates.

### Resolution

* Corrected approval workflow.
* Fixed point calculation logic.
* Re-tested authenticated endpoints with valid access tokens.
* Verified API responses through manual testing.

---

# Sprint 4

## Focus

Wishlist, Weekly Rewards, final testing, and performance improvements.

### Common Issues

* Minor UI inconsistencies.
* Wishlist validation.
* Weekly Rewards integration.
* Performance improvements before release.

### Resolution

* Fixed UI issues.
* Improved validation logic.
* Completed regression testing.
* Verified all major user workflows before deployment.

---

# Bug Resolution Workflow

Whenever a bug was discovered, the team followed the same workflow:

1. Identify the issue through testing or team feedback.
2. Review the expected behavior using the API documentation.
3. Debug the issue using Flutter logs and Dio request/response logs.
4. Implement the required fix.
5. Re-test the affected feature.
6. Review the Pull Request.
7. Merge the fix after successful verification.

---

# Verification

Every bug fix was verified before merging by:

* Manual testing.
* Swagger API testing.
* Comparing frontend behavior with backend documentation.
* Reviewing Dio request and response logs.
* Pull Request review.
* Team verification.

---

# Outcome

Continuous bug tracking throughout the four sprints significantly improved application stability and reduced integration issues between the frontend and backend. Regular debugging, API verification, validation checks, and team collaboration ensured that critical issues were resolved before the final MVP release.
