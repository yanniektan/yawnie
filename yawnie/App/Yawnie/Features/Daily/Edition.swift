import Foundation

/// One morning's paper as the edition function returns it: `{ day, results, html? }`.
/// The block shapes mirror `Backend/supabase/functions/_shared/blocks.ts`. Keep the two in step.
struct Edition: Codable, Equatable {
    /// `yyyy-MM-dd`, the day the paper is for.
    var day: String
    var results: [SkillResult]
    /// The filled `Paper/template.html`, when the backend sends it.
    var html: String?

    func result(for skill: String) -> SkillResult? {
        results.first { $0.skill == skill }
    }
}

struct SkillResult: Codable, Equatable, Identifiable {
    var skill: String
    var generatedAt: String
    var block: Block

    var id: String { skill }

    init(skill: String, generatedAt: String, block: Block) {
        self.skill = skill
        self.generatedAt = generatedAt
        self.block = block
    }

    private enum CodingKeys: String, CodingKey { case skill, generatedAt, block }

    /// A block that will not decode becomes `unavailable`, so one bad skill never stops the paper.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        skill = try c.decode(String.self, forKey: .skill)
        generatedAt = try c.decodeIfPresent(String.self, forKey: .generatedAt) ?? ""
        do {
            block = try c.decode(Block.self, forKey: .block)
        } catch {
            block = .unavailable(skill: skill, reason: "The section could not be read.")
        }
    }
}

enum CounterValue: Codable, Equatable {
    case count(Int)
    case done(Bool)

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let flag = try? c.decode(Bool.self) {
            self = .done(flag)
        } else {
            self = .count(try c.decode(Int.self))
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch self {
        case .count(let n): try c.encode(n)
        case .done(let flag): try c.encode(flag)
        }
    }
}

struct Bar: Codable, Equatable {
    var label: String
    var value: Double
    var unit: String
    var note: String?
}

struct ChecklistEntry: Codable, Equatable {
    var name: String
    var checked: Bool
    var buyUrl: String?
}

struct ListRow: Codable, Equatable {
    var primary: String
    var secondary: String?
    var count: Int?
}

struct ComicPanel: Codable, Equatable {
    var imageUrl: String
    var caption: String
}

enum Block: Equatable {
    case text(title: String, lines: [String], sources: [String])
    case number(title: String, value: Double, unit: String)
    case counters(today: [String: CounterValue], week: [String: [Int]])
    case bar(title: String, bars: [Bar])
    case checklist(title: String, items: [ChecklistEntry])
    case list(title: String, rows: [ListRow])
    case qa(question: String, answer: String, realWorld: String, source: String)
    case message(draft: String)
    case comic(lesson: String, panels: [ComicPanel])
    case unavailable(skill: String, reason: String)
    /// A block type this build of the app does not know yet.
    case unsupported(type: String)
}

extension Block: Codable {
    private enum CodingKeys: String, CodingKey {
        case type, title, lines, sources, value, unit, today, week, bars, items, rows
        case question, answer, realWorld, source, draft, lesson, panels, skill, reason
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let type = try c.decode(String.self, forKey: .type)
        switch type {
        case "text":
            self = .text(
                title: try c.decode(String.self, forKey: .title),
                lines: try c.decode([String].self, forKey: .lines),
                sources: try c.decodeIfPresent([String].self, forKey: .sources) ?? []
            )
        case "number":
            self = .number(
                title: try c.decode(String.self, forKey: .title),
                value: try c.decode(Double.self, forKey: .value),
                unit: try c.decode(String.self, forKey: .unit)
            )
        case "counters":
            self = .counters(
                today: try c.decode([String: CounterValue].self, forKey: .today),
                week: try c.decodeIfPresent([String: [Int]].self, forKey: .week) ?? [:]
            )
        case "bar":
            self = .bar(title: try c.decode(String.self, forKey: .title), bars: try c.decode([Bar].self, forKey: .bars))
        case "checklist":
            self = .checklist(
                title: try c.decode(String.self, forKey: .title),
                items: try c.decode([ChecklistEntry].self, forKey: .items)
            )
        case "list":
            self = .list(title: try c.decode(String.self, forKey: .title), rows: try c.decode([ListRow].self, forKey: .rows))
        case "qa":
            self = .qa(
                question: try c.decode(String.self, forKey: .question),
                answer: try c.decode(String.self, forKey: .answer),
                realWorld: try c.decode(String.self, forKey: .realWorld),
                source: try c.decode(String.self, forKey: .source)
            )
        case "message":
            self = .message(draft: try c.decode(String.self, forKey: .draft))
        case "comic":
            self = .comic(
                lesson: try c.decode(String.self, forKey: .lesson),
                panels: try c.decode([ComicPanel].self, forKey: .panels)
            )
        case "unavailable":
            self = .unavailable(
                skill: try c.decodeIfPresent(String.self, forKey: .skill) ?? "",
                reason: try c.decodeIfPresent(String.self, forKey: .reason) ?? ""
            )
        default:
            self = .unsupported(type: type)
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .text(title, lines, sources):
            try c.encode("text", forKey: .type)
            try c.encode(title, forKey: .title)
            try c.encode(lines, forKey: .lines)
            if !sources.isEmpty { try c.encode(sources, forKey: .sources) }
        case let .number(title, value, unit):
            try c.encode("number", forKey: .type)
            try c.encode(title, forKey: .title)
            try c.encode(value, forKey: .value)
            try c.encode(unit, forKey: .unit)
        case let .counters(today, week):
            try c.encode("counters", forKey: .type)
            try c.encode(today, forKey: .today)
            try c.encode(week, forKey: .week)
        case let .bar(title, bars):
            try c.encode("bar", forKey: .type)
            try c.encode(title, forKey: .title)
            try c.encode(bars, forKey: .bars)
        case let .checklist(title, items):
            try c.encode("checklist", forKey: .type)
            try c.encode(title, forKey: .title)
            try c.encode(items, forKey: .items)
        case let .list(title, rows):
            try c.encode("list", forKey: .type)
            try c.encode(title, forKey: .title)
            try c.encode(rows, forKey: .rows)
        case let .qa(question, answer, realWorld, source):
            try c.encode("qa", forKey: .type)
            try c.encode(question, forKey: .question)
            try c.encode(answer, forKey: .answer)
            try c.encode(realWorld, forKey: .realWorld)
            try c.encode(source, forKey: .source)
        case let .message(draft):
            try c.encode("message", forKey: .type)
            try c.encode(draft, forKey: .draft)
        case let .comic(lesson, panels):
            try c.encode("comic", forKey: .type)
            try c.encode(lesson, forKey: .lesson)
            try c.encode(panels, forKey: .panels)
        case let .unavailable(skill, reason):
            try c.encode("unavailable", forKey: .type)
            try c.encode(skill, forKey: .skill)
            try c.encode(reason, forKey: .reason)
        case let .unsupported(type):
            try c.encode(type, forKey: .type)
        }
    }
}
