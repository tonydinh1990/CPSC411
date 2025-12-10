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

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
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
                        .keyboardType(.numberPad)

                    TextField("Reps", text: $repsText)
                        .keyboardType(.numberPad)

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

                    TextField("Calories (kcal)", text: $caloriesText)
                        .keyboardType(.numberPad)

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

// MARK: - 4. Recommendations (UPDATED)
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
    @State private var selectedGoal = "Lose Weight"
    @State private var selectedMuscle: MuscleGroup = .biceps

    let goals = [
        "Lose Weight",
        "Gain Weight",
        "Increase Strength",
        "Gain Muscle",
        "Stay Healthy"
    ]

    // 🔹 Goal-based exercises with approximate calories per minute
    let goalExercises: [String: [String]] = [
        "Lose Weight": [
            "Running (fast): ~12 calories per minute",
            "Jump rope: ~10 calories per minute",
            "Cycling (moderate): ~8 calories per minute",
            "Burpees: ~10–12 calories per minute",
            "Swimming (laps): ~9 calories per minute"
        ],
        "Gain Weight": [
            "Heavy squats (barbell)",
            "Bench press",
            "Deadlifts",
            "Rows (barbell or dumbbell)",
            "Overhead press"
        ],
        "Increase Strength": [
            "Low reps, heavy squats",
            "Deadlifts",
            "Bench press",
            "Pull-ups / weighted pull-ups",
            "Overhead press"
        ],
        "Gain Muscle": [
            "Squats (3–4 sets of 8–12 reps)",
            "Bench press (3–4 sets of 8–12 reps)",
            "Lat pulldown or pull-ups",
            "Shoulder press",
            "Leg press or lunges"
        ],
        "Stay Healthy": [
            "Brisk walking",
            "Light jogging",
            "Cycling (easy pace)",
            "Bodyweight squats",
            "Light dumbbell exercises"
        ]
    ]

    // 🔹 Goal-based time / frequency advice (the “quote” near bottom)
    let goalDurationAdvice: [String: String] = [
        "Lose Weight": "Try to exercise 30–40 minutes most days of the week to support weight loss.",
        "Gain Weight": "Focus on 30–45 minutes of strength training 3–4 days per week, with enough food to support muscle gain.",
        "Increase Strength": "Aim for 30–60 minutes of heavy strength training 3–5 days per week, with rest days in between.",
        "Gain Muscle": "Try 45–60 minutes of resistance training 3–5 days per week, focusing on progressive overload.",
        "Stay Healthy": "Move your body at least 20–30 minutes a day with light to moderate activity."
    ]

    var currentGoalExercises: [String] {
        goalExercises[selectedGoal] ?? []
    }

    var currentDurationAdvice: String {
        goalDurationAdvice[selectedGoal]
            ?? "Try to move your body regularly throughout the week."
    }

    var body: some View {
        NavigationView {
            Form {
                // Pick overall goal
                Section(header: Text("Goal")) {
                    Picker("Goal", selection: $selectedGoal) {
                        ForEach(goals, id: \.self) { goal in
                            Text(goal)
                        }
                    }
                }

                // 🔹 Exercises for that goal (includes Lose Weight with calories)
                Section(header: Text("Best Exercises for Your Goal")) {
                    if currentGoalExercises.isEmpty {
                        Text("Pick a goal to see exercise ideas.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(currentGoalExercises, id: \.self) { ex in
                            Text(ex)
                        }
                    }

                    if selectedGoal == "Lose Weight" {
                        Text("Calorie numbers are rough estimates and can change based on speed, body weight, and fitness level.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                // 🔹 Time recommendation / “quote” section
                Section(header: Text("Time Recommendation")) {
                    Text(currentDurationAdvice)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                // Still keep muscle group picker if you want more detailed ideas
                Section(header: Text("Muscle Group")) {
                    Picker("Muscle", selection: $selectedMuscle) {
                        ForEach(MuscleGroup.allCases) { group in
                            Text(group.rawValue).tag(group)
                        }
                    }
                }

                Section(header: Text("Recommended Exercises by Muscle")) {
                    ForEach(selectedMuscle.exercises, id: \.self) { ex in
                        Text(ex)
                    }
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

// MARK: - 6. Profile
struct ProfileView: View {
    @State private var name = ""
    @State private var ageText = ""
    @State private var heightCmText = ""   // height in centimeters
    @State private var weightKgText = ""   // weight in kilograms

    // Parsed values
    private var age: Int? {
        Int(ageText)
    }

    private var heightMeters: Double? {
        guard let cm = Double(heightCmText) else { return nil }
        return cm / 100.0
    }

    private var weightKg: Double? {
        Double(weightKgText)
    }

    // BMI calculation
    private var bmi: Double? {
        guard let h = heightMeters,
              let w = weightKg,
              h > 0 else { return nil }
        return w / (h * h)
    }

    private var bmiCategory: String {
        guard let b = bmi else { return "Not enough data" }
        switch b {
        case ..<18.5: return "Underweight"
        case 18.5..<25: return "Normal"
        case 25..<30: return "Overweight"
        default: return "Obese"
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Info")) {
                    TextField("Name", text: $name)

                    TextField("Age (years)", text: $ageText)
                        .keyboardType(.numberPad)
                }

                Section(header: Text("Body Stats")) {
                    TextField("Height (cm)", text: $heightCmText)
                        .keyboardType(.decimalPad)

                    TextField("Weight (kg)", text: $weightKgText)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("BMI")) {
                    if let bmiValue = bmi {
                        Text(String(format: "BMI: %.1f", bmiValue))
                            .font(.headline)
                        Text("Category: \(bmiCategory)")
                            .foregroundColor(.secondary)
                    } else {
                        Text("Enter your height and weight to see your BMI.")
                            .foregroundColor(.secondary)
                    }
                }

                Section(header: Text("Summary")) {
                    if name.isEmpty {
                        Text("Add your name and details to personalize your app.")
                            .foregroundColor(.secondary)
                    } else {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Name: \(name)")
                            if let age = age {
                                Text("Age: \(age) years")
                            }
                            if let h = heightMeters {
                                Text(String(format: "Height: %.0f cm", h * 100))
                            }
                            if let w = weightKg {
                                Text(String(format: "Weight: %.1f kg", w))
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            .navigationTitle("Profile")
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 15 Pro")
    }
}
