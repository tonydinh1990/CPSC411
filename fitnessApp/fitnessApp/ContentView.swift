import SwiftUI

// MARK: - Simple models
struct Workout: Identifiable {
    let id = UUID()
    var name: String
    var sets: Int
    var reps: Int
    var caloriesBurned: Int   // 🔥 calories out
}

struct FoodEntry: Identifiable {
    let id = UUID()
    var name: String
    var calories: Int         // 🍽 calories in
}

// MARK: - Root view with tabs
struct ContentView: View {
    // 🔹 Shared data across tabs
    @State private var workouts: [Workout] = []
    @State private var foods: [FoodEntry] = []

    // 🔹 Profile info (now lives on Home)
    @State private var name = ""
    @State private var ageText = ""
    @State private var heightFeetText = ""
    @State private var heightInchesText = ""
    @State private var weightLbsText = ""

    // 🔹 Totals for Home tab
    var totalCaloriesIn: Int {
        foods.reduce(0) { $0 + $1.calories }
    }

    var totalCaloriesOut: Int {
        workouts.reduce(0) { $0 + $1.caloriesBurned }
    }

    var body: some View {
        TabView {
            // 🏠 HOME TAB
            HomeView(
                totalCaloriesIn: totalCaloriesIn,
                totalCaloriesOut: totalCaloriesOut,
                name: $name,
                ageText: $ageText,
                heightFeetText: $heightFeetText,
                heightInchesText: $heightInchesText,
                weightLbsText: $weightLbsText
            )
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            GoalsView()
                .tabItem {
                    Label("Goals", systemImage: "target")
                }

            // Workouts (shared)
            WorkoutTrackerView(workouts: $workouts)
                .tabItem {
                    Label("Workouts", systemImage: "figure.strengthtraining.traditional")
                }

            // Calories / Nutrition (shared)
            NutritionTrackerView(foods: $foods)
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

// MARK: - 🏠 Home View (Calories + Profile + BMI)
struct HomeView: View {
    // Calories
    let totalCaloriesIn: Int
    let totalCaloriesOut: Int

    // Profile bindings
    @Binding var name: String
    @Binding var ageText: String
    @Binding var heightFeetText: String
    @Binding var heightInchesText: String
    @Binding var weightLbsText: String

    // Computed numbers
    var netCalories: Int {
        totalCaloriesIn - totalCaloriesOut
    }

    private var age: Int? {
        Int(ageText)
    }

    private var heightFeet: Double? {
        Double(heightFeetText)
    }

    private var heightInches: Double? {
        Double(heightInchesText)
    }

    private var totalInches: Double? {
        guard let ft = heightFeet, let inch = heightInches else { return nil }
        let total = ft * 12.0 + inch
        return total > 0 ? total : nil
    }

    private var weightLbs: Double? {
        Double(weightLbsText)
    }

    // BMI with US formula: 703 * (lbs / in²)
    private var bmi: Double? {
        guard let w = weightLbs,
              let inches = totalInches,
              inches > 0 else { return nil }
        return 703.0 * (w / (inches * inches))
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

    private var netStatusText: String {
        if netCalories > 0 {
            return "You’re in a calorie surplus today."
        } else if netCalories < 0 {
            return "You’re in a calorie deficit today."
        } else {
            return "You’re exactly at maintenance today."
        }
    }

    var body: some View {
        NavigationView {
            Form {
                // 🔹 Calories summary
                Section(header: Text("Today’s Calories")) {
                    HStack {
                        Text("Calories In")
                        Spacer()
                        Text("\(totalCaloriesIn) kcal")
                            .font(.headline)
                    }

                    HStack {
                        Text("Calories Out")
                        Spacer()
                        Text("\(totalCaloriesOut) kcal")
                            .font(.headline)
                    }

                    Divider()

                    HStack {
                        Text("Net Calories")
                        Spacer()
                        Text("\(netCalories) kcal")
                            .font(.headline)
                            .foregroundColor(netCalories >= 0 ? .orange : .green)
                    }

                    Text(netStatusText)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                // 🔹 Profile info
                Section(header: Text("Your Info")) {
                    TextField("Name", text: $name)

                    TextField("Age (years)", text: $ageText)
                        .keyboardType(.numberPad)

                    HStack {
                        Text("Height")
                        Spacer()
                        TextField("ft", text: $heightFeetText)
                            .keyboardType(.numberPad)
                            .frame(width: 50)
                        Text("ft")
                        TextField("in", text: $heightInchesText)
                            .keyboardType(.numberPad)
                            .frame(width: 60)
                        Text("in")
                    }

                    HStack {
                        Text("Weight")
                        Spacer()
                        TextField("lbs", text: $weightLbsText)
                            .keyboardType(.decimalPad)
                            .frame(width: 80)
                        Text("lbs")
                    }
                }

                // 🔹 BMI
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

                // 🔹 Helper text
                Section {
                    Text("Log foods in the Calories tab and workouts in the Workouts tab. This Home page will update automatically.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Home")
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

// MARK: - 2. Workout Tracker (with calories out)
struct WorkoutTrackerView: View {
    @Binding var workouts: [Workout]

    @State private var workoutName = ""
    @State private var setsText = ""
    @State private var repsText = ""
    @State private var caloriesText = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Add Workout")) {
                    TextField("Workout name (e.g. Bench Press)", text: $workoutName)

                    TextField("Sets", text: $setsText)
                        .keyboardType(.numberPad)

                    TextField("Reps", text: $repsText)
                        .keyboardType(.numberPad)

                    TextField("Calories burned (kcal)", text: $caloriesText)
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
                                Text("🔥 \(workout.caloriesBurned) kcal")
                                    .font(.subheadline)
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
              let cals = Int(caloriesText),
              sets > 0, reps > 0, cals > 0 else { return false }
        return true
    }

    func addWorkout() {
        guard let sets = Int(setsText),
              let reps = Int(repsText),
              let cals = Int(caloriesText) else { return }

        let newWorkout = Workout(
            name: workoutName,
            sets: sets,
            reps: reps,
            caloriesBurned: cals
        )
        workouts.append(newWorkout)
        workoutName = ""
        setsText = ""
        repsText = ""
        caloriesText = ""
    }
}

// MARK: - 3. Calories Tracker (shared foods)
struct NutritionTrackerView: View {
    @Binding var foods: [FoodEntry]
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

                Section(header: Text("Total Calories In")) {
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
    @State private var selectedGoal = "Lose Weight"
    @State private var selectedMuscle: MuscleGroup = .biceps

    let goals = [
        "Lose Weight",
        "Gain Weight",
        "Increase Strength",
        "Gain Muscle",
        "Stay Healthy"
    ]

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
                Section(header: Text("Goal")) {
                    Picker("Goal", selection: $selectedGoal) {
                        ForEach(goals, id: \.self) { goal in
                            Text(goal)
                        }
                    }
                }

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

                Section(header: Text("Time Recommendation")) {
                    Text(currentDurationAdvice)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

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

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 15 Pro")
    }
}

