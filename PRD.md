# WalletFlow - Product Requirements Document (PRD)

**Version:** 1.0  
**Date:** February 28, 2026  
**Author:** WalletFlow Team  
**Status:** Final  

---

## 1. Introduction

### 1.1 Product Overview

**WalletFlow** is a personal finance management mobile application designed to help users track their expenses, manage budgets, monitor multiple financial accounts (cash, bank, mobile financial services, and credit cards), and track simple loans. The application operates on an offline-first architecture with optional cloud synchronization, providing users with a seamless experience whether they have internet connectivity or not.

### 1.2 Problem Statement

Many individuals struggle to maintain control over their personal finances due to fragmented tracking across multiple accounts and platforms. Users currently rely on disparate tools—spreadsheets for budgeting, separate apps for different account types, and manual methods for loan tracking. This fragmentation leads to incomplete financial visibility, difficulty in budgeting effectively, and challenges in understanding overall financial health.

### 1.3 Product Vision

WalletFlow aims to become the go-to personal finance companion for individuals who want simple yet powerful financial tracking without the complexity of enterprise financial tools. The vision emphasizes ease of use, offline-first functionality, and a clean interface that makes money management feel manageable and stress-free.

---

## 2. Goals and Objectives

### 2.1 Primary Goals

The primary goals of WalletFlow are:

1. **Unified Account Management**: Enable users to track all their financial accounts (cash, bank accounts, mobile financial services, and credit cards) in one unified interface, with the ability to create custom account names and types.

2. **Comprehensive Transaction Tracking**: Provide robust functionality for recording income and expenses with full categorization, date tracking, notes, and account assignment.

3. **Effective Budgeting**: Allow users to set monthly budgets per spending category and receive visual feedback on their progress, helping them stay on track with their financial goals.

4. **Simple Loan Management**: Offer straightforward tools for tracking money lent to others (borrowers) and money owed to others (lenders), with payment tracking capabilities.

5. **Reliable Data Storage**: Implement offline-first architecture using local database storage (Hive) while providing optional cloud synchronization via Supabase for data backup and cross-device access.

### 2.2 Success Metrics

- **User Retention**: 60% of registered users actively using the app after 30 days
- **Transaction Volume**: Average of 15+ transactions per user per month
- **Budget Utilization**: 50%+ of users setting at least one monthly budget
- **Cloud Adoption**: 30% of users enabling cloud sync within the first month
- **Performance**: App startup time under 2 seconds, transaction processing under 100ms

---

## 3. Target Users

### 3.1 Primary User Personas

**Persona A: The Budget-Conscious Professional**
- Age range: 25-45 years old
- Income: Middle-income earner
- Financial behavior: Tracks expenses carefully, uses budgeting techniques, maintains multiple bank accounts
- Goals: Maintain control over spending, save money, avoid debt

**Persona B: The Small Business Owner**
- Age range: 30-55 years old
- Income: Variable income, runs small business
- Financial behavior: Mixes personal and business finances, needs to track cash flow
- Goals: Track business expenses, manage cash flow, separate personal and business finances

**Persona C: The First-Time Finance Manager (Young Adult)**
- Age range: 18-24 years old
- Income: Entry-level salary or student
- Financial behavior: Learning financial management, first time tracking expenses
- Goals: Learn to budget, build good financial habits, understand spending patterns

### 3.2 Target Markets

Primary target market is English-speaking users in:
- United States
- United Kingdom
- India (English-speaking population)
- Southeast Asia (Singapore, Malaysia, Philippines)
- Other English-speaking countries

---

## 4. User Stories

### 4.1 Account Management

| ID | User Story | Priority |
|----|-------------|----------|
| AS-001 | As a user, I want to create a new account by selecting a type (cash, bank, MFS, credit card) and entering a custom name so that I can track my finances by account. | P0 - Must Have |
| AS-002 | As a user, I want to edit the name of any existing account so that I can personalize it (e.g., rename "Bank" to "Chase Checking"). | P0 - Must Have |
| AS-003 | As a user, I want to delete an account and choose whether to keep or delete its transaction history. | P0 - Must Have |
| AS-004 | As a user, I want to view all my accounts with their current balances in one screen. | P0 - Must Have |
| AS-005 | As a user, I want to see the total balance across all accounts. | P0 - Must Have |
| AS-006 | As a user, I want to set a credit limit for credit card accounts and see my available balance. | P1 - Should Have |
| AS-007 | As a user, I want to transfer money between accounts. | P0 - Must Have |

