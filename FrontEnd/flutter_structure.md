# Asalah App Flutter Frontend Structure

This document shows the suggested Flutter frontend structure for the Asalah app.

```text
asalah_app/
│
├── lib/
│   ├── main.dart
│   ├── app.dart
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_text_styles.dart
│   │   │   └── app_spacing.dart
│   │   │
│   │   ├── theme/
│   │   │   └── app_theme.dart
│   │   │
│   │   ├── utils/
│   │   │   ├── validators.dart
│   │   │   ├── format_date.dart
│   │   │   └── calculate_progress.dart
│   │   │
│   │   └── widgets/
│   │       ├── app_button.dart
│   │       ├── app_text_field.dart
│   │       ├── app_card.dart
│   │       ├── screen_container.dart
│   │       ├── noor_points_badge.dart
│   │       └── noor_star_progress.dart
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── screens/
│   │   │   │   ├── login_screen.dart
│   │   │   │   └── register_screen.dart
│   │   │   ├── widgets/
│   │   │   └── services/
│   │   │       └── auth_service.dart
│   │   │
│   │   ├── onboarding/
│   │   │   ├── screens/
│   │   │   │   └── onboarding_screen.dart
│   │   │   └── widgets/
│   │   │
│   │   ├── parent/
│   │   │   ├── screens/
│   │   │   │   ├── parent_dashboard_screen.dart
│   │   │   │   ├── children_screen.dart
│   │   │   │   ├── add_child_screen.dart
│   │   │   │   ├── tasks_screen.dart
│   │   │   │   ├── create_task_screen.dart
│   │   │   │   ├── approvals_screen.dart
│   │   │   │   ├── rewards_screen.dart
│   │   │   │   └── create_reward_screen.dart
│   │   │   │
│   │   │   ├── widgets/
│   │   │   │   ├── child_card.dart
│   │   │   │   ├── task_form.dart
│   │   │   │   ├── reward_form.dart
│   │   │   │   └── approval_card.dart
│   │   │   │
│   │   │   └── services/
│   │   │       ├── child_service.dart
│   │   │       ├── task_service.dart
│   │   │       └── reward_service.dart
│   │   │
│   │   └── child/
│   │       ├── screens/
│   │       │   ├── child_dashboard_screen.dart
│   │       │   ├── child_tasks_screen.dart
│   │       │   ├── task_details_screen.dart
│   │       │   ├── child_rewards_screen.dart
│   │       │   ├── progress_screen.dart
│   │       │   └── child_profile_screen.dart
│   │       │
│   │       ├── widgets/
│   │       │   ├── child_task_card.dart
│   │       │   ├── child_reward_card.dart
│   │       │   ├── noor_points_card.dart
│   │       │   └── achievement_preview.dart
│   │       │
│   │       └── services/
│   │           ├── child_task_service.dart
│   │           └── child_reward_service.dart
│   │
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── child_model.dart
│   │   ├── task_model.dart
│   │   └── reward_model.dart
│   │
│   ├── data/
│   │   ├── mock_children.dart
│   │   ├── mock_tasks.dart
│   │   └── mock_rewards.dart
│   │
│   └── routes/
│       └── app_routes.dart
│
├── assets/
│   ├── images/
│   ├── icons/
│   ├── illustrations/
│   └── fonts/
│
├── pubspec.yaml
└── README.md
```

## Folder Purpose

### `lib/`

Contains the main Flutter application code.

### `main.dart`

The entry point of the Flutter app.

### `app.dart`

Contains the main app widget, theme setup, language direction, and navigation setup.

### `core/`

Contains reusable app-wide code that can be used across many features.

### `core/constants/`

Contains shared constants such as colors, text styles, and spacing.

### `core/theme/`

Contains the app theme configuration.

### `core/utils/`

Contains helper functions such as validation, date formatting, and progress calculation.

### `core/widgets/`

Contains reusable UI widgets such as buttons, text fields, cards, screen containers, and Noor Points widgets.

### `features/`

Contains the main app features, organized by user flow or role.

### `features/auth/`

Contains login and registration screens, widgets, and authentication service files.

### `features/onboarding/`

Contains the onboarding or welcome screen and its related widgets.

### `features/parent/`

Contains parent interface screens, widgets, and services.

### `features/child/`

Contains child interface screens, widgets, and services.

### `models/`

Contains Dart models that define the structure of app data such as users, children, tasks, and rewards.

### `data/`

Contains temporary mock data used before connecting the frontend to the Flask backend.

### `routes/`

Contains app route names and navigation configuration.

### `assets/`

Contains images, icons, illustrations, and fonts used in the app.

### `pubspec.yaml`

The main Flutter configuration file for dependencies, assets, fonts, and app metadata.

### `README.md`

The project documentation file.
