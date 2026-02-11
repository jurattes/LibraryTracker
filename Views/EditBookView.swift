//
//  EditBookView.swift
//  LibraryTracker
//
//  Created by Justin Pescador on 2026-02-11.
//

import SwiftUI
import CoreData

struct EditBookView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var holder: LibraryHolder
        
    let book: Book
        
    @State private var title = ""
    @State private var author = ""
    @State private var isbn = ""
    @State private var selectedCategory: Category? = nil
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Book Information")) {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author)
                    TextField("ISBN (optional)", text: $isbn)
                }
                
                Section(header: Text("Category")) {
                    Picker("Category", selection: $selectedCategory) {
                        Text("None").tag(nil as Category?)
                        ForEach(holder.categories, id: \.id) { category in
                            Text(category.name ?? "").tag(category as Category?)
                        }
                    }
                }
                
                Section(header: Text("Status")) {
                    HStack {
                        Text("Availability")
                        Spacer()
                        Text(book.isAvailable ? "Available" : "Borrowed")
                            .foregroundColor(book.isAvailable ? .green : .red)
                    }
                }
            }
            .navigationTitle("Edit Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        holder.updateBook(
                            book,
                            title: title,
                            author: author,
                            isbn: isbn.isEmpty ? nil : isbn,
                            category: selectedCategory,
                            context)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || author.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                title = book.title ?? ""
                author = book.author ?? ""
                isbn = book.isbn ?? ""
                selectedCategory = book.category
            }
        }
    }
}

//#Preview {
//    EditBookView()
//}
