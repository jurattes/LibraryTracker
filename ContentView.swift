//
//  ContentView.swift
//  LibraryTracker
//
//  Created by Justin Pescador on 2026-02-10.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        TabView {
            BooksView()
                .tabItem {
                    Label("Books", systemImage: "book.fill")
                }
                    
            MembersView()
                .tabItem {
                    Label("Members", systemImage: "person.2.fill")
                }
                    
            LoansView()
                .tabItem {
                    Label("Loans", systemImage: "books.vertical.fill")
                }
            }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
