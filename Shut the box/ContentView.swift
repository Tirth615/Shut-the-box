import SwiftUI

struct GameRecord: Identifiable {
    let id = UUID()
    let points: Int
    let status: String // "Won" or "Lost"
}

struct ShutTheBoxGame: View {
    @State private var numbers = Array(1...12) // Numbers on the board
    @State private var selectedNumbers: [Int] = [] // Numbers chosen by the player
    @State private var diceRoll = 0
    @State private var message = ""
    @State private var points = 0 // Player points
    @State private var gameHistory: [GameRecord] = [] // Track previous games
    
    var body: some View {
        VStack {
            Text("Shut the Box")
                .font(.largeTitle)
                .bold()
                .padding()
            
            // Numbers on the board
            HStack {
                ForEach(numbers, id: \.self) { number in
                    Button(action: {
                        if selectedNumbers.contains(number) {
                            // Unmark the number
                            selectedNumbers.removeAll(where: { $0 == number })
                        } else if diceRoll > 0 && selectedNumbers.reduce(0, +) + number <= diceRoll {
                            // Mark the number if the sum doesn't exceed the dice roll
                            selectedNumbers.append(number)
                        } else {
                            message = "Invalid selection!"
                        }
                    }) {
                        Text("\(number)")
                            .font(.title)
                            .bold()
                            .frame(width: 40, height: 40)
                            .background(selectedNumbers.contains(number) ? Color.gray : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(4)
                    }
                }
            }
            .padding()
            
            // Dice roll result
            Text("Dice Roll: \(diceRoll == 0 ? "Roll the dice!" : "\(diceRoll)")")
                .font(.title2)
                .padding()
            
            // Points
            Text("Points: \(points)")
                .font(.title2)
                .padding()
            
            // Confirm Selection Button
            Button(action: confirmSelection) {
                Text("Confirm Selection")
                    .font(.title2)
                    .bold()
                    .frame(width: 200, height: 50)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            // Message
            Text(message)
                .font(.headline)
                .foregroundColor(.red)
                .padding()
            
            // Game History Section
            Text("Game History")
                .font(.title2)
                .bold()
                .padding(.top)
            
            List(gameHistory) { record in
                HStack {
                    Text("Points: \(record.points)")
                    Spacer()
                    Text("Status: \(record.status)")
                        .foregroundColor(record.status == "Won" ? .green : .red)
                }
            }
            .frame(height: 200)
        }
    }
    
    private func rollDice() {
        diceRoll = Int.random(in: 2...12) // Simulate dice roll
        selectedNumbers.removeAll() // Reset selections
        message = ""
        
        // Check for valid combinations
        if !hasValidCombination(for: diceRoll) {
            // Calculate points as the sum of remaining numbers
            points = numbers.reduce(0, +)
            message = "No valid moves! Your score: \(points)"
            
            // Save the game record
            gameHistory.append(GameRecord(points: points, status: "Lost"))
            
            // Restart the game after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                restartGame()
            }
        }
    }
    
    private func confirmSelection() {
        let sum = selectedNumbers.reduce(0, +)
        if sum == diceRoll {
            numbers.removeAll(where: { selectedNumbers.contains($0) })
            selectedNumbers.removeAll()
            message = "Good job! Rolling again!"
            
            // Check if the game is over
            if numbers.isEmpty {
                message = "Congratulations! You shut the box! Restarting..."
                
                // Save the game record
                gameHistory.append(GameRecord(points: points, status: "Won"))
                
                // Restart the game after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    restartGame()
                }
            } else {
                // Automatically roll the dice for the next turn
                rollDice()
            }
        } else {
            message = "Selection does not match the dice roll!"
        }
    }
    
    private func hasValidCombination(for target: Int) -> Bool {
        // Helper function to check if any combination of numbers matches the target
        func canFormSum(_ nums: [Int], _ target: Int) -> Bool {
            if target == 0 { return true }
            if target < 0 || nums.isEmpty { return false }
            let head = nums[0]
            let tail = Array(nums.dropFirst())
            return canFormSum(tail, target - head) || canFormSum(tail, target)
        }
        return canFormSum(numbers, target)
    }
    
    private func restartGame() {
        numbers = Array(1...12) // Reset the board
        selectedNumbers.removeAll()
        diceRoll = 0
        message = "New game started! Roll the dice!"
        points = 0
    }
}

struct ContentView: View {
    var body: some View {
        ShutTheBoxGame()
    }
}

@main
struct ShutTheBoxApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
