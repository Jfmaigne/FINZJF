import Combine
import SwiftUI
import Foundation

private func justified(_ string: String) -> AttributedString {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .justified
    let nsAttr = NSAttributedString(
        string: string,
        attributes: [
            .paragraphStyle: paragraphStyle
        ]
    )
    return AttributedString(nsAttr)
}

private struct LexiconSection: Identifiable, Hashable {
    let id: String
    let entries: [LexiconEntry]
}

struct LexiconEntry: Identifiable, Hashable, Codable {
    var id: String { word }
    var word: String
    var definition: String

    var initial: String {
        guard let first = word.first else { return "" }
        return String(first)
    }
}

let seedLexicon = [
    LexiconEntry(word: "Budget", definition: "Un plan financier qui estime les revenus et les dépenses sur une période future déterminée."),
    LexiconEntry(word: "Dépense", definition: "Sommes payées ou coûts engagés par une organisation dans ses efforts pour générer des revenus."),
    LexiconEntry(word: "Revenu", definition: "Argent reçu, notamment de manière régulière, en échange d’un travail ou provenant d’investissements."),
    LexiconEntry(word: "Épargne", definition: "La part du revenu qui n’est pas dépensée pour les dépenses courantes."),
    LexiconEntry(word: "Investissement", definition: "Action ou processus consistant à placer de l’argent dans le but d’obtenir un profit ou un avantage matériel."),
    LexiconEntry(word: "Actif", definition: "Ressources détenues par une personne ou une entreprise et considérées comme ayant de la valeur."),
    LexiconEntry(word: "Passif", definition: "Dettes ou obligations financières légales d’une entreprise nées au cours de son activité."),
    LexiconEntry(word: "Valeur nette", definition: "Total des actifs moins l’ensemble des passifs externes d’une personne ou d’une entreprise."),
    LexiconEntry(word: "Crédit", definition: "Capacité d’emprunter de l’argent ou d’accéder à des biens et services avec l’engagement de payer plus tard."),
    LexiconEntry(word: "Dette", definition: "Somme d’argent due par une partie à une autre."),
    LexiconEntry(word: "Intérêt", definition: "Coût de l’emprunt d’argent, généralement exprimé en taux annuel."),
    LexiconEntry(word: "Dividende", definition: "Somme d’argent versée régulièrement par une société à ses actionnaires à partir de ses bénéfices."),
    LexiconEntry(word: "Inflation", definition: "Taux d’augmentation du niveau général des prix des biens et services."),
    LexiconEntry(word: "Déflation", definition: "Diminution du niveau général des prix dans une économie."),
    LexiconEntry(word: "Liquidité", definition: "Disponibilité d’actifs immédiatement mobilisables pour un marché ou une entreprise."),
    LexiconEntry(word: "Portefeuille", definition: "Ensemble des investissements détenus par une personne ou une organisation."),
    LexiconEntry(word: "Diversification", definition: "Stratégie de gestion des risques qui consiste à répartir les investissements sur une large variété d’actifs."),
    LexiconEntry(word: "Capital", definition: "Richesse sous forme d’argent ou d’autres actifs détenus par une personne ou une organisation."),
    LexiconEntry(word: "Capitaux propres", definition: "Valeur des actions émises par une société; part résiduelle appartenant aux actionnaires."),
    LexiconEntry(word: "Chiffre d’affaires", definition: "Revenus d’une organisation, en particulier lorsqu’ils sont d’une importance significative."),
    LexiconEntry(word: "Allocation d’actifs", definition: "Répartition d’un portefeuille entre différentes classes d’actifs pour équilibrer risque et rendement."),
    LexiconEntry(word: "Amortissement", definition: "Réduction progressive de la valeur d’un actif ou remboursement échelonné d’un prêt."),
    LexiconEntry(word: "Analyse fondamentale", definition: "Évaluation d’un actif basée sur ses données économiques et financières sous-jacentes."),
    LexiconEntry(word: "Analyse technique", definition: "Étude des prix et volumes passés pour anticiper les mouvements de marché."),
    LexiconEntry(word: "Annuité", definition: "Série de paiements égaux effectués à intervalles réguliers."),
    LexiconEntry(word: "APL", definition: "Aide personnalisée au logement, prestation sociale réduisant le coût du logement."),
    LexiconEntry(word: "Assurance auto", definition: "Contrat couvrant les dommages matériels et corporels liés à l’utilisation d’un véhicule."),
    LexiconEntry(word: "Assurance habitation", definition: "Contrat protégeant un logement et ses occupants contre divers sinistres."),
    LexiconEntry(word: "Assurance responsabilité civile", definition: "Garantie couvrant les dommages causés à des tiers."),
    LexiconEntry(word: "Assurance santé", definition: "Couverture des frais médicaux non pris en charge par le régime obligatoire."),
    LexiconEntry(word: "Assurance vie", definition: "Contrat d’épargne et/ou de prévoyance avec avantages successoraux."),
    LexiconEntry(word: "Autorisation de découvert", definition: "Facilité bancaire permettant un solde négatif jusqu’à une limite convenue."),
    LexiconEntry(word: "Avoir fiscal", definition: "Crédit d’impôt rattaché à certains revenus, selon la législation en vigueur."),
    LexiconEntry(word: "Bail", definition: "Contrat par lequel un bailleur met un bien à disposition d’un locataire contre loyer."),
    LexiconEntry(word: "Bénéfice net", definition: "Résultat final d’une entreprise après déduction de toutes les charges et impôts."),
    LexiconEntry(word: "Bilan", definition: "Document comptable présentant le patrimoine d’une entité à une date donnée."),
    LexiconEntry(word: "Bourse", definition: "Marché organisé où s’échangent des titres financiers."),
    LexiconEntry(word: "Budget base zéro", definition: "Méthode budgétaire où chaque dépense doit être justifiée à partir de zéro."),
    LexiconEntry(word: "Cadre fiscal", definition: "Ensemble des règles d’imposition applicables à une situation donnée."),
    LexiconEntry(word: "Cap", definition: "Plafond appliqué à un taux ou un prix dans un contrat financier."),
    LexiconEntry(word: "Cash-flow", definition: "Flux de trésorerie net généré par une activité sur une période."),
    LexiconEntry(word: "Cession", definition: "Transfert de propriété d’un actif d’un détenteur à un autre."),
    LexiconEntry(word: "Clause bénéficiaire", definition: "Disposition d’un contrat d’assurance vie désignant le bénéficiaire des capitaux."),
    LexiconEntry(word: "Compte courant", definition: "Compte bancaire utilisé pour les opérations quotidiennes."),
    LexiconEntry(word: "Compte épargne", definition: "Compte rémunéré destiné à mettre de l’argent de côté."),
    LexiconEntry(word: "Comptabilité", definition: "Discipline enregistrant et synthétisant les opérations financières d’une entité."),
    LexiconEntry(word: "Contrat à terme", definition: "Accord d’acheter ou vendre un actif à un prix et une date futurs."),
    LexiconEntry(word: "Contrat d’assurance", definition: "Accord par lequel l’assureur couvre un risque en échange d’une prime."),
    LexiconEntry(word: "Contribution sociale", definition: "Prélèvement finançant la protection sociale."),
    LexiconEntry(word: "Coût de revient", definition: "Coût total de production ou d’acquisition d’un bien ou service."),
    LexiconEntry(word: "Couverture", definition: "Stratégie visant à réduire l’exposition à un risque financier."),
    LexiconEntry(word: "Crédit à la consommation", definition: "Prêt destiné au financement de biens ou services non immobiliers."),
    LexiconEntry(word: "Crédit immobilier", definition: "Prêt destiné à financer l’achat d’un bien immobilier."),
    LexiconEntry(word: "Crédit renouvelable", definition: "Réserve d’argent réutilisable avec intérêts, dans la limite d’un plafond."),
    LexiconEntry(word: "Cumul d’intérêts", definition: "Capitalisation des intérêts ajoutés au capital initial au fil du temps."),
    LexiconEntry(word: "Date de valeur", definition: "Date prise en compte pour le calcul des intérêts sur une opération."),
    LexiconEntry(word: "Débit", definition: "Inscription d’une somme au passif d’un compte bancaire ou comptable."),
    LexiconEntry(word: "Découvert", definition: "Solde négatif d’un compte bancaire autorisé ou non."),
    LexiconEntry(word: "Déduction fiscale", definition: "Somme retranchée du revenu imposable selon la loi fiscale."),
    LexiconEntry(word: "Délai de carence", definition: "Période pendant laquelle les garanties d’assurance ne s’appliquent pas encore."),
    LexiconEntry(word: "Délit d’initié", definition: "Utilisation d’informations privilégiées pour réaliser des opérations boursières."),
    LexiconEntry(word: "Démembrement", definition: "Séparation de la propriété entre usufruit et nue-propriété."),
    LexiconEntry(word: "Dépôt de garantie", definition: "Somme versée en sécurité lors de la signature d’un bail."),
    LexiconEntry(word: "Dérivé", definition: "Instrument financier dont la valeur dépend d’un actif sous-jacent."),
    LexiconEntry(word: "Diversifier", definition: "Répartir ses placements pour réduire le risque global."),
    LexiconEntry(word: "Dividende exceptionnel", definition: "Distribution ponctuelle supérieure au dividende ordinaire."),
    LexiconEntry(word: "Dotation", definition: "Affectation de ressources à un fonds ou une entité pour un usage spécifique."),
    LexiconEntry(word: "Durée d’emprunt", definition: "Période sur laquelle un prêt doit être remboursé."),
    LexiconEntry(word: "Effet de levier", definition: "Utilisation de l’endettement pour augmenter le potentiel de rendement."),
    LexiconEntry(word: "Éligible PEA", definition: "Qualifie un titre pouvant être logé dans un Plan d’Épargne en Actions."),
    LexiconEntry(word: "Épargne de précaution", definition: "Réserve financière destinée aux imprévus."),
    LexiconEntry(word: "Épargne retraite", definition: "Dispositifs d’épargne dédiés à la préparation de la retraite."),
    LexiconEntry(word: "ETF", definition: "Fonds indiciel coté répliquant la performance d’un indice."),
    LexiconEntry(word: "Euribor", definition: "Taux interbancaire de référence de la zone euro."),
    LexiconEntry(word: "Exposition", definition: "Montant du capital soumis à un risque donné."),
    LexiconEntry(word: "FCP", definition: "Fonds commun de placement, véhicule d’investissement collectif."),
    LexiconEntry(word: "Fiche de paie", definition: "Document détaillant la rémunération et les retenues d’un salarié."),
    LexiconEntry(word: "Fiducie", definition: "Mécanisme par lequel des biens sont gérés par un fiduciaire au profit d’un bénéficiaire."),
    LexiconEntry(word: "Fonds en euros", definition: "Support d’assurance vie à capital garanti avec rendement annuel."),
    LexiconEntry(word: "Fonds profilé", definition: "Fonds d’investissement avec un niveau de risque prédéfini."),
    LexiconEntry(word: "Forfait", definition: "Montant fixe convenu pour un service ou une prestation."),
    LexiconEntry(word: "Frais de gestion", definition: "Rémunération prélevée pour l’administration d’un produit financier."),
    LexiconEntry(word: "Frais d’entrée", definition: "Commission perçue lors de la souscription d’un produit d’investissement."),
    LexiconEntry(word: "Garant", definition: "Personne se portant caution du remboursement d’un crédit."),
    LexiconEntry(word: "Garantie emprunteur", definition: "Protection couvrant le remboursement d’un prêt en cas d’aléas de la vie."),
    LexiconEntry(word: "Gestion active", definition: "Stratégie visant à battre un indice de référence par des choix de titres."),
    LexiconEntry(word: "Gestion passive", definition: "Stratégie visant à répliquer un indice de marché à faible coût."),
    LexiconEntry(word: "Horizon de placement", definition: "Durée prévue de détention d’un investissement."),
    LexiconEntry(word: "IFI", definition: "Impôt sur la Fortune Immobilière."),
    LexiconEntry(word: "Impôt sur le revenu", definition: "Prélèvement fiscal assis sur les revenus des personnes physiques."),
    LexiconEntry(word: "Indice boursier", definition: "Mesure synthétique de la performance d’un ensemble de titres."),
    LexiconEntry(word: "Indivision", definition: "Situation juridique où plusieurs personnes détiennent ensemble un bien."),
    LexiconEntry(word: "Inflation sous-jacente", definition: "Inflation corrigée des éléments volatils comme l’énergie et l’alimentation."),
    LexiconEntry(word: "Intérêts composés", definition: "Intérêts calculés sur le capital initial et les intérêts accumulés."),
    LexiconEntry(word: "Lissage d’emprunt", definition: "Technique de répartition des échéances pour stabiliser les mensualités."),
    LexiconEntry(word: "Livret A", definition: "Compte d’épargne réglementé en France avec taux fixé par l’État."),
    LexiconEntry(word: "LTV", definition: "Ratio prêt/valeur d’un bien immobilier."),
    LexiconEntry(word: "Mandat de gestion", definition: "Délégation de la gestion d’un portefeuille à un professionnel."),
    LexiconEntry(word: "Marge brute", definition: "Différence entre le chiffre d’affaires et le coût des ventes."),
    LexiconEntry(word: "Marge nette", definition: "Pourcentage du chiffre d’affaires restant après toutes charges et impôts."),
    LexiconEntry(word: "Maturité", definition: "Échéance à laquelle un instrument financier est remboursé."),
    LexiconEntry(word: "Mensualité", definition: "Paiement effectué chaque mois dans le cadre d’un prêt."),
    LexiconEntry(word: "Modulation de prêt", definition: "Ajustement des échéances ou de la durée d’un crédit immobilier."),
    LexiconEntry(word: "Obligation", definition: "Titre de créance émis par un État ou une entreprise."),
    LexiconEntry(word: "OPA", definition: "Offre publique d’achat sur les titres d’une société cotée."),
    LexiconEntry(word: "OPCVM", definition: "Organisme de placement collectif en valeurs mobilières."),
    LexiconEntry(word: "Option", definition: "Droit d’acheter ou vendre un actif à un prix donné avant une date."),
    LexiconEntry(word: "Pension alimentaire", definition: "Somme versée pour subvenir aux besoins d’un enfant ou ex-conjoint."),
    LexiconEntry(word: "PEA", definition: "Plan d’Épargne en Actions, enveloppe fiscale pour investir en actions."),
    LexiconEntry(word: "PER", definition: "Plan d’Épargne Retraite, dispositif d’épargne pour la retraite."),
    LexiconEntry(word: "Péril assuré", definition: "Événement aléatoire couvert par un contrat d’assurance."),
    LexiconEntry(word: "Période de grâce", definition: "Intervalle durant lequel aucun paiement n’est exigé sans pénalité."),
    LexiconEntry(word: "Plafond", definition: "Limite supérieure appliquée à un montant ou un avantage."),
    LexiconEntry(word: "Plan de financement", definition: "Tableau des ressources mobilisées pour financer un projet."),
    LexiconEntry(word: "Plan de remboursement", definition: "Échéancier détaillant les paiements d’un prêt."),
    LexiconEntry(word: "Plus-value", definition: "Gain réalisé lors de la cession d’un actif au-dessus de son prix d’achat."),
    LexiconEntry(word: "Point mort", definition: "Niveau d’activité à partir duquel une entreprise couvre ses coûts."),
    LexiconEntry(word: "Portage", definition: "Détention temporaire d’un actif pour le compte d’un tiers."),
    LexiconEntry(word: "Prime d’assurance", definition: "Somme payée à l’assureur en échange de la couverture du risque."),
    LexiconEntry(word: "Prime de risque", definition: "Rendement supplémentaire exigé pour compenser un risque plus élevé."),
    LexiconEntry(word: "Provision", definition: "Montant comptabilisé pour couvrir une dépense ou un risque probable."),
    LexiconEntry(word: "Quittance", definition: "Document attestant le paiement d’une somme due."),
    LexiconEntry(word: "Rachat partiel", definition: "Retrait d’une partie de l’épargne d’un contrat d’assurance vie."),
    LexiconEntry(word: "Rachat total", definition: "Clôture d’un contrat d’assurance vie avec versement de l’épargne."),
    LexiconEntry(word: "Rang hypothécaire", definition: "Priorité d’un créancier sur un bien immobilier en cas de défaut."),
    LexiconEntry(word: "Ratio d’endettement", definition: "Mesure de la dette par rapport aux fonds propres ou aux revenus."),
    LexiconEntry(word: "Réallocation", definition: "Ajustement de la répartition d’actifs d’un portefeuille."),
    LexiconEntry(word: "Régime matrimonial", definition: "Organisation juridique des biens dans un couple."),
    LexiconEntry(word: "Rendement", definition: "Revenu généré par un investissement rapporté à sa valeur."),
    LexiconEntry(word: "Rente", definition: "Paiement périodique versé à vie ou sur une durée déterminée."),
    LexiconEntry(word: "Reprise de dette", definition: "Transfert d’un emprunt d’un emprunteur à un autre."),
    LexiconEntry(word: "Réserve de précaution", definition: "Épargne destinée à faire face aux dépenses imprévues."),
    LexiconEntry(word: "Résiliation", definition: "Fin d’un contrat selon des conditions prévues."),
    LexiconEntry(word: "Résiliation infra-annuelle", definition: "Possibilité de résilier un contrat d’assurance en cours d’année."),
    LexiconEntry(word: "Résiliation sans frais", definition: "Clôture d’un contrat sans pénalité, selon conditions."),
    LexiconEntry(word: "Revenus fonciers", definition: "Revenus tirés de la location de biens immobiliers."),
    LexiconEntry(word: "Revenus mobiliers", definition: "Revenus issus de placements financiers (intérêts, dividendes)."),
    LexiconEntry(word: "Risque de taux", definition: "Risque de perte lié aux variations des taux d’intérêt."),
    LexiconEntry(word: "Scoring crédit", definition: "Évaluation statistique de la probabilité de remboursement d’un emprunteur."),
    LexiconEntry(word: "Sensibilité", definition: "Variation du prix d’une obligation en fonction du taux d’intérêt."),
    LexiconEntry(word: "Sinistre", definition: "Réalisation d’un événement couvert par un contrat d’assurance."),
    LexiconEntry(word: "Souscription", definition: "Acte d’adhérer à un contrat d’assurance ou d’acheter des titres."),
    LexiconEntry(word: "Surprime", definition: "Majoration de la prime d’assurance en raison d’un risque aggravé."),
    LexiconEntry(word: "Taux actuariel", definition: "Taux reflétant le rendement réel d’une obligation ou d’un placement."),
    LexiconEntry(word: "Taux d’endettement", definition: "Part des charges de crédit rapportée aux revenus."),
    LexiconEntry(word: "Taux d’intérêt nominal", definition: "Taux affiché ne tenant pas compte de l’inflation."),
    LexiconEntry(word: "Taux d’intérêt réel", definition: "Taux nominal corrigé de l’inflation."),
    LexiconEntry(word: "Taux d’usure", definition: "Taux maximal légal auquel un crédit peut être accordé."),
    LexiconEntry(word: "Taux fixe", definition: "Taux d’intérêt qui reste constant pendant toute la durée du prêt."),
    LexiconEntry(word: "Taux variable", definition: "Taux d’intérêt qui évolue selon un indice de référence."),
    LexiconEntry(word: "TFE", definition: "Taux effectif global (TAEG), coût total du crédit exprimé en pourcentage annuel."),
    LexiconEntry(word: "Ticket modérateur", definition: "Part des frais de santé restant à la charge de l’assuré."),
    LexiconEntry(word: "Titres vifs", definition: "Actions ou obligations détenues directement, hors fonds."),
    LexiconEntry(word: "Trésorerie", definition: "Disponibilités financières immédiatement mobilisables."),
    LexiconEntry(word: "UC", definition: "Unités de compte d’assurance vie, support non garanti en capital."),
    LexiconEntry(word: "Valeur liquidative", definition: "Prix d’une part de fonds calculé à une date donnée."),
    LexiconEntry(word: "Valeur de rachat", definition: "Montant récupérable en cas de rachat d’un contrat d’assurance vie."),
    LexiconEntry(word: "Valeur de réalisation", definition: "Prix estimé de vente d’un actif net des coûts."),
    LexiconEntry(word: "Volatilité", definition: "Mesure de l’ampleur des variations de prix d’un actif."),
    LexiconEntry(word: "Zone euro", definition: "Ensemble des pays utilisant l’euro comme monnaie."),
    LexiconEntry(word: "Acompte", definition: "Paiement partiel effectué avant le solde d’une somme due."),
    LexiconEntry(word: "Arbitrage", definition: "Réallocation des supports d’investissement au sein d’un contrat."),
    LexiconEntry(word: "Assiette", definition: "Base sur laquelle est calculé un impôt ou une cotisation."),
    LexiconEntry(word: "Avantage fiscal", definition: "Réduction d’impôt ou déduction accordée selon certains dispositifs."),
    LexiconEntry(word: "Barème", definition: "Grille de calcul progressive d’un impôt ou d’une cotisation."),
    LexiconEntry(word: "Cotation", definition: "Fixation du prix d’un titre sur un marché."),
    LexiconEntry(word: "Domiciliation", definition: "Enregistrement d’un prélèvement ou d’un virement sur un compte."),
    LexiconEntry(word: "Échéance", definition: "Date à laquelle un paiement doit être effectué."),
    LexiconEntry(word: "Exonération", definition: "Dispense totale ou partielle d’un impôt ou d’une cotisation."),
    LexiconEntry(word: "Indice des prix", definition: "Indicateur mesurant l’évolution moyenne des prix d’un panier de biens."),
    LexiconEntry(word: "Justificatif", definition: "Document prouvant une dépense, un revenu ou une situation."),
    LexiconEntry(word: "Nantissement", definition: "Sûreté consistant à affecter un bien en garantie d’une dette."),
    LexiconEntry(word: "Pénalité de remboursement anticipé", definition: "Frais dus en cas de remboursement d’un prêt avant terme."),
    LexiconEntry(word: "Prélèvement à la source", definition: "Collecte de l’impôt sur le revenu au moment du versement."),
    LexiconEntry(word: "Provision pour risques", definition: "Montant affecté pour couvrir un risque identifié."),
    LexiconEntry(word: "Quote-part", definition: "Part attribuée à un participant dans une répartition."),
    LexiconEntry(word: "Rachat de crédit", definition: "Regroupement de plusieurs prêts en un seul avec nouvelle durée."),
    LexiconEntry(word: "Revalorisation", definition: "Augmentation d’un montant pour tenir compte de l’inflation ou d’un index."),
    LexiconEntry(word: "Taux de rendement interne", definition: "Taux actualisant les flux futurs pour obtenir une VAN nulle."),
    LexiconEntry(word: "Valeur actuelle nette", definition: "Somme actualisée des flux futurs moins l’investissement initial."),
    LexiconEntry(word: "Virement permanent", definition: "Transfert automatique et régulier d’une somme entre comptes."),
]

