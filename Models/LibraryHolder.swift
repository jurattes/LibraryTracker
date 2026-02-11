//
//  LibraryHolder.swift
//  LibraryTracker
//
//  Created by Justin Pescador on 2026-02-10.
//

import Foundation
import CoreData
import Combine

class LibraryHolder: ObservableObject {
    // MARK: - UI States
    @Published var searchedText: String = ""
    @Published var selectedCategory: Category? = nil
    
    // MARK: - Data
    @Published var categories: [Category] = []
    @Published var books: [Book] = []
    @Published var members: [Member] = []
    @Published var loans: [Loan] = []
    
    // MARK: - Init
    init(_ context: NSManagedObjectContext) {
        // Seed (if necessary)
        seeding(context)
        // Refresh
        refreshLibrary(context)
    }
    
    
    // MARK: - Seeding
    private func seeding(_ context: NSManagedObjectContext) {
        let req = Category.fetchRequest()
        req.fetchLimit = 1
        let count = (try? context.count(for: req)) ?? 0
        guard count == 0 else { return }
        
        // Default categories
        let romance = Category(context: context)
        romance.id = UUID()
        romance.name = "Romance"
        
        let fantasy = Category(context: context)
        fantasy.id = UUID()
        fantasy.name = "Fantasy"
        
        let horror = Category(context: context)
        horror.id = UUID()
        horror.name = "Horror"
        
        // Default books
        let b1 = Book(context: context)
        b1.id = UUID()
        b1.title = "Heated Rivalry"
        b1.author = "Rachel Reid"
        b1.isbn = "978-1335534637"
        b1.category = romance
        b1.addedAt = Date()
        b1.isAvailable = true
        
        let b2 = Book(context: context)
        b2.id = UUID()
        b2.title = "Fifty Shades of Grey"
        b2.author = "E.L. James"
        b2.isbn = "978-0345803481"
        b2.category = romance
        b2.addedAt = Date()
        b2.isAvailable = true
        
        let b3 = Book(context: context)
        b3.id = UUID()
        b3.title = "The Witcher"
        b3.author = "Andrzej Sapkowski"
        b3.isbn = ""
        b3.category = fantasy
        b3.addedAt = Date()
        b3.isAvailable = false
        
        let b4 = Book(context: context)
        b4.id = UUID()
        b4.title = "It"
        b4.author = "Stephen King"
        b4.isbn = ""
        b4.category = horror
        b4.addedAt = Date()
        b4.isAvailable = true
        
        
        // Default users
        let justin = Member(context: context)
        justin.id = UUID()
        justin.email = "justin@example.com"
        justin.name = "Justin P."
        justin.joinedAt = Date()
        
        let derrick = Member(context: context)
        derrick.id = UUID()
        derrick.name = "Derrick M."
        derrick.email = "derrick@example.com"
        derrick.joinedAt = Date()
        
        let noah = Member(context: context)
        noah.id = UUID()
        noah.name = "Noah D."
        noah.email = "noah@example.com"
        noah.joinedAt = Date()
        
        saveContext(context)
    }
    
    
    // MARK: - Fetch Request
    func bookFetchRequest() -> NSFetchRequest<Book> {
        let request = Book.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Book.title, ascending: true),
        ]
        return request
    }
    
    func categoryFetchRequest() -> NSFetchRequest<Category> {
        let request = Category.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Category.name, ascending: true)
        ]
        return request
    }
    
    func memberFetchRequest() -> NSFetchRequest<Member> {
        let request = Member.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Member.name, ascending: true)
        ]
        return request
    }
    
    func loanFetchRequest() -> NSFetchRequest<Loan> {
        let request = Loan.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Loan.borrowedAt, ascending: false) // we want to view from opposite order
        ]
        return request
    }
    
    
    // MARK: - Fetch Methods
    func fetchBooks(_ context: NSManagedObjectContext) -> [Book] {
        do { return try context.fetch(bookFetchRequest())}
        catch { fatalError("Unresolved error: \(error)") }
    }
    
    func fetchCategories(_ context: NSManagedObjectContext) -> [Category] {
        do { return try context.fetch(categoryFetchRequest())}
        catch { fatalError("Unresolved error: \(error)") }
    }
    
    func fetchMembers(_ context: NSManagedObjectContext) -> [Member] {
        do { return try context.fetch(memberFetchRequest())}
        catch { fatalError("Unresolved error: \(error)") }
    }
    
    func fetchLoans(_ context: NSManagedObjectContext) -> [Loan] {
        do { return try context.fetch(loanFetchRequest())}
        catch { fatalError("Unresolved error: \(error)") }
    }
    
    
    // MARK: - Refresh Methods
    func refreshLibrary(_ context: NSManagedObjectContext) {
        refreshCategory(context)
        refreshBook(context)
        refreshMember(context)
        refreshLoan(context)
    }
    
    func refreshCategory(_ context: NSManagedObjectContext) {
        categories = fetchCategories(context)
    }
    
    func refreshBook(_ context: NSManagedObjectContext) {
        books = fetchBooks(context)
    }
    
    func refreshMember(_ context: NSManagedObjectContext) {
        members = fetchMembers(context)
    }
    
    func refreshLoan(_ context: NSManagedObjectContext) {
        loans = fetchLoans(context)
    }
    
    
    // MARK: - CRUD: Book
    func createBook(title: String, author: String, isbn: String?, category: Category?, _ context: NSManagedObjectContext) {
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let a = author.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty, !a.isEmpty else { return }
        
        let b = Book(context: context)
        b.id = UUID()
        b.title = t
        b.author = a
        if let isbn = isbn, !isbn.isEmpty {
            b.isbn = isbn
        } else {
            b.isbn = nil
        }
        b.addedAt = Date()
        b.isAvailable = true
        b.category = category
        saveContext(context)
    }
    
    func deleteBook(_ book: Book, _ context: NSManagedObjectContext) {
        context.delete(book)
        saveContext(context)
    }
    
    func updateBook(_ book: Book, title: String, author: String, isbn: String?, category: Category?, _ context: NSManagedObjectContext) {
        book.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        book.author = author.trimmingCharacters(in: .whitespacesAndNewlines)
        if let isbn = isbn, !isbn.isEmpty {
            book.isbn = isbn
        } else {
            book.isbn = nil
        }
        book.category = category
        saveContext(context)
    }
    
    
    // MARK: - CRUD: Category
    func createCategory(name: String, _ context: NSManagedObjectContext) {
        let n = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !n.isEmpty else { return }
        
        let c = Category(context: context)
        c.id = UUID()
        c.name = n
        saveContext(context)
    }
    
    func deleteCategory(_ category: Category, _ context: NSManagedObjectContext) {
        if selectedCategory == category { selectedCategory = nil }
        context.delete(category)
        saveContext(context)
    }
    
    
    // MARK: - CRUD: Member
    func createMember(name: String, email: String, _ context: NSManagedObjectContext) {
        let n = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let e = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !n.isEmpty, !e.isEmpty else { return }
        
        let m = Member(context: context)
        m.id = UUID()
        m.name = n
        m.email = e
        m.joinedAt = Date()
        saveContext(context)
    }
    
    func deleteMember(_ member: Member, _ context: NSManagedObjectContext) {
        context.delete(member)
        saveContext(context)
    }
    
    
    // MARK: - CRUD: Loans
    func borrowBook(book: Book, member: Member, dueDays: Int, _ context: NSManagedObjectContext) {
        guard book.isAvailable else { return }
        
        let l = Loan(context: context)
        l.id = UUID()
        l.book = book
        l.member = member
        l.borrowedAt = Date()
        l.dueAt = Calendar.current.date(byAdding: .day, value: dueDays, to: Date())
        l.returnedAt = nil
        book.isAvailable = false
        saveContext(context)
    }
    
    func returnBook(loan: Loan, _ context: NSManagedObjectContext) {
        loan.returnedAt = Date()
        loan.book?.isAvailable = true
        saveContext(context)
    }
    
    
    // MARK: - Loan Helper Methods
    func isOverdue(_ loan: Loan) -> Bool {
        guard loan.returnedAt == nil else { return false }
        return loan.dueAt ?? Date() < Date()
    }
    
    func loanStatus(_ loan: Loan) -> String {
        if loan.returnedAt != nil {
            return "Returned"
        } else if isOverdue(loan) {
            return "Overdue"
        } else {
            return "Active"
        }
    }
    
    func checkActiveLoans(_ member: Member) -> [Loan] {
        return loans.filter { $0.member == member && $0.returnedAt == nil }
    }
    
    func checkPastLoans(_ member: Member) -> [Loan] {
        return loans.filter { $0.member == member && $0.returnedAt != nil }
    }
    
    
    // MARK: - Setters
    func setCategory(_ category: Category?, _ context: NSManagedObjectContext) {
        selectedCategory = category
        refreshLibrary(context)
    }
    
    func setSearchText(_ text: String, _ context: NSManagedObjectContext) {
        self.searchedText = text
        refreshBook(context)
    }
    
    func setStatus(_ loan: Loan, _ context: NSManagedObjectContext) {
        if loan.returnedAt != nil { loan.status = "Returned" }
        else { loan.status = "Borrowed" }
        saveContext(context)
    }
    
    func activeLoans(_ member: Member) -> [Loan] {
        return loans.filter { $0.member == member && $0.returnedAt == nil }
    }
    
    
    // MARK: - Data Filtering (for search)
    var filteredBooks: [Book] {
        var result = books
        
        // Category filtering
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        // Search filtering
        if !searchedText.isEmpty {
            result = result.filter {
                $0.title?.localizedCaseInsensitiveContains(searchedText) ?? false ||
                $0.author?.localizedCaseInsensitiveContains(searchedText) ?? false
            }
        }
        return result
    }
    
    
    // MARK: - Other Methods
    func saveContext(_ context: NSManagedObjectContext) {
        do {
            try context.save()
            // Refresh context
            refreshLibrary(context)
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            fatalError("Unresolved error \(error)")
        }
    }
}
