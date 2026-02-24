import SwiftUI
import Foundation
import UIKit

struct LogementArticlesLoader {
    static func load() -> [ArticleItem] {
        ArticlesLoader.load(fromAsset: "articles_logement_genz")
    }
}

struct LogementArticlesView: View {
    @State private var articles: [ArticleItem] = []
    
    var body: some View {
        List(articles) { article in
            NavigationLink(destination: ArticleDetailView(article: article)) {
                ArticleRowView(article: article)
            }
        }
        .navigationTitle("Articles logement")
        .onAppear {
            articles = LogementArticlesLoader.load()
        }
    }
}

#Preview {
    NavigationStack {
        LogementArticlesView()
    }
}

