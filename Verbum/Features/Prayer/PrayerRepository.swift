import Foundation
import SwiftData

@MainActor
final class PrayerRepository: ObservableObject {

    private let modelContext: ModelContext
    private let seeder: PrayerAssetSeeder
    private var prayerCache: [PrayerCategory: [Prayer]]? = nil

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.seeder = PrayerAssetSeeder(modelContext: modelContext)
    }

    // MARK: - Seeding

    func ensureSeeded() async {
        await seeder.seed()
        prayerCache = nil
    }

    // MARK: - Queries

    func getPrayersByCategory() -> [PrayerCategory: [Prayer]] {
        if let cached = prayerCache { return cached }
        let descriptor = FetchDescriptor<PrayerEntity>(
            sortBy: [SortDescriptor(\.orderIndex)]
        )
        let entities = (try? modelContext.fetch(descriptor)) ?? []
        if entities.isEmpty {
            // Fallback to static seed while DB is populating
            return Self.staticPrayers
        }
        var result: [PrayerCategory: [Prayer]] = [:]
        for entity in entities {
            let cat = PrayerCategory(rawValue: entity.category.capitalized)
                ?? categoryFromSlug(entity.category)
            var prayers = result[cat] ?? []
            prayers.append(Prayer(id: entity.id, title: entity.title, category: cat,
                                  text: entity.text, latinText: entity.latinText))
            result[cat] = prayers
        }
        prayerCache = result
        return result
    }

    func getPrayer(id: String) -> Prayer? {
        let descriptor = FetchDescriptor<PrayerEntity>(
            predicate: #Predicate { $0.id == id }
        )
        guard let entity = (try? modelContext.fetch(descriptor))?.first else {
            return getPrayersByCategory().values.flatMap { $0 }.first(where: { $0.id == id })
        }
        let cat = categoryFromSlug(entity.category)
        return Prayer(id: entity.id, title: entity.title, category: cat,
                      text: entity.text, latinText: entity.latinText)
    }

    // MARK: - Helpers

    private func categoryFromSlug(_ slug: String) -> PrayerCategory {
        switch slug.lowercased() {
        case "rosary":   return .rosary
        case "morning":  return .morning
        case "evening":  return .evening
        case "saints":   return .saints
        default:         return .devotion
        }
    }

    // MARK: - Static fallback (mirrors prayers.json content)
    static let staticPrayers: [PrayerCategory: [Prayer]] = [
            .rosary: [
                Prayer(id: "rosary_1", title: "Holy Rosary", category: .rosary,
                       text: "In the name of the Father, and of the Son, and of the Holy Spirit. Amen.\n\nI believe in God, the Father almighty, Creator of heaven and earth, and in Jesus Christ, His only Son, our Lord, who was conceived by the Holy Spirit, born of the Virgin Mary, suffered under Pontius Pilate, was crucified, died and was buried…",
                       latinText: "In nomine Patris, et Filii, et Spiritus Sancti. Amen.\n\nCredo in Deum Patrem omnipotentem, Creatorem caeli et terrae…"),
                Prayer(id: "rosary_2", title: "Mysteries of the Rosary", category: .rosary,
                       text: "The Joyful Mysteries (Monday, Saturday):\n1. The Annunciation\n2. The Visitation\n3. The Nativity\n4. The Presentation\n5. The Finding of Jesus in the Temple"),
            ],
            .devotion: [
                Prayer(id: "devotion_1", title: "Our Father", category: .devotion,
                       text: "Our Father, who art in heaven,\nhallowed be thy name;\nthy kingdom come,\nthy will be done\non earth as it is in heaven.\nGive us this day our daily bread,\nand forgive us our trespasses,\nas we forgive those who trespass against us;\nand lead us not into temptation,\nbut deliver us from evil.\nAmen.",
                       latinText: "Pater noster, qui es in caelis,\nsanctificetur nomen tuum.\nAdveniat regnum tuum.\nFiat voluntas tua,\nsicut in caelo et in terra.\nPanem nostrum quotidianum da nobis hodie,\net dimitte nobis debita nostra\nsicut et nos dimittimus debitoribus nostris.\nEt ne nos inducas in tentationem,\nsed libera nos a malo.\nAmen."),
                Prayer(id: "devotion_2", title: "Hail Mary", category: .devotion,
                       text: "Hail Mary, full of grace, the Lord is with thee. Blessed art thou amongst women, and blessed is the fruit of thy womb, Jesus. Holy Mary, Mother of God, pray for us sinners, now and at the hour of our death. Amen.",
                       latinText: "Ave Maria, gratia plena, Dominus tecum. Benedicta tu in mulieribus, et benedictus fructus ventris tui, Iesus. Sancta Maria, Mater Dei, ora pro nobis peccatoribus, nunc et in hora mortis nostrae. Amen."),
                Prayer(id: "devotion_3", title: "Glory Be", category: .devotion,
                       text: "Glory be to the Father, and to the Son, and to the Holy Spirit. As it was in the beginning, is now, and ever shall be, world without end. Amen."),
                Prayer(id: "devotion_4", title: "Act of Contrition", category: .devotion,
                       text: "O my God, I am heartily sorry for having offended Thee, and I detest all my sins because of Thy just punishments, but most of all because they offend Thee, my God, who art all good and deserving of all my love. I firmly resolve with the help of Thy grace to sin no more and to avoid the near occasions of sin. Amen."),
            ],
            .morning: [
                Prayer(id: "morning_1", title: "Morning Offering", category: .morning,
                       text: "O Jesus, through the Immaculate Heart of Mary, I offer You my prayers, works, joys, and sufferings of this day for all the intentions of Your Sacred Heart, in union with the Holy Sacrifice of the Mass throughout the world, for the salvation of souls, the reparation of sins, the reunion of all Christians, and in particular for the intentions of the Holy Father this month. Amen."),
                Prayer(id: "morning_2", title: "Prayer to the Guardian Angel", category: .morning,
                       text: "Angel of God, my guardian dear, to whom God's love commits me here, ever this day be at my side, to light, to guard, to rule, and guide. Amen."),
            ],
            .evening: [
                Prayer(id: "evening_1", title: "Night Prayer", category: .evening,
                       text: "Visit, we beseech You, O Lord, this dwelling, and drive far from it all snares of the enemy; let Your holy angels dwell within to preserve us in peace; and let Your blessing be upon us, through Jesus Christ our Lord. Amen."),
                Prayer(id: "evening_2", title: "Examen of Conscience", category: .evening,
                       text: "Lord, I thank You for the gifts of this day.\nHelp me to see where I have loved well,\nand where I have failed to love.\nGrant me the grace to begin again tomorrow\nmore closely following Your Son, Jesus Christ. Amen."),
            ],
            .saints: [
                Prayer(id: "saints_1", title: "Prayer to St. Joseph", category: .saints,
                       text: "O Saint Joseph, whose protection is so great, so strong, so prompt before the throne of God, I place in thee all my interests and desires. O Saint Joseph, assist me by thy powerful intercession and obtain for me from thy divine Son all spiritual blessings through Jesus Christ, our Lord. Amen."),
                Prayer(id: "saints_2", title: "Prayer to St. Michael", category: .saints,
                       text: "St. Michael the Archangel, defend us in battle. Be our defense against the wickedness and snares of the Devil. May God rebuke him, we humbly pray, and do thou, O Prince of the heavenly hosts, by the power of God, thrust into hell Satan, and all the evil spirits, who prowl about the world seeking the ruin of souls. Amen."),
            ],
        ]
}
