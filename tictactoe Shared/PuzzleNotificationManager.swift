//
//  PuzzleNotificationManager.swift
//  tictactoe Shared
//
//  Created by GitHub Copilot on 11/24/25.
//

import Foundation
import UserNotifications

#if os(iOS)
import UIKit
#endif

/// Manages push notifications for daily puzzle reminders.
///
/// This manager handles:
/// - Notification permission requests
/// - Daily puzzle notification scheduling
/// - Streak reminder notifications
/// - Re-engagement notifications
@MainActor
final class PuzzleNotificationManager: NSObject {
    
    // MARK: - Singleton
    
    static let shared = PuzzleNotificationManager()
    
    // MARK: - Properties
    
    /// Notification center
    private let notificationCenter = UNUserNotificationCenter.current()
    
    /// Whether notifications are authorized
    private(set) var isAuthorized = false
    
    // MARK: - Notification Identifiers
    
    private enum NotificationID {
        static let dailyPuzzle = "daily_puzzle"
        static let streakReminder = "streak_reminder"
        static let reengagement = "reengagement"
    }
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
        notificationCenter.delegate = self
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    /// Requests notification permissions from the user.
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
            
            if granted {
                print("✅ Puzzle notifications authorized")
                scheduleDailyPuzzleNotifications()
            } else {
                print("⚠️ Puzzle notifications not authorized")
            }
            
