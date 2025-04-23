//
//  MintedApp.swift
//  Minted
//
//  Created by Andy Jagoe on 4/11/25.
//

import SwiftUI
import MintedUI
import Clerk

@main
struct MintedApp: App {
    @State private var clerk = Clerk.shared
    @State private var isConfigured = false
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                if !isConfigured {
                    ProgressView("Initializing...")
                        .task {
                            do {
                                try await ClerkConfig.configure()
                                isConfigured = true
                            } catch {
                                print("Failed to configure Clerk: \(error)")
                            }
                        }
                } else {
                    AuthenticationView()
                        .environment(clerk)
                }
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.systemBackground), for: .navigationBar)
            #endif
        }
    }
}