### 4.2 Transaction Management

| ID | User Story | Priority |
|----|-------------|----------|
| TM-001 | As a user, I want to add an expense by entering amount, selecting category, choosing account, and optionally adding a note. | P0 - Must Have |
| TM-002 | As a user, I want to add income by entering amount, selecting source category, choosing account, and optionally adding a note. | P0 - Must Have |
| TM-003 | As a user, I want to edit any existing transaction. | P0 - Must Have |
| TM-004 | As a user, I want to delete a transaction. | P0 - Must Have |
| TM-005 | As a user, I want to filter transactions by date range, category, account, and type. | P0 - Must Have |
| TM-006 | As a user, I want to search transactions by note content or amount. | P1 - Should Have |
| TM-007 | As a user, I want to view transactions grouped by date. | P0 - Must Have |

### 4.3 Categories

| ID | User Story | Priority |
|----|-------------|----------|
| CT-001 | As a user, I want to see default categories pre-loaded. | P0 - Must Have |
| CT-002 | As a user, I want to create custom categories with my own name, icon, and color. | P1 - Should Have |
| CT-003 | As a user, I want to edit existing categories. | P1 - Should Have |
| CT-004 | As a user, I want to delete custom categories. | P1 - Should Have |

### 4.4 Budget Management

| ID | User Story | Priority |
|----|-------------|----------|
| BM-001 | As a user, I want to set a monthly budget amount for each spending category. | P0 - Must Have |
| BM-002 | As a user, I want to see how much I've spent against each budget with a visual progress indicator. | P0 - Must Have |
| BM-003 | As a user, I want to receive an alert when I reach 80% of my budget. | P1 - Should Have |
| BM-004 | As a user, I want to receive an alert when I exceed my budget. | P1 - Should Have |
| BM-005 | As a user, I want to view past months' budgets and spending. | P1 - Should Have |
| BM-006 | As a user, I want to edit or delete existing budgets. | P0 - Must Have |

### 4.5 Loan Tracking

| ID | User Story | Priority |
|----|-------------|----------|
| LN-001 | As a user, I want to record money I've lent to someone (borrower) with their name, amount, date, and notes. | P0 - Must Have |
| LN-002 | As a user, I want to record money I owe to someone (lender) with their name, amount, date, and notes. | P0 - Must Have |
| LN-003 | As a user, I want to record partial payments against a loan. | P0 - Must Have |
| LN-004 | As a user, I want to see the remaining balance for each loan. | P0 - Must Have |
| LN-005 | As a user, I want to view a summary showing total money lent, total money owed, and net position. | P0 - Must Have |
| LN-006 | As a user, I want to mark a loan as fully repaid/completed. | P0 - Must Have |

### 4.6 Cloud Synchronization

| ID | User Story | Priority |
|----|-------------|----------|
| CS-001 | As a user, I want to create an account using email/password authentication. | P0 - Must Have |
| CS-002 | As a user, I want to sign in using my Google account. | P1 - Should Have |
| CS-003 | As a user, I want my data to automatically sync to the cloud when online. | P0 - Must Have |
| CS-004 | As a user, I want to manually trigger a sync. | P1 - Should Have |
| CS-005 | As a user, I want to see a sync status indicator. | P1 - Should Have |
| CS-006 | As a user, I want to continue using the app fully when offline. | P0 - Must Have |
| CS-007 | As a user, I want to restore my data from the cloud when switching devices. | P0 - Must Have |

---

## 5. Functional Requirements

### 5.1 Account Management Module

The account management module provides comprehensive functionality for managing multiple financial accounts.

