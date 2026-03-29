import SwiftUI

struct CategoryColor {
    static func color(for category: String) -> Color {
        switch category {
        case "Diocesan Events", "Campus Ministry":
            return Color(red: 221/255, green: 238/255, blue: 250/255) // #DDEEFA
        case "Home Campus":
            return Color(red: 230/255, green: 242/255, blue: 224/255) // #E6F2E0
        case "Counseling":
            return Color(red: 253/255, green: 226/255, blue: 224/255) // #FDE2E0
        case "Academics":
            return Color(red: 254/255, green: 235/255, blue: 214/255) // #FEEBD6
        case "Activities":
            return Color(red: 235/255, green: 231/255, blue: 243/255) // #EBE7F3
        case "Block Schedule":
            return Color(red: 255/255, green: 253/255, blue: 227/255) // #FFFDE3
        case "Athletics":
            return Color(red: 243/255, green: 255/255, blue: 220/255) // #F3FFDC
        case "Admissions":
            return Color(red: 166/255, green: 215/255, blue: 239/255) // #A6D7EF
        case "Alumni & Advancement":
            return Color(red: 171/255, green: 228/255, blue: 192/255) // #ABE4C0
        case "Visual Arts":
            return Color(red: 253/255, green: 218/255, blue: 176/255) // #FDDAB0
        case "Performing Arts":
            return Color(red: 208/255, green: 200/255, blue: 225/255) // #D0C8E1
        default:
            // Default gray for unknown categories
            return Color(red: 240/255, green: 240/255, blue: 240/255)
        }
    }
    
    // Helper to determine if text should be dark or light (all these pastels need dark text)
    static func textColor(for category: String) -> Color {
        return .black
    }
}
