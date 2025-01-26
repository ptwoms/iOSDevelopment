//
//  PMNotification.swift
//  PMUIKitCommon
//
//  Created by Pyae Phyo Myint Soe on 26/1/25.
//
import Foundation

public class PMNotificationToken {
    let token: NSObjectProtocol
    let notifCenter: NotificationCenter

    init(token: NSObjectProtocol, in center: NotificationCenter) {
        self.token = token
        self.notifCenter = center
    }

    deinit {
        notifCenter.removeObserver(token)
    }
}

public extension NotificationCenter {
    func observe(
        name: Notification.Name?,
        object obj: Any?,
        queue: OperationQueue? = .main,
        using block: @escaping (Notification) -> Void) -> PMNotificationToken
    {
        let token: NSObjectProtocol = addObserver(forName: name, object: obj, queue: queue, using: block)
        return PMNotificationToken(token: token, in: self)
    }
}