**Account Types:**
- Cash (physical money held)
- Bank (traditional banking accounts)
- MFS (mobile financial services such as bKash, Rocket, Paytm)
- Credit Cards

**Features:**
- Create accounts with custom names
- Edit account names, types, and credit limits
- Delete accounts with option to preserve transactions
- Transfer between accounts
- View total balance across all accounts

### 5.2 Transaction Management Module

The transaction management module forms the core of expense and income tracking.

**Transaction Types:**
- Income
- Expense
- Transfer

**Features:**
- Add/edit/delete transactions
- Assign to accounts and categories
- Filter by date range, category, account, type
- Search by note or amount
- Grouped by date display
- Automatic balance updates

### 5.3 Category Management Module

**Default Expense Categories:**
- Food, Transport, Shopping, Bills, Entertainment, Health, Education, Others

**Default Income Categories:**
- Salary, Freelance, Business, Investment, Gift, Others

**Features:**
- Default categories pre-loaded
- Custom category creation with icon and color
- Edit and delete custom categories

### 5.4 Budget Management Module

**Features:**
- Monthly budgets per category
- Visual progress bars with color coding
- Alert notifications at 80% and 100% thresholds
- Budget comparison with previous months
- Edit and delete budgets

### 5.5 Loan Tracking Module

**Features:**
- Track money lent (borrowers)
- Track money owed (lenders)
- Record partial payments
- View remaining balance
- Loan summary dashboard
- Mark loans as completed

### 5.6 Cloud Synchronization Module

**Features:**
- Firebase Authentication (email/password, Google Sign-In)
- Supabase cloud database
- Offline-first approach
- Auto-sync when online
- Manual sync option
- Data restoration on new device

---

## 6. Non-Functional Requirements

### 6.1 Performance Requirements

- App launch within 2 seconds
- Transaction operations under 100ms
- Smooth rendering with 10,000+ transactions
- Memory usage under 150MB

### 6.2 Reliability Requirements

- Accurate financial calculations to two decimal places
- ACID properties for data consistency
- Crash recovery preserving all data

### 6.3 Security Requirements

- Secure credential storage
- HTTPS for all cloud communication
- Hive encryption for sensitive data
- Permanent account deletion option

### 6.4 Usability Requirements

- Maximum 5 taps for basic workflows
- Touch targets at least 48x48 dp
- Support for portrait and landscape
- Dark mode with WCAG AA compliance

### 6.5 Compatibility Requirements

- Minimum Android SDK 21 (Android 5.0)
- Target SDK 34 (Android 14)
- Support 4-inch phones to 10-inch tablets

---

## 7. UI/UX Requirements

### 7.1 Design Principles

- Material Design 3 (Material You)
- Clean, minimalist aesthetic
- Clarity, consistency, efficiency, forgiveness

### 7.2 Color Scheme

**Light Theme:**
| Color | Hex | Usage |
|-------|-----|-------|
| Primary | #2196F3 | Main actions, app bar |
| Secondary | #009688 | FAB, secondary actions |
| Income Green | #4CAF50 | Income amounts |
| Expense Red | #F44336 | Expense amounts |
| Warning Orange | #FF9800 | Budget warnings |

**Dark Theme:**
| Color | Hex | Usage |
|-------|-----|-------|
| Primary | #64B5F6 | Main actions |
| Secondary | #4DB6AC | FAB |
| Income Green | #81C784 | Income amounts |
| Expense Red | #E57373 | Expense amounts |

### 7.3 Screen Structure

```
Bottom Navigation (5 tabs):
├── Dashboard
│   ├── Total Balance Card
│   ├── Account Summary Cards
│   ├── Recent Transactions
│   ├── Budget Overview
│   └── Loan Summary
│
├── Transactions
│   ├── Filter/Search
│   ├── Transaction List
│   └── Add Transaction FAB
│
├── Budgets
│   ├── Month Selector
│   ├── Budget List
│   └── Add Budget FAB
│
├── Loans
│   ├── Tab: Lent / Owed
│   ├── Loan List
│   └── Add Loan FAB
│
└── Settings
    ├── Accounts Management
    ├── Categories
    ├── Dark Mode Toggle
    ├── Cloud Sync
    ├── Export Data
    └── About
```

