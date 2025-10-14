# SmartPOS Desktop 🏪

[![Flutter Version](https://img.shields.io/badge/Flutter-3.10+-blue.svg)](https://flutter.dev/)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)](https://flutter.dev/desktop)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Development Status](https://img.shields.io/badge/Status-Under%20Development-yellow.svg)]()

**A Modern Flutter Desktop Point-of-Sale System for Small Retail Businesses**

SmartPOS Desktop is a comprehensive, offline-capable point-of-sale application built with Flutter for Windows, macOS, and Linux. Designed specifically for small retail stores, grocery shops, and local cafes that need a reliable, user-friendly POS solution without dependence on internet connectivity or subscription services.

![SmartPOS Dashboard](https://via.placeholder.com/800x400/2196F3/FFFFFF?text=SmartPOS+Dashboard+Preview)

## ✨ Features

### 🔐 **Authentication & User Management**
- Role-based authentication (Admin/Cashier)
- Secure session management with automatic timeout
- User activity logging and audit trails

### 🛒 **Point of Sale**
- Fast checkout with barcode scanning support
- Product search and selection
- Real-time cart management
- Multiple payment methods (Cash, Card, Digital)
- Discount application (percentage & fixed amount)
- Receipt generation and printing

### 📦 **Inventory Management**
- Real-time stock tracking
- Low stock alerts and notifications
- Product categorization and search
- Bulk inventory updates
- Cost and profit margin tracking

### 👥 **Customer Management**
- Customer database with contact information
- Purchase history tracking
- Loyalty points system
- Customer analytics and insights

### 📊 **Reports & Analytics**
- Interactive dashboard with key metrics
- Daily, weekly, and monthly sales reports
- Product performance analytics
- Visual charts and graphs with FL Chart
- Export capabilities (CSV, PDF)

### 🖥️ **Desktop Optimized**
- Native desktop performance
- Offline-first operation
- Local SQLite database
- Material 3 modern UI design
- Responsive layout with sidebar navigation

## 🛠️ Tech Stack

- **Framework**: [Flutter 3.10+](https://flutter.dev/) for cross-platform desktop development
- **Database**: [SQLite](https://www.sqlite.org/) with [sqflite](https://pub.dev/packages/sqflite) for local data storage
- **State Management**: [Provider](https://pub.dev/packages/provider) for reactive state management
- **UI Design**: [Material 3](https://m3.material.io/) design system for modern, consistent UI
- **Charts**: [FL Chart](https://pub.dev/packages/fl_chart) for interactive data visualization
- **PDF Generation**: [pdf](https://pub.dev/packages/pdf) & [printing](https://pub.dev/packages/printing) for receipts and reports
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router) for declarative routing
- **Architecture**: Clean Architecture with feature-first approach

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: 3.10 or later
- **Dart SDK**: 3.0 or later
- **Desktop Development**: Enabled for your target platform(s)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/smartpos-desktop.git
   cd smartpos-desktop
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Enable desktop support** (if not already enabled)
   ```bash
   flutter config --enable-windows-desktop
   flutter config --enable-macos-desktop
   flutter config --enable-linux-desktop
   ```

4. **Run the application**
   ```bash
   # For Windows
   flutter run -d windows
   
   # For macOS
   flutter run -d macos
   
   # For Linux
   flutter run -d linux
   ```

### 🔑 Demo Credentials

Use these credentials to test the application:

- **Admin Account**
   - Email: `admin@smartpos.com`
   - Password: `password`
   - Access: All modules and administrative functions

- **Cashier Account**
   - Email: `cashier@smartpos.com`
   - Password: `password`
   - Access: Sales, limited product and customer management

## 📁 Project Structure

```
lib/
├── main.dart                          # Application entry point
├── core/                              # Core utilities and constants
│   ├── constants/                     # App constants (colors, strings, database)
│   ├── database/                      # Database helper and table schemas
│   └── widgets/                       # Reusable widgets
├── features/                          # Feature modules (Clean Architecture)
│   ├── auth/                         # Authentication module
│   ├── dashboard/                    # Dashboard and analytics
│   ├── products/                     # Product & inventory management
│   ├── sales/                        # POS and sales processing
│   ├── customers/                    # Customer management
│   └── reports/                      # Reports and analytics
└── shared/                           # Shared components
    ├── navigation/                   # App routing
    └── widgets/                      # Layout widgets (sidebar, main layout)
```

Each feature follows Clean Architecture principles:
```
feature/
├── data/
│   ├── models/                       # Data models
│   └── repositories/                 # Repository implementations
├── domain/
│   ├── entities/                     # Business entities
│   └── repositories/                 # Repository interfaces
└── presentation/
    ├── providers/                    # State management (Provider)
    └── pages/                        # UI pages and widgets
```

## 🎯 Current Development Status

### ✅ **Completed Features**
- [x] Project setup and architecture
- [x] Database schema and SQLite integration
- [x] Authentication system with role-based access
- [x] Dashboard with analytics and charts
- [x] Basic POS interface with cart functionality
- [x] Product management (CRUD operations)
- [x] Customer management structure
- [x] Reports module foundation
- [x] Material 3 UI implementation
- [x] Responsive sidebar navigation

### 🚧 **In Progress**
- [ ] Advanced POS features (discounts, multiple payment methods)
- [ ] Receipt generation and printing
- [ ] Inventory management enhancements
- [ ] Customer loyalty system
- [ ] Advanced reporting features
- [ ] PDF export functionality

### 📋 **Planned Features**
- [ ] Barcode scanner integration
- [ ] Multi-language support
- [ ] Data backup and restore
- [ ] Advanced analytics and forecasting
- [ ] Plugin system for extensions
- [ ] Cloud sync capabilities (optional)

## 🤝 Contributing

We welcome contributions from the community! This project is part of an academic assignment, but we're open to suggestions and improvements.

### How to Contribute

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Commit your changes** (`git commit -m 'Add some amazing feature'`)
4. **Push to the branch** (`git push origin feature/amazing-feature`)
5. **Open a Pull Request**

### Development Guidelines

- Follow Flutter best practices and conventions
- Maintain clean architecture principles
- Write meaningful commit messages
- Test your changes thoroughly
- Update documentation as needed

## 🐛 Known Issues

- [ ] Sidebar navigation overflow on smaller screens (fix in progress)
- [ ] Asset directory warnings during development
- [ ] Linux desktop portal warnings (cosmetic, doesn't affect functionality)

## 📊 Performance Targets

Based on HCI requirements analysis:

- **Transaction Speed**: < 60 seconds for standard checkout
- **System Response**: < 2 seconds for all operations
- **Database Queries**: < 1 second for product searches
- **Throughput**: 200+ transactions per hour per terminal
- **Error Rate**: < 2% for transactions
- **User Training**: < 2 hours for basic proficiency

## 🎓 Academic Project Information

**Course**: Human Computer Interaction (BSCS 5-1)  
**Institution**: Riphah International University  
**Supervisor**: Mr. Hameed Ali  
**Semester**: Fall 2025

## 🔧 System Requirements

### Minimum Requirements
- **OS**: Windows 10, macOS 10.14, or Ubuntu 18.04+
- **RAM**: 4GB
- **Storage**: 2GB free space
- **Display**: 1024x768 resolution

### Recommended Requirements
- **OS**: Windows 11, macOS 12+, or Ubuntu 20.04+
- **RAM**: 8GB
- **Storage**: 5GB free space
- **Display**: 1920x1080 resolution
- **Hardware**: Barcode scanner, receipt printer (optional)

## 📞 Support

For support, questions, or feedback:

- **Email**: kazmijaffar890@gmail.com

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Mr. Hameed Ali** - Project supervisor and guidance
- **Flutter Team** - For the amazing cross-platform framework
- **Material Design Team** - For the beautiful design system
- **Open Source Community** - For the libraries and tools that made this possible

---

<div align="center">

**⭐ If you find this project useful, please consider giving it a star!**

Made with ❤️ by the SmartPOS Team at Riphah International University

</div>