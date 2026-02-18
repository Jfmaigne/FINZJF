import SwiftUI

enum ImpotsTVAArticlesLoader {
    static func load() -> [ArticleItem] {
        ArticlesLoader.load(fromAsset: "articles_impots_tva_genz")
    }
}

struct ImpotsTVAArticlesView: View {
    @State private var articles: [ArticleItem] = []
    var body: some View {
        List(articles) { article in
            NavigationLink(destination: ArticleDetailView(article: article)) {
                ArticleRowView(article: article)
            }
        }
        .navigationTitle("Impôts & TVA")
        .onAppear { articles = ImpotsTVAArticlesLoader.load() }
    }
}

#Preview { NavigationStack { ImpotsTVAArticlesView() } }
