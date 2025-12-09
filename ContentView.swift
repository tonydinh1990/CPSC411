import SwiftUI

// MARK: - Simple models
struct Workout: Identifiable {
    let id = UUID()
    var name: String
    var sets: Int
    var reps: Int
}

struct FoodEntry: Identifiable {
    let id = UUID()
    var name: String
    var calories: Int
}

// MARK: - Root view with tabs
struct ContentView: View {
    var body: some View {
        TabView {
            GoalsView()
                .tabItem {
                    Label("Goals", systemImage: "target")
                }

            WorkoutTrackerView()
                .tabItem {
                    Label("Workouts", systemImage: "figure.strengthtraining.traditional")
                }

            NutritionTrackerView()
                .tabItem {
                    Label("Calories", systemImage: "fork.knife")
                }

            RecommendationsView()
                .tabItem {
                    Label("Exercises", systemImage: "dumbbell")
                }

            QuotesView()
                .tabItem {
                    Label("Quotes", systemImage: "quote.bubble")
                }
        }
    }
}

// MARK: - 1. Goals
struct GoalsView: View {
    @State private var selectedGoal = "Lose Weight"
    @State private var notes = ""

    let allGoals = [
        "Lose Weight",
        "Gain Weight",
        "Increase Strength",
        "Gain Muscle",
        "Stay Healthy",
        "Aesthetic / Look Better"
    ]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Your Main Goal")) {
                    Picker("Goal", selection: $selectedGoal) {
                        ForEach(allGoals, id: \.self) { goal in
                            Text(goal)
                        }
                        
                    }
                }
                
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
                
                Section(header: Text("Summary")) {
                    Text("Goal: \(selectedGoal)")
                    if notes.isEmpty {
                        Text("Add some notes about why this goal matters to you.")
                            .foregroundColor(.secondary)
                    } else {
                        Text("Notes: \(notes)")
                    }
                }
            }
            .padding(.horizontal, 12)
            .navigationTitle("Only You Goals")
        }
    }
}

// MARK: - 2. Workout Tracker
struct WorkoutTrackerView: View {
    @State private var workouts: [Workout] = []
    @State private var workoutName = ""
    @State private var setsText = ""
    @State private var repsText = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Add Workout")) {
                    TextField("Workout name (e.g. Bench Press)", text: $workoutName)
                    TextField("Sets", text: $setsText)
                    #if os(iOS)
                        .keyboardType(.numberPad)
                    #endif

                    TextField("Reps", text: $repsText)
                    #if os(iOS)
                        .keyboardType(.numberPad)
                    #endif


                    Button("Add Workout") {
                        addWorkout()
                    }
                    .disabled(!canAddWorkout)
                }

                Section(header: Text("Today’s Workouts")) {
                    if workouts.isEmpty {
                        Text("No workouts added yet.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(workouts) { workout in
                            VStack(alignment: .leading) {
                                Text(workout.name)
                                    .font(.headline)
                                Text("\(workout.sets) sets x \(workout.reps) reps")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            .navigationTitle("Workout Tracker")
        }
    }

    var canAddWorkout: Bool {
        guard !workoutName.isEmpty,
              let sets = Int(setsText),
              let reps = Int(repsText),
              sets > 0, reps > 0 else { return false }
        return true
    }

    func addWorkout() {
        guard let sets = Int(setsText), let reps = Int(repsText) else { return }
        let newWorkout = Workout(name: workoutName, sets: sets, reps: reps)
        workouts.append(newWorkout)
        workoutName = ""
        setsText = ""
        repsText = ""
    }
}

// MARK: - 3. Calories Tracker
struct NutritionTrackerView: View {
    @State private var foods: [FoodEntry] = []
    @State private var foodName = ""
    @State private var caloriesText = ""

    var totalCalories: Int {
        foods.reduce(0) { $0 + $1.calories }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Add Food")) {
                    TextField("Food name (e.g. Chicken, Rice)", text: $foodName)

                    TextField("Sets", text: $caloriesText)
                    #if os(iOS)
                        .keyboardType(.numberPad)
                    #endif

                    Button("Add Food") {
                        addFood()
                    }
                    .disabled(!canAddFood)
                }

                Section(header: Text("Today’s Foods")) {
                    if foods.isEmpty {
                        Text("No foods added yet.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(foods) { food in
                            HStack {
                                Text(food.name)
                                Spacer()
                                Text("\(food.calories) kcal")
                            }
                        }
                    }
                }

                Section(header: Text("Total Calories")) {
                    Text("\(totalCalories) kcal")
                        .font(.headline)
                }
            }
            .padding(.horizontal, 12)
            .navigationTitle("Calories Tracker")
        }
    }

    var canAddFood: Bool {
        guard !foodName.isEmpty,
              let cals = Int(caloriesText),
              cals > 0 else { return false }
        return true
    }

    func addFood() {
        guard let cals = Int(caloriesText) else { return }
        let newFood = FoodEntry(name: foodName, calories: cals)
        foods.append(newFood)
        foodName = ""
        caloriesText = ""
    }
}

