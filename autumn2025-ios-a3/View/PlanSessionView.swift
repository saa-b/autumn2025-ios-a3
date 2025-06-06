//
//  PlanSessionView.swift
//  autumn2025-ios-a3
//
//  Created by Saab Kovavinthaweewat on 2/5/2025.
//

import SwiftUI

struct PlanSessionView: View {
    let sessionId: UUID

    @Environment(\.presentationMode) var presentationMode

    @State private var sessionName: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var exercises: [Exercise] = []
    @State private var originalSessionName: String = ""
    @State private var originalStartDate: Date = Date()
    @State private var originalEndDate: Date = Date()
    @State private var isStartPickerVisible = false
    @State private var isEndPickerVisible = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Session Name
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Session Name")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.primary)

                        TextField("Session Name", text: $sessionName)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                    }

                    // Start Date
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Start Date")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.primary)

                        Button(action: {
                            withAnimation {
                                isStartPickerVisible.toggle()
                                isEndPickerVisible = false
                            }
                        }) {
                            HStack {
                                Text(FormatterUtil.longDateFormatter.string(from: startDate))
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "calendar")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                        }

                        if isStartPickerVisible {
                            DatePicker("Select Start Date", selection: $startDate, displayedComponents: [.date])
                                .datePickerStyle(.graphical)
                                .onChange(of: startDate) { _, newValue in
                                    startDate = newValue
                                    withAnimation {
                                        isStartPickerVisible = false
                                    }
                                }
                                .padding(.top, 5)
                        }
                    }

                    // End Date
                    VStack(alignment: .leading, spacing: 6) {
                        Text("End Date")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.primary)

                        Button(action: {
                            withAnimation {
                                isEndPickerVisible.toggle()
                                isStartPickerVisible = false
                            }
                        }) {
                            HStack {
                                Text(FormatterUtil.longDateFormatter.string(from: endDate))
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "calendar")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                        }

                        if isEndPickerVisible {
                            DatePicker("Select End Date", selection: $endDate, displayedComponents: [.date])
                                .datePickerStyle(.graphical)
                                .onChange(of: endDate) { _, newValue in
                                    endDate = newValue
                                    withAnimation {
                                        isEndPickerVisible = false
                                    }
                                }
                                .padding(.top, 5)
                        }
                    }

                    // Exercise Section (same as before)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Exercise")
                            .font(.subheadline)
                            .foregroundColor(.primary)

                        if exercises.isEmpty {
                            Text("No exercise")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .padding(.bottom, 8)
                        } else {
                            ForEach(exercises, id: \.id) { exercise in
                                GroupBox(label:
                                    Label(exercise.name, systemImage: "figure.walk")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                ) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(exercise.type == .reps ? "Reps: \(exercise.count)" : "Time: \(exercise.count)")
                                                    .font(.footnote)
                                                    .foregroundColor(.gray)

                                                Text("Sets: \(exercise.sets)")
                                                    .font(.footnote)
                                                    .foregroundColor(.gray)
                                            }

                                            Spacer()

                                            VStack(alignment: .trailing, spacing: 6) {
                                                NavigationLink(destination: PlanSessionExerciseView(sessionId: sessionId, exerciseId: exercise.id)) {
                                                    Text("View & Edit")
                                                        .font(.subheadline)
                                                        .bold()
                                                        .foregroundColor(.white)
                                                        .padding(.horizontal, 10)
                                                        .padding(.vertical, 4)
                                                        .frame(width: 110)
                                                        .background(Capsule().fill(Color.blueButton))
                                                }

                                                Button(action: {
                                                    SessionRepository().deleteExercise(sessionId: sessionId, exerciseId: exercise.id)
                                                    exercises.removeAll { $0.id == exercise.id }
                                                }) {
                                                    Text("Delete")
                                                        .font(.subheadline)
                                                        .bold()
                                                        .foregroundColor(.white)
                                                        .padding(.horizontal, 10)
                                                        .padding(.vertical, 4)
                                                        .frame(width: 110)
                                                        .background(Capsule().fill(Color.red))
                                                }
                                            }
                                        }
                                    }
                                    .padding(8)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top)
            }

            VStack {
                Divider()

                NavigationLink(destination: PlanSessionNewExerciseView(sessionId: sessionId)) {
                    Text("Create a new exercise")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.horizontal, 100)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color.blueButton))
                }
                .padding(.vertical)
            }
            .background(Color(.systemBackground))
        }
        .navigationBarItems(trailing: Button(action: {
            // Validation checks
            if sessionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                alertMessage = "Please enter a session name."
                showAlert = true
                return
            }

            if endDate < startDate {
                alertMessage = "End date cannot be before start date."
                showAlert = true
                return
            }

            if SessionRepository().hasOverlappingSession(start: startDate, end: endDate) {
                alertMessage = "This session overlaps with an existing one."
                showAlert = true
                return
            }

            // Save the session if everything is valid
            if var session = SessionRepository().getById(by: sessionId) {
                session.name = sessionName
                session.startDate = startDate
                session.endDate = endDate
                SessionRepository().update(session)
                presentationMode.wrappedValue.dismiss()
            }
        }) {
            Text("Save")
                .font(.subheadline)
                .bold()
                .foregroundColor(isSaveEnabled ? .white : .gray)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Capsule().fill(isSaveEnabled ? Color.blueButton : Color.gray.opacity(0.5)))
        })
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        }
        .onAppear {
            if let session = SessionRepository().getById(by: sessionId) {
                sessionName = session.name
                startDate = session.startDate
                endDate = session.endDate
                originalSessionName = sessionName
                originalStartDate = startDate
                originalEndDate = endDate
                exercises = session.exercises
            }
        }
    }

    private var isSaveEnabled: Bool {
        return sessionName != originalSessionName || startDate != originalStartDate || endDate != originalEndDate
    }
}

#Preview {
    ContentView(selection: .plan)
}
