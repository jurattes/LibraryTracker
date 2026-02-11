//
//  BooksView.swift
//  LibraryTracker
//
//  Created by Justin Pescador on 2026-02-11.
//

import SwiftUI
import CoreData

struct BooksView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var holder: LibraryHolder
    
    @State private var showAddBook = false
    @State private var editingBook: Book?
    @State private var searchText: String = ""
    
    private let cols = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                HStack {
                    TextField("Search by title or author..", text: $searchText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                .padding(12)
                .background(.secondary.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal)
                .onChange(of: searchText) { _,
                    newValue in
                    holder.setSearchText(newValue, context)
                }
                
                categoryBar
                
                if holder.filteredBooks.isEmpty {
                    ContentUnavailableView(
                        "No books found",
                        systemImage: "book.closed",
                        description: Text("Nothing was found. Try searching for a book or adding a new one.")
                    )
                    .padding(.top, 40)
                } else {
                    ScrollView {
                        LazyVGrid(columns: cols, spacing: 12) {
                            ForEach(holder.filteredBooks, id: \.id) {
                                book in
                                BookCard(book: book, onEdit: {
                                    editingBook = book
                                })
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                    }
                }
            }
            .navigationTitle("Books")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showAddBook = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddBook) {
                AddBookView()
            }
            .sheet(item: $editingBook) {
                book in
                EditBookView(book: book)
            }
            .onAppear {
                holder.refreshLibrary(context)
                searchText = holder.searchedText
            }
        }
    }
    
    private var categoryBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                Button {
                    holder.setCategory(nil, context)
                } label: {
                    Text("All")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            holder.selectedCategory == nil ?
                            Color.primary.opacity(0.12) : Color.clear
                        )
                        .clipShape(Capsule())
                }
                
                ForEach(holder.categories) {
                    cat in
                    Button {
                        holder.setCategory(cat, context)
                    } label: {
                        Text(cat.name ?? "Category")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                holder.selectedCategory == cat ?
                                Color.primary.opacity(0.12) : Color.clear
                            )
                            .clipShape(Capsule()
                            )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

//#Preview {
//    BooksView()
//}