// MARK: - 4. Recommendations
enum MuscleGroup: String, CaseIterable, Identifiable {
    case biceps = "Biceps"
    case chest = "Chest"
    case back = "Back"
    case legs = "Legs"
    case shoulders = "Shoulders"

    var id: String { rawValue }

    var exercises: [String] {
        switch self {
        case .biceps: return ["Hammer Curl", "Barbell Curl", "Dumbbell Curl"]
        case .chest: return ["Bench Press", "Push-Ups", "Incline Dumbbell Press"]
        case .back: return ["Pull-Ups", "Barbell Row", "Lat Pulldown"]
        case .legs: return ["Squats", "Lunges", "Leg Press"]
        case .shoulders: return ["Overhead Press", "Lateral Raise", "Front Raise"]
        }
    }
}

struct RecommendationsView: View {
    @State private var selectedGoal = "Increase Strength"
    @State private var selectedMuscle: MuscleGroup = .biceps

    let goals = [
        "Lose Weight",
        "Gain Weight",
        "Increase Strength",
        "Gain Muscle",
        "Stay Healthy"
    ]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal")) {
                    Picker("Goal", selection: $selectedGoal) {
                        ForEach(goals, id: \.self) { goal in
                            Text(goal)
                        }
                    }
                }

                Section(header: Text("Muscle Group")) {
                    Picker("Muscle", selection: $selectedMuscle) {
                        ForEach(MuscleGroup.allCases) { group in
                            Text(group.rawValue).tag(group)
                        }
                    }
                }

                Section(header: Text("Recommended Exercises")) {
                    ForEach(selectedMuscle.exercises, id: \.self) { ex in
                        Text(ex)
                    }
                }

                Section {
                    Text("Tip: Pick 2–3 of these exercises and focus on good form.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .navigationTitle("Recommendations")
        }
    }
}

// MARK: - 5. Quotes
struct QuotesView: View {
    @State private var selectedMood = "Tired"
    @State private var currentQuote = ""

    let moods = ["Tired", "Stressed", "Happy", "Sad", "Motivated"]

    let quotes: [String: [String]] = [
        "Tired": [
            "Small steps still move you forward.",
            "You don’t have to be perfect, just consistent."
        ],
        "Stressed": [
            "One workout at a time. One day at a time.",
            "You are stronger than you think."
        ],
        "Happy": [
            "Use this energy to chase your goals!",
            "Celebrate progress, not perfection."
        ],
        "Sad": [
            "Moving your body can help clear your mind.",
            "You’re not alone in this — keep going."
        ],
        "Motivated": [
            "Today is a great day to get better.",
            "Your future self will thank you."
        ]
    ]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("How do you feel today?")) {
                    Picker("Mood", selection: $selectedMood) {
                        ForEach(moods, id: \.self) { mood in
                            Text(mood)
                        }
                    }
                    .onChange(of: selectedMood) { _ in
                        updateQuote()
                    }
                }

                Section(header: Text("Motivational Quote")) {
                    if currentQuote.isEmpty {
                        Text("Select your mood to see a quote.")
                            .foregroundColor(.secondary)
                    } else {
                        Text("“\(currentQuote)”")
                            .font(.headline)
                            .padding(.vertical, 8)
                    }

                    Button("New Quote") {
                        updateQuote()
                    }
                }

                Section(header: Text("Privacy")) {
                    Text("Your mood and notes stay on this device only.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .navigationTitle("Motivation")
            .onAppear {
                updateQuote()
            }
        }
    }

    func updateQuote() {
        guard let options = quotes[selectedMood], !options.isEmpty else {
            currentQuote = ""
            return
        }
        currentQuote = options.randomElement() ?? ""
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

