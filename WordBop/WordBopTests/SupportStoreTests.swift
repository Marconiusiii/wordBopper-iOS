import Foundation
import StoreKit
import StoreKitTest
import Testing
@testable import WordBop

@MainActor
struct SupportStoreTests {
    @Test func localProductsAndRepeatSupport() async throws {
        let session = try SKTestSession(configurationFileNamed: "SupportWordBopper")
        session.resetToDefaultState()
        session.disableDialogs = true
        session.clearTransactions()
        defer {
            session.resetToDefaultState()
            session.clearTransactions()
        }
        let suite = "SupportStoreTests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = SupportStore(defaults: defaults)
        await store.loadProducts()
        #expect(!store.loadFailed)
        #expect(store.products.count == 4)
        for option in SupportStore.options {
            let product = try #require(store.products[option.id])
            #expect(product.type == .consumable)
            #expect(product.displayName == option.name)
        }
        let option = SupportStore.options[0]
        #expect(await store.purchase(option) == .success)
        let first = try #require(store.latest)
        #expect(await store.purchase(option) == .success)
        let second = try #require(store.latest)
        #expect(first.transactionID != second.transactionID)
        let reopened = SupportStore(defaults: defaults, listen: false)
        #expect(reopened.latest?.transactionID == second.transactionID)
        #expect(reopened.latest?.date == second.date)
        #expect(reopened.thankYou?.contains(option.name) == true)

        try await session.setSimulatedError(.generic(.userCancelled), forAPI: .purchase)
        #expect(await store.purchase(option) == .cancelled)
        #expect(store.latest?.transactionID == second.transactionID)
        try await session.setSimulatedError(nil, forAPI: .purchase)

        session.askToBuyEnabled = true
        let pendingOption = SupportStore.options[1]
        #expect(await store.purchase(pendingOption) == .pending)
        #expect(store.latest?.transactionID == second.transactionID)
        let pending = try #require(session.allTransactions().first { $0.pendingAskToBuyConfirmation })
        try session.approveAskToBuyTransaction(identifier: pending.identifier)
        for _ in 0..<100 {
            if store.latest?.productID == pendingOption.id { break }
            try await Task.sleep(for: .milliseconds(100))
        }
        #expect(store.latest?.productID == pendingOption.id)
    }
}
