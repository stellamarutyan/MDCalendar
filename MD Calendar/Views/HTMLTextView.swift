import SwiftUI
import UIKit

struct HTMLTextView: UIViewRepresentable {
    let htmlContent: String
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        guard let data = htmlContent.data(using: .utf8) else { return }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            // Scale font to match system body font if needed, or keep HTML styles
            // For improved readability on iOS:
            let mutableAS = NSMutableAttributedString(attributedString: attributedString)
            mutableAS.enumerateAttribute(.font, in: NSRange(location: 0, length: mutableAS.length), options: []) { value, range, stop in
                if let font = value as? UIFont {
                    // Resize font to a reasonable default if too small, or typically system font
                    let newFont = font.withSize(16)
                    mutableAS.addAttribute(.font, value: newFont, range: range)
                }
            }
            uiView.attributedText = mutableAS
        }
        uiView.textColor = .label // Adapts to Dark Mode
    }
}
