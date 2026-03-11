import WidgetKit
import SwiftUI

// MARK: - 配色

struct WidgetColors {
    static let accent = Color(red: 74/255, green: 144/255, blue: 217/255)       // #4A90D9
    static let accentLight = Color(red: 100/255, green: 165/255, blue: 235/255) // 浅色模式强调
    static let accentDark = Color(red: 120/255, green: 185/255, blue: 255/255)  // 深色模式强调

    static func primary(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? accentDark : accent
    }

    static func cardBg(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(white: 0.15)
            : Color(white: 0.97)
    }

    static func textPrimary(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? .white : Color(white: 0.1)
    }

    static func textSecondary(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(white: 0.65) : Color(white: 0.45)
    }

    static func subtleBg(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(white: 0.22)
            : Color(white: 0.92)
    }
}

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

// MARK: - 工具函数

func statusIcon(_ status: String) -> String {
    switch status {
    case "inProgress": return "book.fill"
    case "upcoming": return "bell.fill"
    case "next": return "arrow.right.circle.fill"
    default: return "book.closed"
    }
}

func statusColor(_ status: String, scheme: ColorScheme) -> Color {
    switch status {
    case "inProgress": return Color.green
    case "upcoming": return Color.orange
    case "next": return WidgetColors.primary(scheme)
    default: return WidgetColors.textSecondary(scheme)
    }
}

var hasCourse: (CourseSummary?) -> Bool = { s in
    guard let s = s else { return false }
    return s.status != "noCourse" && s.status != "finished"
}

// MARK: - 主屏幕 Small 视图

struct HomeSmallView: View {
    let summary: CourseSummary?
    @Environment(\.colorScheme) var scheme

    var body: some View {
        if let s = summary, hasCourse(s) {
            VStack(alignment: .leading, spacing: 6) {
                // 状态标签
                HStack(spacing: 4) {
                    Image(systemName: statusIcon(s.status))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(statusColor(s.status, scheme: scheme))
                    Text(s.statusLabel)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(statusColor(s.status, scheme: scheme))
                }

                // 课程名
                Text(s.courseName)
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundColor(WidgetColors.textPrimary(scheme))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                Spacer(minLength: 2)

                // 时间
                if !s.timeRange.isEmpty {
                    HStack(spacing: 3) {
                        Image(systemName: "clock")
                            .font(.system(size: 9))
                        Text(s.timeRange)
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(WidgetColors.textSecondary(scheme))
                }

                // 教室
                if !s.classroom.isEmpty {
                    HStack(spacing: 3) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 9))
                        Text(s.classroom)
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(WidgetColors.textSecondary(scheme))
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        } else {
            // 无课状态
            VStack(spacing: 8) {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 28))
                    .foregroundColor(WidgetColors.primary(scheme))

                Text(summary?.statusLabel ?? "今日无课")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(WidgetColors.textPrimary(scheme))

                Text("好好休息")
                    .font(.system(size: 11))
                    .foregroundColor(WidgetColors.textSecondary(scheme))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - 主屏幕 Medium 视图

struct HomeMediumView: View {
    let summary: CourseSummary?
    @Environment(\.colorScheme) var scheme

    var body: some View {
        if let s = summary, hasCourse(s) {
            HStack(spacing: 0) {
                // 左侧：课程信息
                VStack(alignment: .leading, spacing: 5) {
                    // 状态标签
                    HStack(spacing: 4) {
                        Image(systemName: statusIcon(s.status))
                            .font(.system(size: 11, weight: .bold))
                        Text(s.statusLabel)
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(statusColor(s.status, scheme: scheme))

                    // 课程名
                    Text(s.courseName)
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundColor(WidgetColors.textPrimary(scheme))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Spacer(minLength: 2)

                    // 时间 + 教室
                    HStack(spacing: 12) {
                        if !s.timeRange.isEmpty {
                            HStack(spacing: 3) {
                                Image(systemName: "clock")
                                    .font(.system(size: 10))
                                Text(s.timeRange)
                                    .font(.system(size: 11, weight: .medium))
                            }
                        }
                        if !s.classroom.isEmpty {
                            HStack(spacing: 3) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 10))
                                Text(s.classroom)
                                    .font(.system(size: 11, weight: .medium))
                            }
                        }
                    }
                    .foregroundColor(WidgetColors.textSecondary(scheme))
                }
                .padding(14)
                .frame(maxHeight: .infinity, alignment: .topLeading)

                Spacer(minLength: 0)

                // 右侧：周次 + 今日课程数
                VStack(spacing: 8) {
                    // 今日课程数
                    VStack(spacing: 2) {
                        Text("\(s.totalToday)")
                            .font(.system(size: 28, weight: .heavy, design: .rounded))
                            .foregroundColor(WidgetColors.primary(scheme))
                        Text("今日课程")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(WidgetColors.textSecondary(scheme))
                    }

                    // 周次
                    if !s.weekLabel.isEmpty {
                        Text(s.weekLabel)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(WidgetColors.primary(scheme))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(WidgetColors.primary(scheme).opacity(0.15))
                            )
                    }

                    // 日期
                    if !s.dateLabel.isEmpty {
                        Text(s.dateLabel)
                            .font(.system(size: 9))
                            .foregroundColor(WidgetColors.textSecondary(scheme))
                    }
                }
                .padding(14)
                .frame(maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            // 无课状态
            HStack(spacing: 16) {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 36))
                    .foregroundColor(WidgetColors.primary(scheme))

                VStack(alignment: .leading, spacing: 4) {
                    Text(summary?.statusLabel ?? "今日无课")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(WidgetColors.textPrimary(scheme))

                    Text("好好休息，享受美好时光")
                        .font(.system(size: 12))
                        .foregroundColor(WidgetColors.textSecondary(scheme))

                    if let s = summary, !s.dateLabel.isEmpty {
                        Text("\(s.weekLabel)  \(s.dateLabel)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(WidgetColors.textSecondary(scheme))
                            .padding(.top, 2)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - 锁屏 Rectangular 视图（美化）

struct TimetableRectangularView: View {
    let summary: CourseSummary?

    var body: some View {
        if let s = summary, hasCourse(s) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Image(systemName: statusIcon(s.status))
                        .font(.system(size: 10, weight: .bold))
                    Text(s.statusLabel)
                        .font(.system(size: 11, weight: .bold))
                    Spacer()
                    if s.totalToday > 0 {
                        Text("共\(s.totalToday)节")
                            .font(.system(size: 9, weight: .medium))
                            .opacity(0.7)
                    }
                }
                Text(s.courseName)
                    .font(.system(size: 15, weight: .heavy))
                    .lineLimit(1)
                HStack(spacing: 6) {
                    if !s.timeRange.isEmpty {
                        Text(s.timeRange)
                            .font(.system(size: 10, weight: .medium))
                    }
                    if !s.classroom.isEmpty {
                        Text("· \(s.classroom)")
                            .font(.system(size: 10, weight: .medium))
                    }
                }
                .opacity(0.75)
            }
        } else {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 10, weight: .bold))
                    Text(summary?.statusLabel ?? "今日无课")
                        .font(.system(size: 11, weight: .bold))
                }
                Text("好好休息")
                    .font(.system(size: 15, weight: .heavy))
                if let s = summary, !s.dateLabel.isEmpty {
                    Text(s.dateLabel)
                        .font(.system(size: 10, weight: .medium))
                        .opacity(0.7)
                }
            }
        }
    }
}

