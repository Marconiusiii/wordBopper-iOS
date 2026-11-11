import Foundation
import Observation
import StoreKit

@MainActor
@Observable
final class SupportStore {
    struct Option: Identifiable {
        let id: String
        let name: String
    }

    static let options = [
        Option(id: "com.marconius.WordBop.support.littleBop", name: "Little Bop"),
        Option(id: "com.marconius.WordBop.support.bigBop", name: "Big Bop"),
        Option(id: "com.marconius.WordBop.support.superBop", name: "Super Bop"),
        Option(id: "com.marconius.WordBop.support.bopToTheTop", name: "Bop to the Top")
    ]

    struct Receipt: Codable {
        let productID: String
        let date: Date
        let transactionID: UInt64
    }

    enum Outcome {
        case success, pending, cancelled, failed, unverified
    }

    private(set) var products: [String: Product] = [:]
    private(set) var loading = false
    private(set) var loadFailed = false
    private(set) var purchasing = false
    private(set) var latest: Receipt?
    private let defaults: UserDefaults
    private static let receiptKey = "wordBopper.latestSupport"
    @ObservationIgnored private var listener: Task<Void, Never>?

    init(defaults: UserDefaults = .standard, listen: Bool = true) {
        self.defaults = defaults
        if let data = defaults.data(forKey: Self.receiptKey) {
            latest = try? JSONDecoder().decode(Receipt.self, from: data)
        }
        if listen {
            listener = Task { [weak self] in
                await withTaskGroup(of: Void.self) { group in
                    group.addTask { [weak self] in
                        for await result in Transaction.updates {
                            await self?.process(result)
                        }
                    }
                    for await result in Transaction.unfinished {
                        await self?.process(result)
                    }
                }
            }
        }
    }

    deinit { listener?.cancel() }

    func loadProducts() async {
        guard !loading, products.count < Self.options.count else { return }
        loading = true
        defer { loading = false }
        do {
            let loaded = try await Product.products(for: Self.options.map(\.id))
            products = Dictionary(uniqueKeysWithValues: loaded.map { ($0.id, $0) })
            loadFailed = products.count < Self.options.count
        } catch {
            loadFailed = true
        }
    }

    func purchase(_ option: Option) async -> Outcome {
        guard !purchasing, let product = products[option.id] else { return .failed }
        purchasing = true
        defer { purchasing = false }
        do {
            switch try await product.purchase() {
            case .success(let result):
                return await process(result) ? .success : .unverified
            case .pending: return .pending
            case .userCancelled: return .cancelled
            @unknown default: return .failed
            }
        } catch StoreKitError.userCancelled {
            return .cancelled
        } catch {
            return .failed
        }
    }

    @discardableResult
    private func process(_ result: VerificationResult<Transaction>) async -> Bool {
        guard case .verified(let transaction) = result,
              Self.options.contains(where: { $0.id == transaction.productID }),
              transaction.revocationDate == nil else { return false }
        let shouldRecord = latest.map {
            (transaction.purchaseDate, transaction.id) > ($0.date, $0.transactionID)
        } ?? true
        if shouldRecord {
            let receipt = Receipt(productID: transaction.productID, date: transaction.purchaseDate,
                                  transactionID: transaction.id)
            guard let data = try? JSONEncoder().encode(receipt) else { return false }
            defaults.set(data, forKey: Self.receiptKey)
            latest = receipt
        }
        await transaction.finish()
        return true
    }

    var thankYou: String? {
        guard let latest, let option = Self.options.first(where: { $0.id == latest.productID }) else { return nil }
        let name = products[option.id]?.displayName ?? option.name
        let date = latest.date.formatted(date: .long, time: .omitted)
        return String(localized: "Thanks for the \(name) on \(date).")
    }
}
