import Foundation

final class StatisticServiceImplementation {
    private let storage: UserDefaults = .standard
}

extension StatisticServiceImplementation: StatisticService {
    var gamesCount: Int {
        get {
            self.storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            self.storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    var bestGame: GameResult {
        get {
            return GameResult(
                correct: self.storage.integer(
                    forKey: Keys.bestGameСorrect.rawValue
                ),
                total: self.storage.integer(
                    forKey: Keys.bestGameTotal.rawValue
                ),
                date: self.storage.object(
                    forKey: Keys.bestGameDate.rawValue
                ) as? Date ?? Date()
            )
        }
        set {
            self.storage.set(
                newValue.correct,
                forKey: Keys.bestGameСorrect.rawValue
            )
            self.storage.set(
                newValue.total,
                forKey: Keys.bestGameTotal.rawValue
            )
            self.storage.set(
                newValue.date,
                forKey: Keys.bestGameDate.rawValue
            )
        }
    }
    var totalAccuracy: Double {
         let total = self.gamesCount * 10
         guard total > 0 else { return 0 }
         return Double(self.correct * 100) / Double(total)
     }
     func store(correct count: Int, total amount: Int) {
         self.gamesCount += 1
         self.correct += count
         let currentGame = GameResult(correct: count, total: amount, date: Date())
         if currentGame.isBetterThan(self.bestGame) {
             self.bestGame = currentGame
         }
     }
 }

 private extension StatisticServiceImplementation {
     enum Keys: String {
         case correct
         case bestGameСorrect
         case bestGameTotal
         case bestGameDate
         case gamesCount
     }
     var correct: Int {
         get {
             self.storage.integer(forKey: Keys.correct.rawValue)
         }
         set {
             self.storage.set(newValue, forKey: Keys.correct.rawValue)
         }
     }
 }
