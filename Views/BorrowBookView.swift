//
//  BorrowBookView.swift
//  LibraryTracker
//
//  Created by Justin Pescador on 2026-02-11.
//

import SwiftUI
import CoreData

struct BorrowBookView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var holder: LibraryHolder
    
    let member: Member
    let onBorrowed: ((String) -> Void)?
    
    @State private var selectedBook: Book?
    @State private var dueDays = 14
    
    var availableBooks: [Book] {
        holder.books.filter { $0.isAvailable }
    }
    
    var dueDate: Date? {
        Calendar.current.date(byAdding: .day, value: dueDays, to: Date())
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Member") {
                    HStack {
                        Text("Borrowing for: ")
                        Spacer()
                        Text(member.name ?? "")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("Select book") {
                    if availableBooks.isEmpty {
                        Text("No books available.")
                            .foregroundStyle(.secondary)
                            .italic()
                    } else {
                        ForEach(availableBooks, id: \.id) {
                            book in
                            Button (action: {
                                selectedBook = book
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(book.title ?? "")
                                            .font(.headline)
                                        Text(book.author ?? "")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    if selectedBook == book {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.blue)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                Section("Loan Duration") {
                    HStack {
                        Button(action: { dueDays = 7 }) {
                            Text("1 week")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(dueDays == 7 ? Color.blue.opacity(0.2) : Color.clear)
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                                            
                        Button(action: { dueDays = 14 }) {
                            Text("2 weeks")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(dueDays == 14 ? Color.blue.opacity(0.2) : Color.clear)
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                                            
                        Button(action: { dueDays = 21 }) {
                            Text("3 weeks")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(dueDays == 21 ? Color.blue.opacity(0.2) : Color.clear)
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                                            
                        Button(action: { dueDays = 30 }) {
                            Text("4 weeks")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(dueDays == 30 ? Color.blue.opacity(0.2) : Color.clear)
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                if let book = selectedBook {
                    Section("Summary") {
                        HStack {
                            Text("Book")
                            Spacer()
                            Text(book.title ?? "")
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack {
                            Text("Due Date")
                            Spacer()
                            if let dueDate {
                                Text(dueDate, style: .date)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Borrow Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Borrow") {
                        if let book = selectedBook {
                            holder.borrowBook(book: book, member: member, dueDays: dueDays, context)
                            onBorrowed?(book.title ?? "Book")
                            dismiss()
                        }
                    }
                    .disabled(selectedBook == nil)
                }
            }
        }
    }
}

//#Preview {
//    BorrowBookView()
//}
