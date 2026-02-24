import SwiftUI
import Foundation
import UIKit

private func articleImage(for article: ArticleItem) -> Image? {
    let candidates: [String] = [
        article.slug,
        article.slug.replacingOccurrences(of: "-", with: "_"),
        article.tags.first?.lowercased() ?? ""
    ].filter { !$0.isEmpty }
    for name in candidates {
        if UIImage(named: name) != nil {
            return Image(name)
        }
    }
    return nil
}

private func themePictogram(for article: ArticleItem) -> Image? {
    let themeName = article.tags.first ?? article.slug
    let candidates: [String] = [
        themeName,
        themeName.lowercased(),
        themeName.replacingOccurrences(of: " ", with: "_"),
        themeName.replacingOccurrences(of: " ", with: "-").lowercased()
    ].filter { !$0.isEmpty }
    for name in candidates {
        if UIImage(named: name) != nil {
            return Image(name)
        }
    }
    return nil
}

private func fallbackSymbolName(for article: ArticleItem) -> String {
    // Build a searchable string from title, slug, and tags
    let haystack = ([article.title] + [article.slug] + article.tags).joined(separator: " ").lowercased()

    // Category: Impôts & TVA → prefer "tax" if available, otherwise fallback to "percent"
    if haystack.contains("impot") || haystack.contains("impôts") || haystack.contains("impots") || haystack.contains("tva") {
        if UIImage(systemName: "tax") != nil { return "tax" }
        return "percent"
    }

    // Category: Investissement → euros
    if haystack.contains("invest") || haystack.contains("placement") {
        return "eurosign.circle.fill"
    }

    // Category: Budget & gestion → tableau
    if haystack.contains("budget") || haystack.contains("gestion") {
        return "table"
    }

    // Category: Logement → maison (default)
    if haystack.contains("logement") || haystack.contains("loyer") || haystack.contains("habitation") {
        return "house.fill"
    }

    // Default to house for any unrecognized category
    return "house.fill"
}

public struct ArticleItem: Identifiable, Codable, Hashable {
    public let id: Int
    public let title: String
    public let slug: String
    public let excerpt: String
    public let content: String
    public let tags: [String]
    public let audience: String
    public let reading_time_minutes: Int
}

public struct ArticlesEnvelope: Codable, Hashable {
    public let version: String
    public let generated_at: String
    public let articles: [ArticleItem]
}

public enum ArticlesLoader {
    public static func load(fromAsset name: String) -> [ArticleItem] {
        guard let dataAsset = NSDataAsset(name: name) else { return [] }
        do {
            let decoder = JSONDecoder()
            let envelope = try decoder.decode(ArticlesEnvelope.self, from: dataAsset.data)
            return envelope.articles
        } catch {
            return []
        }
    }
}

public struct ArticleRowView: View {
    let article: ArticleItem
    public init(article: ArticleItem) { self.article = article }
    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .center, spacing: 8) {
                    Image(systemName: fallbackSymbolName(for: article))
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.blue, Color.purple, Color.pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .accessibilityHidden(true)

                    Text(article.title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.black)
                        .lineLimit(2)
                }
                Text(article.excerpt).font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
            }
            Spacer()
            if let img = articleImage(for: article) {
                img.resizable().scaledToFill().frame(width: 64, height: 64).clipped().cornerRadius(8)
            }
        }
    }
}

public struct ArticleDetailView: View {
    let article: ArticleItem
    public init(article: ArticleItem) { self.article = article }
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: fallbackSymbolName(for: article))
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.blue, Color.purple, Color.pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .accessibilityHidden(true)

                    Text(article.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.black)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(nil)
                }
                let headerImage = articleImage(for: article)
                HStack(spacing: 8) {
                    Label("\(article.reading_time_minutes) min", systemImage: "clock").font(.footnote).foregroundStyle(.secondary)
                    Text(article.audience).font(.footnote).padding(.horizontal, 8).padding(.vertical, 4).background(Capsule().fill(Color(.secondarySystemBackground)))
                }
                if let img = headerImage {
                    img.resizable().scaledToFill().frame(maxWidth: .infinity).frame(height: 160).clipped().cornerRadius(12)
                }
                if !article.tags.isEmpty { WrapTagsView_Shared(tags: article.tags) }
                Divider()
                Text(.init(article.content)).font(.body)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct WrapTagsView_Shared: View {
    let tags: [String]
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags").font(.footnote).foregroundStyle(.secondary)
            FlexibleTagWrap_Shared(tags: tags)
        }
    }
}

private struct FlexibleTagWrap_Shared: View {
    let tags: [String]
    var body: some View {
        GeometryReader { proxy in
            let availableWidth = proxy.size.width
            var width: CGFloat = 0
            var height: CGFloat = 0
            ZStack(alignment: .topLeading) {
                ForEach(tags, id: \.self) { tag in
                    TagChip_Shared(text: tag)
                        .padding(.trailing, 8)
                        .padding(.bottom, 8)
                        .alignmentGuide(.leading) { d in
                            if abs(width - d.width) > availableWidth {
                                width = 0
                                height -= d.height
                            }
                            let result = width
                            if tag == tags.last { width = 0 } else { width -= d.width }
                            return result
                        }
                        .alignmentGuide(.top) { d in
                            let result = height
                            if tag == tags.last { height = 0 }
                            return result
                        }
                }
            }
        }
    }
}

private struct TagChip_Shared: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color(.tertiarySystemBackground)))
    }
}
