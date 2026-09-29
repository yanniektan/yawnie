import UIKit

protocol PrinterPicking {
    /// Shows a printer chooser. Returns nil if the user cancels.
    @MainActor func pickPrinter(current: SavedPrinter?) async -> SavedPrinter?
}

/// The system printer chooser. The Print service prints straight to the printer saved here.
struct SystemPrinterPicker: PrinterPicking {
    @MainActor
    func pickPrinter(current: SavedPrinter?) async -> SavedPrinter? {
        let picker = UIPrinterPickerController(initiallySelectedPrinter: current.map { UIPrinter(url: $0.url) })
        return await withCheckedContinuation { continuation in
            picker.present(animated: true) { controller, userDidSelect, _ in
                guard userDidSelect, let printer = controller.selectedPrinter else {
                    continuation.resume(returning: nil)
                    return
                }
                continuation.resume(returning: SavedPrinter(url: printer.url, name: printer.displayName))
            }
        }
    }
}
