import SwiftUI
import MessageUI

enum WordBopMailDraft {
	case feedback
	case missingWord(language: DictionaryLanguage, mode: GameMode)

	var subject: String {
		switch self {
		case .feedback:
			String(localized: "WordBopper iOS Feedback", comment: "Email subject; WordBopper is a brand term")
		case .missingWord:
			String(localized: "WordBopper Missing Word", comment: "Email subject; WordBopper is a brand term")
		}
	}

	var body: String? {
		switch self {
		case .feedback:
			nil
		case let .missingWord(language, mode):
			String(localized: """
			Missing word:

			Bubble Language: \(language.label)
			Game Mode: \(mode.label)

			Please include the missing word above. If you know the language or regional spelling details, feel free to add those too.
			""", comment: "Prefilled email body for reporting a missing word")
		}
	}

	func mailURL(recipient: String) -> URL? {
		var components = URLComponents()
		components.scheme = "mailto"
		components.path = recipient
		var queryItems = [URLQueryItem(name: "subject", value: subject)]
		if let body {
			queryItems.append(URLQueryItem(name: "body", value: body))
		}
		components.queryItems = queryItems
		return components.url
	}
}

struct MailComposerView: UIViewControllerRepresentable {

	let recipient: String
	let subject: String
	let body: String?
	let onFinish: (MFMailComposeResult) -> Void

	@Environment(\.dismiss) private var dismiss

	func makeCoordinator() -> Coordinator {
		Coordinator(dismiss: dismiss, onFinish: onFinish)
	}

	func makeUIViewController(context: Context) -> MFMailComposeViewController {
		let controller = MFMailComposeViewController()
		controller.mailComposeDelegate = context.coordinator
		controller.setToRecipients([recipient])
		controller.setSubject(subject)

		if let body {
			controller.setMessageBody(body, isHTML: false)
		}

		return controller
	}

	func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
	}

	final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {

		let dismiss: DismissAction
		let onFinish: (MFMailComposeResult) -> Void

		init(dismiss: DismissAction, onFinish: @escaping (MFMailComposeResult) -> Void) {
			self.dismiss = dismiss
			self.onFinish = onFinish
		}

		func mailComposeController(
			_ controller: MFMailComposeViewController,
			didFinishWith result: MFMailComposeResult,
			error: Error?
		) {
			onFinish(result)
			dismiss()
		}
	}
}
