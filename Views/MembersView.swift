//
//  MembersView.swift
//  LibraryTracker
//
//  Created by Justin Pescador on 2026-02-11.
//

import SwiftUI

struct MembersView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var holder: LibraryHolder
    
    @State private var showAddMember: Bool = false
    
    
    var body: some View {
        NavigationStack {
            Group {
                if holder.members.isEmpty {
                    ContentUnavailableView(
                        "No members yet",
                        systemImage: "person.2.slash",
                        description: Text("Add your first member to get started")
                    )
                } else {
                    List {
                        ForEach(holder.members, id: \.id) { member in
                            NavigationLink(destination: MemberDetailView(member: member)) {
                                MemberRow(member: member)
                            }
                        }
                        .onDelete(perform: deleteMembers)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Members")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddMember = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddMember) {
                AddMemberView()
            }
            .onAppear {
                holder.refreshLibrary(context)
            }
        }
    }
        
        private func deleteMembers(at offsets: IndexSet) {
            for index in offsets {
                let member = holder.members[index]
                holder.deleteMember(member, context)
            }
        }
    }

struct MemberRow: View {
    @EnvironmentObject var holder: LibraryHolder
    let member: Member
    
    var activeLoansCount: Int {
        holder.activeLoans(member).count
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Text(String(member.name?.prefix(1) ?? "?"))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(member.name ?? "")
                    .font(.headline)
                Text(member.email ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if activeLoansCount > 0 {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(activeLoansCount)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.blue)
                        .monospacedDigit()
                    Text("active")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}



#Preview {
    MembersView()
}
