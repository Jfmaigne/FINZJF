import SwiftUI

struct ArticlesListView: View {
    let assetName: String
    let title: String
    @State private var articles: [ArticleItem] = []
    @State private var query: String = ""

    private var filtered: [ArticleItem] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return articles }
        return articles.filter { a in
            a.title.localizedCaseInsensitiveContains(q) ||
            a.excerpt.localizedCaseInsensitiveContains(q) ||
            a.slug.localizedCaseInsensitiveContains(q) ||
            a.tags.contains(where: { $0.localizedCaseInsensitiveContains(q) })
        }
    }

    var body: some View {
        List(filtered) { article in
            NavigationLink(destination: ArticleDetailView(article: article)) {
                ArticleRowView(article: article)
            }
        }
        .navigationTitle(title)
        .searchable(text: $query, prompt: "Rechercher un article")
        .onAppear { articles = ArticlesLoader.load(fromAsset: assetName) }
    }
}

#Preview {
    NavigationStack {
        ArticlesListView(assetName: "articles_logement_genz", title: "Apprendre")
    }
}
