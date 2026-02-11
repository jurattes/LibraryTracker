//
//  BookCard.swift
//  LibraryTracker
//
//  Created by Justin Pescador on 2026-02-11.
//

import SwiftUI

struct BookCard: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var holder: LibraryHolder
    
    let book: Book
    let onEdit: () -> Void
    
    @State private var showDelete = false
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(book.isAvailable ? Color.blue.opacity(0.12) : Color.secondary.opacity(0.12))
                    .frame(height: 110)
                Image(systemName: book.isAvailable ? "book.fill" : "book.closed.fill")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(book.isAvailable ? .blue : .secondary)
            }
            
            Text(book.title ?? "")
                .font(.headline)
                .lineLimit(2)
            Text(book.author ?? "")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            
            if let category = book.category {
                Text(category.name ?? "")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.purple.opacity(0.2))
                    .foregroundStyle(.purple)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            HStack {
                Circle()
                    .fill(book.isAvailable ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                Text(book.isAvailable ? "Available" : "Borrowed")
                    .font(.caption)
                    .foregroundStyle(book.isAvailable ? .green : .red)
            }
            
            Spacer()
            
            HStack {
                Button(action: onEdit) {
                    Text("Edit")
                        .font(.caption)
                }
                .buttonStyle(BorderlessButtonStyle())
                
                Spacer()
                
                Button(action: { showDelete = true }) {
                    Text("Delete")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .padding(12)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(.secondary.opacity(0.15), lineWidth: 1)
        )
        .alert("Delete Book", isPresented: $showDelete) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                holder.deleteBook(book, context)
            }
        } message: {
            Text("Are you sure you want to remove the book (\(book.title ?? "Unknown"))? It will remove all associated loans, previous or present.")
        }
    }
}

//#Preview {
//    BookCard()
//}
