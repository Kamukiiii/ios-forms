import Foundation
import SwiftUI

// MARK: - Question Type
enum QuestionType: String, CaseIterable, Identifiable, Codable {
    var id: String { rawValue }
    case short, paragraph, mc, checkbox, dropdown, scale, rating
    case date, time, mcgrid, checkgrid, textblock, image, video, section

    var label: String {
        switch self {
        case .short:      return "Short answer"
        case .paragraph:  return "Paragraph"
        case .mc:         return "Multiple choice"
        case .checkbox:   return "Checkboxes"
        case .dropdown:   return "Dropdown"
        case .scale:      return "Linear scale"
        case .rating:     return "Rating"
        case .date:       return "Date"
        case .time:       return "Time"
        case .mcgrid:     return "Multiple choice grid"
        case .checkgrid:  return "Checkbox grid"
        case .textblock:  return "Text"
        case .image:      return "Image"
        case .video:      return "Video"
        case .section:    return "Section"
        }
    }

    var sfSymbol: String {
        switch self {
        case .short:      return "text.alignleft"
        case .paragraph:  return "doc.text"
        case .mc:         return "circle"
        case .checkbox:   return "checkmark.square"
        case .dropdown:   return "chevron.up.chevron.down"
        case .scale:      return "slider.horizontal.3"
        case .rating:     return "star"
        case .date:       return "calendar"
        case .time:       return "clock"
        case .mcgrid:     return "tablecells"
        case .checkgrid:  return "checkmark.rectangle.stack"
        case .textblock:  return "textformat"
        case .image:      return "photo"
        case .video:      return "video"
        case .section:    return "minus"
        }
    }

    var isContentBlock: Bool { [.textblock, .image, .video, .section].contains(self) }
    var hasOptions: Bool { [.mc, .checkbox, .dropdown].contains(self) }
    var isGrid: Bool { [.mcgrid, .checkgrid].contains(self) }
}

// MARK: - Question
struct Question: Identifiable {
    var id: String = UUID().uuidString
    var type: QuestionType = .short
    var title: String = ""
    var description: String = ""
    var required: Bool = false
    var options: [String] = ["Option 1"]
    var hasImage: Bool = false
    var hasDesc: Bool = false
    var scaleMin: Int = 1
    var scaleMax: Int = 5
    var rows: [String] = ["Row 1"]
    var columns: [String] = ["Column 1", "Column 2"]

    // Preview/response state
    var answerText: String = ""
    var selectedOption: Int? = nil
    var selectedOptions: Set<Int> = []
    var ratingValue: Int = 0
    var dateMonth: String = ""
    var dateDay: String = ""
    var dateYear: String = ""
    var timeHour: String = ""
    var timeMin: String = ""
    var timePeriod: String = "AM"
}

// MARK: - Form
struct FormModel: Identifiable {
    var id: String = UUID().uuidString
    var title: String = "Untitled form"
    var description: String = ""
    var accentHex: String = "#5b5bd6"
    var responseCount: Int = 0
    var editedDate: Date = Date()
    var createdDate: Date = Date()
    var questions: [Question] = []

    // Settings
    var pushNotif: Bool = false
    var emailNotif: Bool = true
    var collectEmail: Bool = false
    var limitOne: Bool = false
    var allowEdit: Bool = false
    var shareSummary: Bool = true
    var progressBar: Bool = false
    var shuffle: Bool = false
    var submitAnother: Bool = true
    var makeQuiz: Bool = false

    var accentColor: Color { Color(hex: accentHex) }

    var metaString: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        let d = f.string(from: editedDate)
        return "Edited \(d) · \(responseCount) response\(responseCount == 1 ? "" : "s")"
    }

    var shortMeta: String {
        "\(responseCount)r"
    }

    // MARK: - Samples
    static let sampleForms: [FormModel] = [
        FormModel(
            id: "f1",
            title: "Customer Satisfaction Survey",
            description: "Help us improve your experience",
            accentHex: "#5b5bd6",
            responseCount: 248,
            editedDate: daysAgo(4),
            createdDate: daysAgo(30),
            questions: [
                Question(id: "q1", type: .mc, title: "How satisfied are you with our service overall?",
                         required: true, options: ["Very satisfied", "Satisfied", "Neutral", "Dissatisfied", "Very dissatisfied"]),
                Question(id: "q2", type: .short, title: "What did you like most about your experience?"),
                Question(id: "q3", type: .rating, title: "How likely are you to recommend us to a friend?"),
                Question(id: "q4", type: .paragraph, title: "Any additional comments or suggestions?"),
                Question(id: "q5", type: .scale, title: "Rate the value for money", scaleMin: 1, scaleMax: 10),
            ]
        ),
        FormModel(
            id: "f2",
            title: "Event Registration",
            description: "",
            accentHex: "#2bb3a3",
            responseCount: 63,
            editedDate: daysAgo(12),
            createdDate: daysAgo(20),
            questions: [
                Question(id: "q6", type: .short, title: "Full name", required: true),
                Question(id: "q7", type: .short, title: "Email address", required: true),
                Question(id: "q8", type: .dropdown, title: "T-shirt size", options: ["XS", "S", "M", "L", "XL", "XXL"]),
                Question(id: "q9", type: .mc, title: "Meal preference", required: true,
                         options: ["Vegetarian", "Vegan", "Non-vegetarian", "Gluten-free"]),
            ]
        ),
        FormModel(
            id: "f3",
            title: "Team Feedback Form",
            description: "",
            accentHex: "#f0a23b",
            responseCount: 12,
            editedDate: daysAgo(2),
            createdDate: daysAgo(14),
            questions: [
                Question(id: "q10", type: .paragraph, title: "Describe your week in a few sentences"),
                Question(id: "q11", type: .scale, title: "Rate your workload this week", scaleMin: 1, scaleMax: 5),
                Question(id: "q12", type: .mc, title: "Are you blocked on anything?",
                         options: ["Yes, significantly", "Somewhat", "No blockers"]),
                Question(id: "q13", type: .checkbox, title: "Which areas need more resources?",
                         options: ["Engineering", "Design", "Marketing", "Sales", "Support"]),
            ]
        ),
        FormModel(
            id: "f4",
            title: "Pop Quiz – Chapter 5",
            description: "",
            accentHex: "#e8638a",
            responseCount: 31,
            editedDate: daysAgo(7),
            createdDate: daysAgo(10),
            questions: [
                Question(id: "q14", type: .mc, title: "What is the capital of France?", required: true,
                         options: ["London", "Berlin", "Paris", "Madrid"]),
                Question(id: "q15", type: .checkbox, title: "Select all prime numbers:",
                         options: ["2", "4", "7", "9", "11"]),
                Question(id: "q16", type: .short, title: "In your own words, explain photosynthesis", required: true),
            ]
        ),
    ]

    private static func daysAgo(_ n: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -n, to: Date()) ?? Date()
    }
}
