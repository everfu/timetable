import WidgetKit
import SwiftUI

// MARK: - 数据模型

struct CourseSummary: Codable {
    let status: String
    let statusLabel: String
    let courseName: String
    let classroom: String
    let timeRange: String
    let weekLabel: String
    let dateLabel: String
    let totalToday: Int
}

// MARK: - Timeline Provider

struct TimetableProvider: TimelineProvider {
    private static let appGroupId = "group.efu.me.timetable"
    private static let fileName = "widget_course.json"

    func placeholder(in context: Context) -> TimetableEntry {
        TimetableEntry(
            date: Date(),
            summary: CourseSummary(
                status: "next",
                statusLabel: "下节课",
                courseName: "高等数学",
                classroom: "教一 203",
                timeRange: "08:30 - 10:05",
                weekLabel: "第1周 · 单周",
                dateLabel: "3月9日 周一",
                totalToday: 3
            )
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TimetableEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TimetableEntry>) -> Void) {
        let summary = loadSummary()
        let entry = TimetableEntry(date: Date(), summary: summary)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadSummary() -> CourseSummary? {
        guard let url = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: TimetableProvider.appGroupId
        ) else { return nil }

        let fileURL = url.appendingPathComponent(TimetableProvider.fileName)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(CourseSummary.self, from: data)
    }
}

// MARK: - Timeline Entry

struct TimetableEntry: TimelineEntry {
    let date: Date
    let summary: CourseSummary?
}

// MARK: - 锁屏 Rectangular 视图

struct TimetableRectangularView: View {
    let summary: CourseSummary?

    var body: some View {
        if let s = summary, s.status != "noCourse" && s.status != "finished" {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: statusIcon(s.status))
                        .font(.system(size: 10, weight: .semibold))
                    Text(s.statusLabel)
                        .font(.system(size: 11, weight: .semibold))
                }
                Text(s.courseName)
                    .font(.system(size: 14, weight: .bold))
                    .lineLimit(1)
                HStack(spacing: 4) {
                    if !s.timeRange.isEmpty {
                        Text(s.timeRange)
                            .font(.system(size: 10))
                    }
                    if !s.classroom.isEmpty {
                        Text("·")
                            .font(.system(size: 10))
                        Text(s.classroom)
                            .font(.system(size: 10))
                    }
                }
                .opacity(0.8)
            }
        } else {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 10, weight: .semibold))
                    Text(summary?.statusLabel ?? "今日无课")
                        .font(.system(size: 11, weight: .semibold))
                }
                Text("好好休息")
                    .font(.system(size: 14, weight: .bold))
                if let s = summary, !s.dateLabel.isEmpty {
                    Text(s.dateLabel)
                        .font(.system(size: 10))
                        .opacity(0.8)
                }
            }
        }
    }

    private func statusIcon(_ status: String) -> String {
        switch status {
        case "inProgress": return "book.fill"
        case "upcoming": return "bell.fill"
        case "next": return "arrow.right.circle.fill"
        default: return "book.closed"
        }
    }
}

struct TimetableInlineView: View {
    let summary: CourseSummary?

    var body: some View {
        if let s = summary, s.status != "noCourse" && s.status != "finished" {
            HStack(spacing: 4) {
                Image(systemName: "book.fill")
                Text("\(s.statusLabel): \(s.courseName)")
                    .lineLimit(1)
            }
        } else {
            HStack(spacing: 4) {
                Image(systemName: "book.closed")
                Text(summary?.statusLabel ?? "今日无课")
            }
        }
    }
}

struct TimetableCircularView: View {
    let summary: CourseSummary?

    var body: some View {
        if let s = summary, s.status != "noCourse" && s.status != "finished" {
            VStack(spacing: 1) {
                Image(systemName: statusIcon(s.status))
                    .font(.system(size: 12))
                Text(String(s.courseName.prefix(2)))
                    .font(.system(size: 10, weight: .bold))
                    .lineLimit(1)
            }
        } else {
            VStack(spacing: 1) {
                Image(systemName: "book.closed")
                    .font(.system(size: 12))
                Text("无课")
                    .font(.system(size: 10, weight: .bold))
            }
        }
    }

    private func statusIcon(_ status: String) -> String {
        switch status {
        case "inProgress": return "book.fill"
        case "upcoming": return "bell.fill"
        case "next": return "arrow.right.circle.fill"
        default: return "book.closed"
        }
    }
}

struct TimetableLockScreenWidget: Widget {
    let kind: String = "TimetableLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimetableProvider()) { entry in
            if #available(iOSApplicationExtension 17.0, *) {
                TimetableWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                TimetableWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("课表")
        .description("显示即将上课与下节课信息")
        .supportedFamilies(supportedFamilies)
    }

    private var supportedFamilies: [WidgetFamily] {
        #if os(iOS)
        if #available(iOSApplicationExtension 16.0, *) {
            return [.accessoryRectangular, .accessoryInline, .accessoryCircular]
        }
        #endif
        return []
    }
}

struct TimetableWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: TimetableEntry

    var body: some View {
        switch family {
        case .accessoryRectangular:
            TimetableRectangularView(summary: entry.summary)
        case .accessoryInline:
            TimetableInlineView(summary: entry.summary)
        case .accessoryCircular:
            TimetableCircularView(summary: entry.summary)
        default:
            TimetableRectangularView(summary: entry.summary)
        }
    }
}
