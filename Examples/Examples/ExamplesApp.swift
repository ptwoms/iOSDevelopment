//
//  ExamplesApp.swift
//  Examples
//
//  Created by Pyae Phyo Myint Soe on 15/1/25.
//

import SwiftUI

@main
struct ExamplesApp: App {

    @UIApplicationDelegateAdaptor(PMAppDelegate.self) private var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