---

## 8. Technical Requirements

### 8.1 Technology Stack

| Component | Technology |
|-----------|------------|
| Framework | Flutter 3.x |
| Language | Dart 3.x |
| State Management | GetX |
| Local Database | Hive |
| Cloud Database | Supabase |
| Authentication | Firebase Auth |
| Charts | fl_chart |
| Architecture | Clean Architecture (Feature-based) |

### 8.2 Project Structure

```
lib/
├── app/
│   ├── bindings/
│   ├── pages/
│   └── theme/
├── core/
│   ├── constants/
│   ├── database/
│   └── utils/
├── features/
│   ├── accounts/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── controllers/
│   │       ├── pages/
│   │       └── widgets/
│   ├── budgets/
│   ├── dashboard/
│   ├── loans/
│   ├── settings/
│   └── transactions/
└── main.dart
```

---

## 9. Data Models

### 9.1 Account

```
- id: UUID
- name: String
- type: Enum (cash, bank, mfs, creditCard)
- balance: Double
- creditLimit: Double?
- icon: String
- color: String
- createdAt: DateTime
- updatedAt: DateTime
- isSynced: Bool
- userId: String?
```

### 9.2 Transaction

```
- id: UUID
- accountId: UUID
- type: Enum (income, expense, transfer)
- amount: Double
- categoryId: UUID?
- note: String?
- date: DateTime
- toAccountId: UUID?
- createdAt: DateTime
- updatedAt: DateTime
- isSynced: Bool
- userId: String?
```

### 9.3 Category

```
- id: UUID
- name: String
- type: Enum (income, expense)
- icon: String
- color: String
- isDefault: Bool
- isHidden: Bool
- createdAt: DateTime
- userId: String?
```

### 9.4 Budget

```
- id: UUID
- categoryId: UUID
- amount: Double
- month: Int (1-12)
- year: Int
- createdAt: DateTime
- updatedAt: DateTime
- isSynced: Bool
- userId: String?
```

### 9.5 Loan

```
- id: UUID
- type: Enum (lent, owed)
- personName: String
- originalAmount: Double
- remainingAmount: Double
- date: DateTime
- note: String?
- isCompleted: Bool
- createdAt: DateTime
- updatedAt: DateTime
- isSynced: Bool
- userId: String?
```

### 9.6 LoanPayment

```
- id: UUID
- loanId: UUID
- amount: Double
- date: DateTime
- note: String?
- createdAt: DateTime
- isSynced: Bool
- userId: String?
```

---

## 10. Default Categories

### Expense Categories

| Name | Icon | Color |
|------|------|-------|
| Food | restaurant | #FF9800 |
| Transport | directions_car | #2196F3 |
| Shopping | shopping_bag | #E91E63 |
| Bills | receipt_long | #9C27B0 |
| Entertainment | movie | #00BCD4 |
| Health | medical_services | #4CAF50 |
| Education | school | #FF5722 |
| Others | more_horiz | #607D8B |

### Income Categories

| Name | Icon | Color |
|------|------|-------|
| Salary | work | #4CAF50 |
| Freelance | computer | #2196F3 |
| Business | business | #9C27B0 |
| Investment | trending_up | #00BCD4 |
| Gift | card_giftcard | #E91E63 |
| Others | more_horiz | #607D8B |

---

## 11. Future Considerations

### Phase 2 Features (Post-Launch)
- Recurring Transactions
- Receipt Scanning (OCR)
- AI Spending Insights
- Multiple Currencies
- Debt Repayment Plans
- Savings Goals

### Premium Features
- Unlimited custom categories
- Advanced analytics and reports
- Cloud sync for multiple devices
- Priority support
- Export to PDF reports
- Custom themes
- Password/biometric lock

### Platform Expansion
- iOS version
- Web dashboard
- Desktop application
- Apple Watch / Wear OS companion

---

**Document End**

*This PRD is a living document and will be updated as the project evolves.*
