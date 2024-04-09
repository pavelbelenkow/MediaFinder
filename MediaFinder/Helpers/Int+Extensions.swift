import Foundation

extension Int {
    
    func millisecondsToReadableString() -> String {
        let totalSeconds = self / 1000
        let seconds = totalSeconds % 60
        let minutes = (totalSeconds / 60) % 60
        let hours = totalSeconds / 3600
        
        if hours > .zero {
            if minutes > .zero {
                return String(format: "%dh %dmin", hours, minutes)
            } else {
                return String(format: "%dh", hours)
            }
        } else if minutes > .zero {
            if seconds > .zero {
                return String(format: "%dmin %ds", minutes, seconds)
            } else {
                return String(format: "%dmin", minutes)
            }
        } else {
            return String(format: "%ds", seconds)
        }
    }
}
