# Intune Disk Space Monitoring & Remediation

A pair of PowerShell scripts designed for Microsoft Intune remediation that monitors local disk space and notifies users with adaptive toast notifications based on their Windows theme preference.

## 📋 Overview

This solution consists of two scripts:
- **Detection.ps1** - Monitors C: drive free space and triggers remediation when below threshold
- **RemediationLightAndDark.ps1** - Displays themed toast notification to users with disk space warning

## 🎯 Features

- **Automatic disk space detection** with configurable threshold (default: 20GB)
- **Theme-aware notifications** - Automatically selects appropriate logo based on user's Windows theme (Light/Dark mode)
- **Localized messaging** - Supports multi-language notification content
- **Graceful error handling** - Falls back to light theme image if registry detection fails
- **Non-intrusive reminders** - Uses Windows toast notifications instead of blocking popups

## 📁 Script Details

### Detection.ps1

**Purpose:** Runs as Intune detection script to identify devices with low disk space.

**Logic:**
1. Queries C: drive volume information
2. Calculates free space and percentage used
3. Returns exit code 1 if free space ≤ 20GB (triggers remediation)
4. Returns exit code 0 if disk space is adequate

**Threshold:** Configurable on line 28 (default: 20GB)

### RemediationLightAndDark.ps1

**Purpose:** Displays toast notification when remediation is triggered.

**Logic:**
1. Checks Windows theme registry value (`HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize`)
2. Downloads appropriate logo image from Azure Blob Storage based on theme:
   - Dark theme (AppsUseLightTheme = 0) → Dark-themed logo
   - Light theme (AppsUseLightTheme = 1) → Light-themed logo
   - Registry error/not found → Defaults to light theme logo
3. Constructs and displays toast notification with current free space
4. Notification includes dismissible action button

## ⚙️ Setup Instructions

### 1. Prepare Logo Images

Create two versions of your company logo optimized for light and dark Windows themes:
- **Dark theme logo** - Light-colored logo for dark backgrounds
- **Light theme logo** - Dark-colored logo for light backgrounds

Upload both to Azure Blob Storage and obtain public URLs.

### 2. Configure RemediationLightAndDark.ps1

Update the following placeholders with your actual values:

**Line 17:**
```powershell
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Your Company Name").Show($ToastXML)