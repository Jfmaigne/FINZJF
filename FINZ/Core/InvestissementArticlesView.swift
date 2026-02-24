import SwiftUI

enum InvestissementArticlesLoader {
    static func load() -> [ArticleItem] {
        ArticlesLoader.load(fromAsset: "articles_investissement_genz")
    }
}

struct InvestissementArticlesView: View {
    @State private var articles: [ArticleItem] = []
    var body: some View {
        List(articles) { article in
            NavigationLink(destination: ArticleDetailView(article: article)) {
                ArticleRowView(article: article)
            }
        }
        .navigationTitle("Investissement")
        .onAppear { articles = InvestissementArticlesLoader.load() }
    }
}

#Preview { NavigationStack { InvestissementArticlesView() } }