// MARK: - 锁屏 Inline 视图（精简）

struct TimetableInlineView: View {
    let summary: CourseSummary?

    var body: some View {
        if let s = summary, hasCourse(s) {
            HStack(spacing: 4) {
                Image(systemName: statusIcon(s.status))
                Text("\(s.statusLabel): \(s.courseName)")
                    .lineLimit(1)
            }
        } else {
            HStack(spacing: 4) {
                Image(systemName: "moon.stars.fill")
                Text(summary?.statusLabel ?? "今日无课")
            }
        }
    }
}

// MARK: - 锁屏 Circular 视图（改进）

struct TimetableCircularView: View {
    let summary: CourseSummary?

    var body: some View {
        if let s = summary, hasCourse(s) {
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 1) {
                    Image(systemName: statusIcon(s.status))
                        .font(.system(size: 14, weight: .bold))
                    Text(String(s.courseName.prefix(2)))
                        .font(.system(size: 10, weight: .heavy))
                        .lineLimit(1)
                }
            }
        } else {
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 1) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 14, weight: .bold))
                    Text("无课")
                        .font(.system(size: 10, weight: .heavy))
                }
            }
        }
    }
}

// MARK: - 锁屏 Widget 定义

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
        .configurationDisplayName("江软课 · 锁屏")
        .description("在锁屏显示当前课程状态")
        .supportedFamilies(lockScreenFamilies)
    }

    private var lockScreenFamilies: [WidgetFamily] {
        #if os(iOS)
        if #available(iOSApplicationExtension 16.0, *) {
            return [.accessoryRectangular, .accessoryInline, .accessoryCircular]
        }
        #endif
        return []
    }
}

// MARK: - 主屏幕 Widget 定义

struct TimetableHomeScreenWidget: Widget {
    let kind: String = "TimetableHomeScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimetableProvider()) { entry in
            if #available(iOSApplicationExtension 17.0, *) {
                HomeWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        Color.clear
                    }
            } else {
                HomeWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("江软课 · 课表")
        .description("在主屏幕显示课程信息与今日概览")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - 锁屏 Entry View

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

// MARK: - 主屏幕 Entry View

struct HomeWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: TimetableEntry

    var body: some View {
        switch family {
        case .systemSmall:
            HomeSmallView(summary: entry.summary)
        case .systemMedium:
            HomeMediumView(summary: entry.summary)
        default:
            HomeSmallView(summary: entry.summary)
        }
    }
}