            return granted
        } catch {
            print("❌ Notification authorization error: \(error)")
            return false
        }
    }
    
    /// Checks current authorization status.
    private func checkAuthorizationStatus() {
        Task {
            let settings = await notificationCenter.notificationSettings()
            isAuthorized = settings.authorizationStatus == .authorized
        }
    }
    
    // MARK: - Daily Puzzle Notifications
    
    /// Schedules daily puzzle reminder notifications.
    ///
    /// By default, schedules notifications at 9 AM every day. Users can
    /// customize the time through their profile preferences.
    func scheduleDailyPuzzleNotifications() {
        guard isAuthorized else { return }
        
        // Cancel existing notifications
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [NotificationID.dailyPuzzle])
        
        // Get user's preferred notification time
        let profile = PuzzleManager.shared.userProfile
        let hour = profile.preferredNotificationHour
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "New Daily Puzzle! 🧩"
        content.body = "Test your skills with today's challenge"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "PUZZLE_DAILY"
        
        // Create daily trigger
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: NotificationID.dailyPuzzle,
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        notificationCenter.add(request) { error in
            if let error = error {
                print("❌ Failed to schedule daily puzzle notification: \(error)")
            } else {
                print("✅ Daily puzzle notification scheduled for \(hour):00")
            }
        }
    }
    
    /// Schedules a streak reminder notification.
    ///
    /// Sent if user hasn't completed puzzle within 24 hours to maintain streak.
    func scheduleStreakReminder() {
        guard isAuthorized else { return }
        
        // Check if user has an active streak
        let profile = PuzzleManager.shared.userProfile
        guard profile.currentStreak > 0 else { return }
        
        // Cancel existing reminder
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [NotificationID.streakReminder])
        
        // Create content
        let content = UNMutableNotificationContent()
        content.title = "Don't Break Your Streak! 🔥"
        content.body = "Your \(profile.currentStreak)-day streak is at risk. Complete today's puzzle!"
        content.sound = .default
        content.categoryIdentifier = "PUZZLE_STREAK"
        
        // Trigger in 20 hours if not completed
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 20 * 60 * 60, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: NotificationID.streakReminder,
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("❌ Failed to schedule streak reminder: \(error)")
            } else {
                print("✅ Streak reminder scheduled")
            }
        }
    }
    
    /// Schedules a re-engagement notification.
    ///
    /// Sent if user hasn't played for several days to bring them back.
    func scheduleReengagementNotification(daysInactive: Int = 3) {
        guard isAuthorized else { return }
        
        // Cancel existing re-engagement notification
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [NotificationID.reengagement])
        
        // Create content with variety
        let messages = [
            "We miss you! Try a new puzzle 🎯",
            "Ready for a challenge? 🧠",
            "Your skills are getting rusty! Come back and play 🎮",
            "New puzzles are waiting for you! 🆕"
        ]
        
        let content = UNMutableNotificationContent()
        content.title = "Come Back to Puzzle Mode!"
        content.body = messages.randomElement() ?? messages[0]
        content.sound = .default
        content.categoryIdentifier = "PUZZLE_REENGAGEMENT"
        
        // Trigger after specified days
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(daysInactive * 24 * 60 * 60),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: NotificationID.reengagement,
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("❌ Failed to schedule re-engagement notification: \(error)")
            } else {
                print("✅ Re-engagement notification scheduled for \(daysInactive) days")
            }
        }
    }
    
    // MARK: - Notification Management
    
    /// Cancels all pending puzzle notifications.
    func cancelAllNotifications() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [
            NotificationID.dailyPuzzle,
            NotificationID.streakReminder,
            NotificationID.reengagement
        ])
        print("🔕 All puzzle notifications cancelled")
    }
    
    /// Updates notification schedule when user completes daily puzzle.
    func handleDailyPuzzleCompleted() {
        // Cancel streak reminder since puzzle is complete
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [NotificationID.streakReminder])
        
        // Clear badge
        #if os(iOS)
        UIApplication.shared.applicationIconBadgeNumber = 0
        #endif
    }
    
    /// Updates notification preferences.
    func updateNotificationTime(hour: Int) {
        guard (0...23).contains(hour) else { return }
        
        // Update profile
        var profile = PuzzleManager.shared.userProfile
        profile.preferredNotificationHour = hour
        
        // Reschedule notifications
        scheduleDailyPuzzleNotifications()
    }
    
    // MARK: - Notification Actions
    
    /// Registers notification actions and categories.
    func registerNotificationActions() {
        // Action: Solve Now
        let solveAction = UNNotificationAction(
            identifier: "SOLVE_NOW",
            title: "Solve Now",
            options: .foreground
        )
        
        // Action: Remind Later
        let remindLaterAction = UNNotificationAction(
            identifier: "REMIND_LATER",
            title: "Remind Me Later",
            options: []
        )
        
        // Daily puzzle category
        let dailyCategory = UNNotificationCategory(
            identifier: "PUZZLE_DAILY",
            actions: [solveAction, remindLaterAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Streak category
        let streakCategory = UNNotificationCategory(
            identifier: "PUZZLE_STREAK",
            actions: [solveAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Re-engagement category
        let reengagementCategory = UNNotificationCategory(
            identifier: "PUZZLE_REENGAGEMENT",
            actions: [solveAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Register categories
        notificationCenter.setNotificationCategories([
            dailyCategory,
            streakCategory,
            reengagementCategory
        ])
    }
    
    // MARK: - Debug
    
    /// Prints pending notifications for debugging.
    func printPendingNotifications() {
        Task {
            let requests = await notificationCenter.pendingNotificationRequests()
            print("📋 Pending Puzzle Notifications:")
            for request in requests {
                print("  - \(request.identifier): \(request.content.title)")
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension PuzzleNotificationManager: UNUserNotificationCenterDelegate {
    
    /// Called when notification is received while app is in foreground.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is active
        completionHandler([.banner, .sound, .badge])
    }
    
    /// Called when user interacts with notification.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        Task { @MainActor in
            let identifier = response.notification.request.identifier
            let actionIdentifier = response.actionIdentifier
            
            print("📬 Notification action: \(actionIdentifier) for \(identifier)")
            
            // Handle actions
            switch actionIdentifier {
            case "SOLVE_NOW":
                // TODO: Navigate to puzzle scene
                print("User wants to solve puzzle now")
                
            case "REMIND_LATER":
                // Reschedule notification for later
                scheduleStreakReminder()
                
            case UNNotificationDefaultActionIdentifier:
                // User tapped the notification
                print("User tapped notification")
                
            default:
                break
            }
            
            completionHandler()
        }
    }
}
