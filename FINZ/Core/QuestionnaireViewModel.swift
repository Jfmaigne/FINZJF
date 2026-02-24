import Foundation
import Combine

final class QuestionnaireViewModel: ObservableObject {
    
    enum SubscriptionType: String, CaseIterable, Codable, Hashable {
        case sport
        case music
        case telecom
        case tv
    }
    enum SubscriptionMusicType: String, CaseIterable, Codable, Hashable {
        case AppleMusic
        case Deezer
        case Spotify
        case AmazonMusic
        case Other
    }

    enum SubscriptionTelecomType: String, CaseIterable, Codable, Hashable {
        case Free
        case Orange
        case SFR
        case Bouygues
        case Other
    }

    enum SubscriptionSportType: String, CaseIterable, Codable, Hashable {
        case BasicFit
        case WeFit
        case KeepCool
        case FitnessPark
        case ClubLocal
    }
    
    enum SubscriptionTVType: String, CaseIterable, Codable, Hashable {
        case Netflix
        case CanalPlus
        case BeinSport
        case AmazonPrime
        case Other
    }
    
    // Step 1: Living situation
    enum LivingSituation: String, CaseIterable, Codable, Hashable{
        case withParents
        case alone
        case colocation
        case couple
    }

    enum TransportMode: String, CaseIterable, Codable, Hashable {
        case car
        case publicTransport
        case bike
        case walk
    }
    
    enum PersonnalSituation: String, CaseIterable, Codable, Hashable {
        case Etudiant
        case Salarié
        case SansEmploi
        case Handicap
        case Entrepreneur
    }
    
    enum HousingStatus: String, CaseIterable, Codable, Hashable {
        case owner
        case renter
    }

    // Step 1: Living situation
    @Published var livingSituation: LivingSituation? = nil

    // Step 2: Contributions (when living with parents)
    @Published var housingContribution: Double = 0
    @Published var livingContribution: Double = 0

    // Step 3: Transport modes
    @Published var selectedTransportModes: Set<TransportMode> = []
    @Published var selectedLifeModes: Set<LivingSituation> = []
    @Published var selectedSubscriptions: Set<SubscriptionType> = []
    @Published var selectedSubscriptionsMusic: Set<SubscriptionMusicType> = []
    @Published var selectedSubscriptionsTelecom: Set<SubscriptionTelecomType> = []
    @Published var selectedSubscriptionsSport: Set<SubscriptionSportType> = []
    @Published var selectedSubscriptionsTV: Set<SubscriptionTVType> = []
    // Queue driving the multi-step Subscriptions flow (e.g., sport -> music -> telecom -> tv)
    @Published var subscriptionFlowQueue: [SubscriptionType] = []
    @Published var selectedPersonnalSituation: Set<PersonnalSituation> = []


    @Published var LifeModeVar: LivingSituation? = nil
    @Published var housingStatus: HousingStatus? = nil
    
    // Prepare the flow queue in a deterministic order based on the user's selection
    func prepareSubscriptionFlow() {
        let order: [SubscriptionType] = [.sport, .music, .telecom, .tv]
        subscriptionFlowQueue = order.filter { selectedSubscriptions.contains($0) }
    }

    // Pop the next subscription type to present, or nil if done
    @discardableResult
    func dequeueNextSubscriptionType() -> SubscriptionType? {
        guard !subscriptionFlowQueue.isEmpty else { return nil }
        return subscriptionFlowQueue.removeFirst()
    }
    
}

