# WalletFlow

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?style=flat&logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-bluegrey" alt="Platform">
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License">
</p>

A comprehensive personal finance management app for tracking expenses, managing budgets, monitoring accounts, and handling loans with offline-first architecture and cloud sync capability.

## Features

- **Multi-Account Management** - Support for cash, bank accounts, mobile financial services (MFS), and credit cards
- **Transaction Tracking** - Record income, expenses, and transfers with categorized entries
- **Budget Planning** - Create and track monthly budgets with spending limits
- **Loan Management** - Track loans with payment schedules and repayment history
- **Financial Reports** - Visual analytics with interactive charts showing spending trends
- **Data Export** - Export your financial data for external use
- **Cloud Sync** - Optional sync across devices via Supabase
- **Offline-First** - Works seamlessly without internet using local database

## Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter |
| Language | Dart |
| State Management | GetX |
| Local Database | Hive |
| Cloud Backend | Supabase |
| Authentication | Firebase Auth (Google Sign-In) |
| Charts | fl_chart |

## Screenshots

### Light Mode

| | | |
|:---:|:---:|:---:|
| <img src="assets/screenshots/ss_light (1).png" width="200"/> | <img src="assets/screenshots/ss_light (2).png" width="200"/> | <img src="assets/screenshots/ss_light (3).png" width="200"/> |
| <img src="assets/screenshots/ss_light (4).png" width="200"/> | <img src="assets/screenshots/ss_light (5).png" width="200"/> | <img src="assets/screenshots/ss_light (6).png" width="200"/> |
| <img src="assets/screenshots/ss_light (7).png" width="200"/> | <img src="assets/screenshots/ss_light (8).png" width="200"/> | <img src="assets/screenshots/ss_light (9).png" width="200"/> |

### Dark Mode

| | | |
|:---:|:---:|:---:|
| <img src="assets/screenshots/ss_dark (1).png" width="200"/> | <img src="assets/screenshots/ss_dark (2).png" width="200"/> | <img src="assets/screenshots/ss_dark (3).png" width="200"/> |
| <img src="assets/screenshots/ss_dark (4).png" width="200"/> | | |

## Getting Started

### Prerequisites

- Flutter SDK 3.x or higher
- Dart SDK 3.x or higher
- A Supabase project (for cloud sync)
- A Firebase project (for authentication)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/irfanekon04/walletflow.git
   ```

2. Navigate to the project directory:
   ```bash
   cd walletflow
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

### Building APK

```bash
flutter build apk --release
```

## Project Structure

```
lib/
├── app/                 # App configuration, routes, bindings
├── core/                # Shared utilities, widgets, services
└── features/            # Feature modules
    ├── accounts/        # Account management
    ├── auth/            # Authentication
    ├── budgets/         # Budget tracking
    ├── dashboard/       # Home dashboard
    ├── loans/           # Loan management
    ├── reports/         # Financial reports
    ├── settings/        # App settings
    ├── splash/          # Splash screen
    ├── transactions/    # Transaction management
    └── onboarding/      # First-time user experience
```

## Download

Latest APK available on [GitHub Releases](https://github.com/irfanekon04/walletflow/releases)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<p align="center">Built with ❤️ using Flutter</p>
