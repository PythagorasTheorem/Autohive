# GitHub Workflow Guide for AutoHive Project

This document explains how to use Git and GitHub to manage the AutoHive Flutter project with your team.

---

## 📋 Table of Contents
1. [Initial Setup](#initial-setup)
2. [Daily Workflow](#daily-workflow)
3. [Common Git Commands](#common-git-commands)
4. [Push & Pull Process](#push--pull-process)
5. [Best Practices](#best-practices)
6. [Troubleshooting](#troubleshooting)

---

## 🚀 Initial Setup

### First Time Setup (Already Done)

```powershell
# Navigate to project
cd "C:\Users\yohan\Downloads\autohive(yohan)\autohive\autohive"

# Initialize git
git init

# Add GitHub remote
git remote add flutter https://github.com/yoyodonut/flutter.git

# Configure user (one-time)
git config --global user.email "yohan@example.com"
git config --global user.name "Yohan"
```

### For New Team Members

```powershell
# Clone the project
git clone https://github.com/yoyodonut/flutter.git

# Navigate into project
cd flutter

# Get dependencies
flutter pub get

# You're ready to go!
```

---

## 📱 Daily Workflow

### Step 1: Pull Latest Changes (Start of Day)

```powershell
cd flutter

# Fetch latest code from GitHub
git pull flutter main
```

This ensures you have the latest code from your teammates.

### Step 2: Make Changes to Code

Edit files in VS Code as needed. For example:
- Fix bugs in `lib/features/vehicles/vehicles_screen.dart`
- Add new features in `lib/features/profile/profile_screen.dart`
- Update database logic in `lib/core/db.dart`

### Step 3: Check What You Changed

```powershell
# See modified files
git status

# See what was actually changed (diff)
git diff
```

### Step 4: Stage Your Changes

```powershell
# Add all changed files
git add .

# Or add specific files
git add lib/features/vehicles/vehicles_screen.dart

# Verify staged files
git status
```

### Step 5: Commit Your Changes

```powershell
# Commit with a meaningful message
git commit -m "Add search feature to vehicles list"

# Good commit message format:
# - Start with what you did
# - Be clear and concise
# - Explain WHY if not obvious
```

### Step 6: Push to GitHub

```powershell
# Push your commits to GitHub
git push flutter main

# Or the short version (after first setup)
git push
```

### Step 7: Test on Your Phone (Optional but Recommended)

```powershell
# Rebuild and run to test your changes
flutter pub get
flutter run
```

---

## 🔧 Common Git Commands

### Check Status
```powershell
# See what files changed
git status

# See detailed changes
git diff

# See changes for specific file
git diff lib/features/vehicles/vehicles_screen.dart
```

### View History
```powershell
# See last 5 commits
git log --oneline -5

# See all commits with details
git log

# See who changed what
git blame lib/features/vehicles/vehicles_screen.dart
```

### Undo Changes
```powershell
# Undo changes to a file (before commit)
git checkout lib/features/vehicles/vehicles_screen.dart

# Undo changes to all files (before commit)
git checkout .

# Undo last commit but keep changes
git reset --soft HEAD~1

# Undo last commit and discard changes
git reset --hard HEAD~1
```

### Branching (Advanced)
```powershell
# Create new branch for a feature
git branch feature/add-notifications

# Switch to that branch
git checkout feature/add-notifications

# Push branch to GitHub
git push flutter feature/add-notifications

# Merge back to main when done
git checkout main
git merge feature/add-notifications
```

---

## 📤 Push & Pull Process

### Pulling (Getting Latest Code)

```powershell
cd flutter

# Method 1: Pull (recommended for beginners)
git pull flutter main

# Method 2: Fetch + Merge (gives you more control)
git fetch flutter
git merge flutter/main
```

**Use this when:**
- Starting your day
- Before pushing changes
- To get your teammate's updates

### Pushing (Uploading Your Code)

```powershell
# Make sure you're on main branch
git branch  # Shows current branch

# Commit your changes first
git add .
git commit -m "Your commit message"

# Push to GitHub
git push flutter main
```

**Always commit before pushing!**

### Conflict Resolution

If there's a conflict when pulling:

```powershell
# Pull will tell you about conflicts
git pull flutter main

# Open conflicting files in VS Code
# Look for markers like:
# <<<<<<< HEAD
# your code
# =======
# their code
# >>>>>>> branch-name

# Edit to keep what you want
# Then stage and commit
git add .
git commit -m "Resolved merge conflict"
git push flutter main
```

---

## ✅ Best Practices

### 1. **Commit Often, Push Daily**
```powershell
# Good: Multiple commits per feature
git commit -m "Add vehicle edit button"
git commit -m "Implement edit dialog"
git commit -m "Add image picker functionality"

# Bad: One huge commit for everything
git commit -m "Updated everything"
```

### 2. **Write Clear Commit Messages**
```
✅ GOOD:
- "Fix vehicle delete confirmation dialog not showing"
- "Add colour, fuel type, mileage fields to edit vehicle"
- "Update profile screen with logout button"

❌ BAD:
- "fix bug"
- "updates"
- "stuff"
```

### 3. **Always Pull Before Pushing**
```powershell
git pull flutter main  # Get latest
git add .
git commit -m "Your message"
git push flutter main  # Push your changes
```

### 4. **Don't Push Sensitive Info**
Already handled with `.gitignore`, but avoid:
- API keys
- Passwords
- Personal tokens

### 5. **Test Before Pushing**
```powershell
flutter pub get
flutter run
# Test your changes on device
# Then push
git push flutter main
```

---

## 🐛 Troubleshooting

### "error: failed to push some refs to origin"

**Cause:** Your local branch is behind the remote branch.

**Solution:**
```powershell
git pull flutter main  # Get latest first
git push flutter main  # Then push
```

### "fatal: not a git repository"

**Cause:** You're not in the git project folder.

**Solution:**
```powershell
cd flutter  # Navigate to project folder
git status  # Should work now
```

### "Your branch is ahead of 'flutter/main' by 3 commits"

**This is normal!** Just push your commits:
```powershell
git push flutter main
```

### "Please commit your changes before switching branches"

**Cause:** You have uncommitted changes.

**Solution:**
```powershell
git add .
git commit -m "Work in progress"
git checkout branch-name
```

### Accidentally Made Changes to Wrong Branch

```powershell
# Save your work
git stash

# Go to correct branch
git checkout main

# Restore your work
git stash pop
```

---

## 📞 Team Collaboration Example

### Scenario: Two Team Members Working Together

**Person A (You):**
```powershell
# Morning: Pull latest
git pull flutter main

# Make changes to profile screen
# ... edit files ...

# Commit and push
git add .
git commit -m "Add logout functionality to profile"
git push flutter main
```

**Person B (Your Friend):**
```powershell
# Morning: Pull latest
git pull flutter main

# Make changes to vehicles screen
# ... edit files ...

# Commit and push
git add .
git commit -m "Add vehicle search feature"
git push flutter main
```

**Later - Person A Pulls Person B's Changes:**
```powershell
git pull flutter main

# Now both features are available locally!
```

---

## 📊 Quick Reference

| Task | Command |
|------|---------|
| Check changes | `git status` |
| Stage changes | `git add .` |
| Commit changes | `git commit -m "message"` |
| Push to GitHub | `git push flutter main` |
| Pull from GitHub | `git pull flutter main` |
| View history | `git log --oneline` |
| Undo last commit | `git reset --soft HEAD~1` |
| Create branch | `git branch feature-name` |
| Switch branch | `git checkout branch-name` |
| Merge branch | `git merge branch-name` |

---

## 🎯 Daily Checklist

Before leaving for the day:

- [ ] `git pull flutter main` - Get latest
- [ ] Make your code changes
- [ ] `git status` - Review what changed
- [ ] `flutter run` - Test on device
- [ ] `git add .` - Stage changes
- [ ] `git commit -m "Clear message"` - Commit
- [ ] `git push flutter main` - Push to GitHub

---

## 📚 Additional Resources

- **GitHub Docs:** https://docs.github.com
- **Git Cheat Sheet:** https://git-scm.com/docs
- **Interactive Git Learning:** https://learngitbranching.js.org/

---

## ❓ Questions?

If you're unsure about a command:
```powershell
git help command-name

# Example
git help pull
git help commit
```

Or check git status - it often suggests the next steps!

---

**Last Updated:** February 1, 2026
**Project:** AutoHive Flutter
**Repository:** https://github.com/yoyodonut/flutter.git
