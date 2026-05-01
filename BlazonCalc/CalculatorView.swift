import SwiftUI

struct CalculatorView: View {
    @State private var display = "0"
    @State private var operand: Double = 0.0
    @State private var pendingOperation: String = ""
    @State private var isNewOperation = true

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Spacer()

                HStack {
                    Spacer()
                    Text(display)
                        .font(.system(size: 48, weight: .regular, design: .rounded))
                        .multilineTextAlignment(.trailing)
                        .lineLimit(2)
                        .minimumScaleFactor(0.45)
                        .padding()
                }
                .frame(maxWidth: .infinity, minHeight: 140, alignment: .bottomTrailing)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                LazyVGrid(columns: columns, spacing: 12) {
                    button("C", style: .utility) { clear() }
                    button("⌫", style: .utility) { backspace() }
                    button("%", style: .utility) { percent() }
                    button("÷", style: .operatorKey) { operationTapped("/") }

                    button("7") { numberTapped("7") }
                    button("8") { numberTapped("8") }
                    button("9") { numberTapped("9") }
                    button("×", style: .operatorKey) { operationTapped("*") }

                    button("4") { numberTapped("4") }
                    button("5") { numberTapped("5") }
                    button("6") { numberTapped("6") }
                    button("−", style: .operatorKey) { operationTapped("-") }

                    button("1") { numberTapped("1") }
                    button("2") { numberTapped("2") }
                    button("3") { numberTapped("3") }
                    button("+", style: .operatorKey) { operationTapped("+") }

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
    private func button(_ title: String, style: KeyStyle = .number, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 28, weight: .medium, design: .rounded))
                .frame(maxWidth: .infinity)
                .frame(height: 72)
                .background(style.background)
                .foregroundColor(style.foreground)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }

    private func numberTapped(_ value: String) {
        if isNewOperation {
            display = ""
            isNewOperation = false
        }

        if value == "." && display.contains(".") {
            return
        }

        if display == "0" && value != "." {
            display = value
        } else {
            display += value
        }

        if display.isEmpty {
            display = "0"
        }
    }

    private func clear() {
        display = "0"
        operand = 0.0
        pendingOperation = ""
        isNewOperation = true
    }

    private func backspace() {
        if isNewOperation { return }

        if !display.isEmpty {
            display.removeLast()
            if display.isEmpty || display == "-" {
                display = "0"
                isNewOperation = true
            }
        }
    }

    private func negate() {
        guard let value = Double(display) else { return }
        display = value == 0 ? "0" : tidy(value * -1)
    }

    private func percent() {
        guard let value = Double(display) else { return }
        display = tidy(value / 100.0)
    }

    private func operationTapped(_ operation: String) {
        guard let value = Double(display) else { return }

        if pendingOperation.isEmpty {
            operand = value
        } else {
            operand = performOperation(operand, value, pendingOperation)
            display = tidy(operand)
        }

        pendingOperation = operation
        isNewOperation = true
    }

    private func equalsTapped() {
        guard let value = Double(display) else { return }

        operand = pendingOperation.isEmpty ? value : performOperation(operand, value, pendingOperation)
        display = tidy(operand)
        pendingOperation = ""
        isNewOperation = true
    }

    private func performOperation(_ a: Double, _ b: Double, _ operation: String) -> Double {
        switch operation {
        case "+": return a + b
        case "-": return a - b
        case "*": return a * b
        case "/": return b == 0 ? .nan : a / b
        default: return b
        }
    }

    private func tidy(_ value: Double) -> String {
        if value.isNaN || value.isInfinite { return "Error" }
        if value.rounded() == value { return String(Int64(value)) }
        return String(format: "%.10g", value)
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
}

#Preview {
    CalculatorView()
}
