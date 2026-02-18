import SwiftUI

enum BudgetGestionArticlesLoader {
    static func load() -> [ArticleItem] {
        ArticlesLoader.load(fromAsset: "articles_budget_gestion_genz")
    }
}

struct BudgetGestionArticlesView: View {
    @State private var articles: [ArticleItem] = []
    var body: some View {
        List(articles) { article in
            NavigationLink(destination: ArticleDetailView(article: article)) {
                ArticleRowView(article: article)
            }
        }
        .navigationTitle("Budget & gestion")
        .onAppear { articles = BudgetGestionArticlesLoader.load() }
    }
}

#Preview {
    NavigationStack { BudgetGestionArticlesView() }
}
