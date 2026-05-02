import SwiftUI

struct CalculatorView: View {
    @State private var display = "0"
    @State private var expression = ""
    @State private var storedValue: Double?
    @State private var pendingOperation: Operation?
    @State private var isTypingNumber = false
    @State private var shouldResetDisplay = false

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    Text(expression.isEmpty ? " " : expression)
                        .font(.system(size: 24, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    Text(display)
                        .font(.system(size: 52, weight: .regular, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(1)
                        .minimumScaleFactor(0.42)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight: 150, alignment: .bottomTrailing)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Calculator display")
                .accessibilityValue(expression.isEmpty ? display : "\(expression) \(display)")

                LazyVGrid(columns: columns, spacing: 12) {
                    button("C", style: .utility) { clear() }
                    button("⌫", style: .utility) { backspace() }
                    button("%", style: .utility) { percent() }
                    button("÷", style: .operatorKey, isSelected: pendingOperation == .divide) { operationTapped(.divide) }

                    button("7") { numberTapped("7") }
                    button("8") { numberTapped("8") }
                    button("9") { numberTapped("9") }
                    button("×", style: .operatorKey, isSelected: pendingOperation == .multiply) { operationTapped(.multiply) }

                    button("4") { numberTapped("4") }
                    button("5") { numberTapped("5") }
                    button("6") { numberTapped("6") }
                    button("−", style: .operatorKey, isSelected: pendingOperation == .subtract) { operationTapped(.subtract) }

                    button("1") { numberTapped("1") }
                    button("2") { numberTapped("2") }
                    button("3") { numberTapped("3") }
                    button("+", style: .operatorKey, isSelected: pendingOperation == .add) { operationTapped(.add) }

                    button("+/-", style: .utility) { negate() }
                    button("0") { numberTapped("0") }
                    button(".") { numberTapped(".") }
                    button("=", style: .operatorKey) { equalsTapped() }
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    private func button(
        _ title: String,
        style: KeyStyle = .number,
        isSelected: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 28, weight: .medium, design: .rounded))
                .frame(maxWidth: .infinity)
                .frame(height: 72)
                .background(isSelected ? style.selectedBackground : style.background)
                .foregroundColor(isSelected ? style.selectedForeground : style.foreground)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 3)
                )
        }
        .accessibilityLabel(accessibilityLabel(for: title))
    }

    private func numberTapped(_ value: String) {
        if display == "Error" {
            clear()
        }

        if shouldResetDisplay {
            display = "0"
            shouldResetDisplay = false
            isTypingNumber = false
        }

        if value == "." {
            if !display.contains(".") {
                display += "."
            }
            isTypingNumber = true
            return
        }

        if display == "0" || !isTypingNumber {
            display = value
        } else {
            display += value
        }

        isTypingNumber = true
    }

    private func operationTapped(_ operation: Operation) {
        guard display != "Error", let currentValue = Double(display) else { return }

        if let pendingOperation, let storedValue, isTypingNumber {
            let result = performOperation(storedValue, currentValue, pendingOperation)
            display = tidy(result)
            self.storedValue = result.isNaN || result.isInfinite ? nil : result
            expression = display == "Error" ? "" : "\(tidy(result)) \(operation.symbol)"
        } else {
            storedValue = currentValue
            expression = "\(tidy(currentValue)) \(operation.symbol)"
        }

        pendingOperation = operation
        isTypingNumber = false
        shouldResetDisplay = true
    }

    private func equalsTapped() {
        guard display != "Error",
              let operation = pendingOperation,
              let storedValue,
              let currentValue = Double(display) else { return }

        let result = performOperation(storedValue, currentValue, operation)
        expression = "\(tidy(storedValue)) \(operation.symbol) \(tidy(currentValue)) ="
        display = tidy(result)

        self.storedValue = nil
        pendingOperation = nil
        isTypingNumber = false
        shouldResetDisplay = true
    }

    private func clear() {
        display = "0"
        expression = ""
        storedValue = nil
        pendingOperation = nil
        isTypingNumber = false
        shouldResetDisplay = false
    }

    private func backspace() {
        if display == "Error" {
            clear()
            return
        }

        if shouldResetDisplay { return }

        if display.count > 1 {
            display.removeLast()
        } else {
            display = "0"
            isTypingNumber = false
        }
    }

    private func negate() {
        guard display != "Error", let value = Double(display) else { return }
        display = value == 0 ? "0" : tidy(value * -1)
    }

    private func percent() {
        guard display != "Error", let value = Double(display) else { return }
        display = tidy(value / 100.0)
    }

    private func performOperation(_ a: Double, _ b: Double, _ operation: Operation) -> Double {
        switch operation {
        case .add:
            return a + b
        case .subtract:
            return a - b
        case .multiply:
            return a * b
        case .divide:
            return b == 0 ? .nan : a / b
        }
    }

    private func tidy(_ value: Double) -> String {
        if value.isNaN || value.isInfinite { return "Error" }

        if value.rounded() == value {
            return String(Int64(value))
        }

        return String(format: "%.10g", value)
    }

    private func accessibilityLabel(for title: String) -> String {
        switch title {
        case "C": return "Clear"
        case "⌫": return "Backspace"
        case "%": return "Percent"
        case "÷": return "Divide"
        case "×": return "Multiply"
        case "−": return "Subtract"
        case "+": return "Add"
        case "+/-": return "Toggle sign"
        case "=": return "Equals"
        default: return title
        }
    }
}

enum Operation {
    case add
    case subtract
    case multiply
    case divide

    var symbol: String {
        switch self {
        case .add:
            return "+"
        case .subtract:
            return "−"
        case .multiply:
            return "×"
        case .divide:
            return "÷"
        }
    }
}

enum KeyStyle {
    case number
    case utility
    case operatorKey

    var background: Color {
        switch self {
        case .number:
            return Color.white
        case .utility:
            return Color(.systemGray4)
        case .operatorKey:
            return Color.orange
        }
    }

    var foreground: Color {
        switch self {
        case .number, .operatorKey:
            return .black
        case .utility:
            return .primary
        }
    }

    var selectedBackground: Color {
        switch self {
        case .operatorKey:
            return Color.white
        default:
            return background
        }
    }

    var selectedForeground: Color {
        switch self {
        case .operatorKey:
            return Color.orange
        default:
            return foreground
        }
    }
}

#Preview {
    CalculatorView()
}
