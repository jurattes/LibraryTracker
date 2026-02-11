//
//  MemberDetailView.swift
//  LibraryTracker
//
//  Created by Justin Pescador on 2026-02-11.
//

import SwiftUI
import CoreData

struct MemberDetailView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var holder: LibraryHolder
    
    let member: Member
    
    @State private var showBorrowSheet = false
    @State private var showBorrowToast = false
    @State private var borrowBookName = ""
    
    private var activeLoans: [Loan] {
           holder.loans.filter { $0.member == member && $0.returnedAt == nil }
       }
       
       private var pastLoans: [Loan] {
           holder.loans.filter { $0.member == member && $0.returnedAt != nil }
       }
    
    var body: some View {
        List {
            Section("Member Information") {
                HStack {
                    Text("Name")
                    Spacer()
                    Text(member.name ?? "")
                        .foregroundStyle(.secondary)
                }
                    
            HStack {
                Text("Email")
                Spacer()
                Text(member.email ?? "")
                    .foregroundStyle(.secondary)
            }
                    
            if let joinedAt = member.joinedAt {
                HStack {
                    Text("Member Since")
                    Spacer()
                    Text(joinedAt, style: .date)
                        .foregroundStyle(.secondary)
                    }
                }
            }
                
            Section("Active Loans (\(activeLoans.count))") {
                if activeLoans.isEmpty {
                    Text("No active loans")
                        .foregroundStyle(.secondary)
                        .italic()
                } else {
                    ForEach(activeLoans, id: \.id) {
                        loan in
                        LoanRowView(loan: loan)
                    }
                }
            }
            
            if !pastLoans.isEmpty {
                Section("Past Loans (\(pastLoans.count))") {
                    ForEach(pastLoans, id: \.id) { loan in
                        LoanRowView(loan: loan)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(member.name ?? "Member")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showBorrowSheet = true }) {
                    Label("Borrow", systemImage: "plus.circle.fill")
                }
            }
        }
        .sheet(isPresented: $showBorrowSheet) {
            BorrowBookView(member: member, onBorrowed: { bookName in
                borrowBookName = bookName
                withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                    showBorrowToast = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeOut(duration: 0.2)) {
                        showBorrowToast = false
                    }
                }
            })
        }
            .safeAreaInset(edge: .bottom) {
                if showBorrowToast {
                    BorrowedSnackbar(text: "\(borrowBookName) borrowed")
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                }
            }
            .animation(.easeOut(duration: 0.2), value: showBorrowToast)
            .onAppear {
                holder.refreshLibrary(context)
            }
        }
    }

    struct LoanRowView: View {
        @EnvironmentObject var holder: LibraryHolder
        let loan: Loan
        
        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                Text(loan.book?.title ?? "Unknown Book")
                    .font(.headline)
                
                HStack(spacing: 12) {
                    if let borrowedAt = loan.borrowedAt {
                        Label(borrowedAt.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    if let dueAt = loan.dueAt, loan.returnedAt == nil {
                        Label(dueAt.formatted(date: .abbreviated, time: .omitted), systemImage: "clock")
                            .font(.caption)
                            .foregroundStyle(holder.isOverdue(loan) ? .red : .secondary)
                    }
                }
                
                if let returnedAt = loan.returnedAt {
                    Label(returnedAt.formatted(date: .abbreviated, time: .omitted), systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
                
                Text(holder.loanStatus(loan))
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor(for: loan).opacity(0.2))
                    .foregroundStyle(statusColor(for: loan))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.vertical, 4)
        }
        
        private func statusColor(for loan: Loan) -> Color {
            if loan.returnedAt != nil {
                return .green
            } else if holder.isOverdue(loan) {
                return .red
            } else {
                return .blue
            }
        }
        
    }

struct BorrowedSnackbar: View {
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
//    MemberDetailView()
//}