struct LexiconView: View {
    @State private var query: String = ""

    private var sections: [LexiconSection] {
        buildSections(from: filteredList())
    }

    private func allEntriesSorted() -> [LexiconEntry] {
        seedLexicon.sorted { $0.word.localizedCaseInsensitiveCompare($1.word) == .orderedAscending }
    }

    private func filteredList() -> [LexiconEntry] {
        let base = allEntriesSorted()
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let searched: [LexiconEntry]
        if q.isEmpty {
            searched = base
        } else {
            searched = base.filter { entry in
                entry.word.localizedCaseInsensitiveContains(q) ||
                entry.definition.localizedCaseInsensitiveContains(q)
            }
        }
        return searched
    }

    private func buildSections(from entries: [LexiconEntry]) -> [LexiconSection] {
        let grouped = Dictionary(grouping: entries, by: { $0.initial })
        var result: [LexiconSection] = []
        for (key, values) in grouped {
            let sortedValues = values.sorted { $0.word.localizedCaseInsensitiveCompare($1.word) == .orderedAscending }
            result.append(LexiconSection(id: key, entries: sortedValues))
        }
        return result.sorted { $0.id < $1.id }
    }

    var body: some View {
        VStack(spacing: 12) {
            // Search bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Rechercher", text: $query)
                    .textInputAutocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
            .padding(.horizontal)

            // Content list
            List {
                ForEach(sections) { section in
                    Section(section.id) {
                        ForEach(section.entries) { entry in
                            NavigationLink(destination: LexiconDetailView(entry: entry)) {
                                LexiconRow(entry: entry)
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
        .background(
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.04),
                    Color.purple.opacity(0.04),
                    Color.pink.opacity(0.04)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .environment(\.locale, Locale(identifier: "fr"))
    }
}

private struct LexiconRow: View {
    let entry: LexiconEntry

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(entry.word)
                    .font(.headline)
                Text(justified(entry.definition))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

private struct LexiconDetailView: View {
    let entry: LexiconEntry
    @State private var scale: CGFloat = 1.0

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(entry.word)
                .font(.largeTitle)
                .bold()
            ScrollView {
                Text(justified(entry.definition))
                    .font(.body)
                    .scaleEffect(scale)
                    .animation(.default, value: scale)
                    .gesture(MagnificationGesture().onChanged { value in
                        scale = min(max(0.5, value), 3.0)
                    })
            }
            Spacer()
        }
        .padding()
    }
}
