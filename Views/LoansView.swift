//
//  LoansView.swift
//  LibraryTracker
//
//  Created by Justin Pescador on 2026-02-11.
//

import SwiftUI
import CoreData

struct LoansView: View {
    @Environment(\.managedObjectContext) private var context
        @EnvironmentObject var holder: LibraryHolder
        
        @State private var filterOption = 0 // 0-all, 1-active, 2-returned, 3-overdue
        @State private var showReturnedToast = false
        @State private var returnedBookName = ""
        
        var filteredLoans: [Loan] {
            switch filterOption {
            case 1: // Active
                return holder.loans.filter { $0.returnedAt == nil }
            case 2: // Returned
                return holder.loans.filter { $0.returnedAt != nil }
            case 3: // Overdue
                return holder.loans.filter { holder.isOverdue($0) }
            default: // All
                return holder.loans
            }
        }
    
    var body: some View {
        NavigationStack {
                VStack(spacing: 0) {
                       Picker("Filter", selection: $filterOption) {
                           Text("All").tag(0)
                           Text("Active").tag(1)
                           Text("Returned").tag(2)
                           Text("Overdue").tag(3)
                       }
                       .pickerStyle(.segmented)
                       .padding()
                       
                       if filteredLoans.isEmpty {
                           ContentUnavailableView(
                               "No loans found",
                               systemImage: "books.vertical",
                               description: Text(emptyStateMessage)
                           )
                           .padding(.top, 40)
                       } else {
                           List {
                               ForEach(filteredLoans, id: \.id) { loan in
                                   LoanCard(loan: loan, onReturned: { bookName in
                                       returnedBookName = bookName
                                       withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                           showReturnedToast = true
                                       }
                                       DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                           withAnimation(.easeOut(duration: 0.2)) {
                                               showReturnedToast = false
                                           }
                                       }
                                   })
                               }
                           }
                           .listStyle(.plain)
                       }
                   }
                   .navigationTitle("Loans")
                   .safeAreaInset(edge: .bottom) {
                       if showReturnedToast {
                           ReturnedSnackbar(text: "\(returnedBookName) returned")
                               .transition(.move(edge: .bottom).combined(with: .opacity))
                               .padding(.horizontal)
                               .padding(.bottom, 8)
                       }
                   }
                   .animation(.easeOut(duration: 0.2), value: showReturnedToast)
                   .onAppear {
                       holder.refreshLibrary(context)
                   }
               }
           }
           
           private var emptyStateMessage: String {
               if filterOption != 0 {
                   return "Nothing here!"
               }
               return "No loans yet"
           }
       }

       struct LoanCard: View {
           @Environment(\.managedObjectContext) private var context
           @EnvironmentObject var holder: LibraryHolder
           
           let loan: Loan
           var onReturned: ((String) -> Void)? = nil
           
           @State private var showingReturnAlert = false
           
           var body: some View {
               VStack(alignment: .leading, spacing: 12) {
                   // Book Title
                   HStack {
                       VStack(alignment: .leading, spacing: 4) {
                           Text(loan.book?.title ?? "Unknown Book")
                               .font(.headline)
                           Text(loan.book?.author ?? "Unknown Author")
                               .font(.subheadline)
                               .foregroundStyle(.secondary)
                       }
                       
                       Spacer()
                       
                       // Status Badge
                       Text(holder.loanStatus(loan))
                           .font(.caption)
                           .fontWeight(.semibold)
                           .padding(.horizontal, 12)
                           .padding(.vertical, 6)
                           .background(statusColor.opacity(0.2))
                           .foregroundStyle(statusColor)
                           .clipShape(RoundedRectangle(cornerRadius: 12))
                   }
                   
                   Divider()
                   
                   // Member Info
                   Label(loan.member?.name ?? "Unknown Member", systemImage: "person.circle.fill")
                       .font(.subheadline)
                       .foregroundStyle(.blue)
                   
                   // Dates
                   VStack(alignment: .leading, spacing: 6) {
                       if let borrowedAt = loan.borrowedAt {
                           Label(borrowedAt.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                               .font(.caption)
                               .foregroundStyle(.secondary)
                       }
                       
                       if let dueAt = loan.dueAt {
                           HStack(spacing: 8) {
                               Label(dueAt.formatted(date: .abbreviated, time: .omitted), systemImage: "clock")
                                   .font(.caption)
                                   .foregroundStyle(holder.isOverdue(loan) ? .red : .secondary)
                               
                               if holder.isOverdue(loan) {
                                   Image(systemName: "exclamationmark.triangle.fill")
                                       .foregroundStyle(.red)
                                       .font(.caption)
                               }
                           }
                       }
                       
                       if let returnedAt = loan.returnedAt {
                           Label(returnedAt.formatted(date: .abbreviated, time: .omitted), systemImage: "checkmark.circle.fill")
                               .font(.caption)
                               .foregroundStyle(.green)
                       }
                   }
                   
                   // Return Button (only for active loans)
                   if loan.returnedAt == nil {
                       Button(action: { showingReturnAlert = true }) {
                           Label("Return Book", systemImage: "return")
                               .frame(maxWidth: .infinity)
                       }
                       .buttonStyle(.borderedProminent)
                       .tint(.green)
                   }
               }
               .padding(12)
               .background(holder.isOverdue(loan) ? Color.red.opacity(0.05) : Color(.systemBackground))
               .clipShape(RoundedRectangle(cornerRadius: 12))
               .overlay(
                   RoundedRectangle(cornerRadius: 12)
                       .stroke(holder.isOverdue(loan) ? Color.red.opacity(0.3) : Color.clear, lineWidth: 2)
               )
               .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
               .listRowSeparator(.hidden)
               .alert("Return Book", isPresented: $showingReturnAlert) {
                   Button("Cancel", role: .cancel) { }
                   Button("Return") {
                       let bookName = loan.book?.title ?? "Book"
                       holder.returnBook(loan: loan, context)
                       onReturned?(bookName)
                   }
               } message: {
                   Text("Mark '\(loan.book?.title ?? "this book")' as returned?")
               }
           }
           
           private var statusColor: Color {
               if loan.returnedAt != nil {
                   return .green
               } else if holder.isOverdue(loan) {
                   return .red
               } else {
                   return .blue
               }
           }
       }

       // Add the return snackbar component
       struct ReturnedSnackbar: View {
           let text: String
           
           var body: some View {
               HStack(spacing: 10) {
                   Image(systemName: "checkmark.circle.fill")
                       .foregroundStyle(.green)
                   Text(text)
                       .lineLimit(1)
                   Spacer()
               }
               .font(.subheadline)
               .padding(.horizontal, 14)
               .padding(.vertical, 12)
               .background(.ultraThinMaterial)
               .clipShape(RoundedRectangle(cornerRadius: 14))
               .overlay(
                   RoundedRectangle(cornerRadius: 14)
                       .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
               )
           }
       }



//#Preview {
//    LoansView()
//}
