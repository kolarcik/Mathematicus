import SwiftUI

/// Zobrazení otázky (zadání + obrázek + nápověda).
struct QuestionCard: View {
    let question: Question
    let accent: Color
    var showHintButton = true
    @State private var showHint = false

    var body: some View {
        VStack(spacing: 14) {
            Text(question.prompt)
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity)

            if let figure = question.figure {
                FigureView(figure: figure, color: accent)
                    .frame(height: 150)
            }

            if showHintButton, let hint = question.hint {
                if showHint {
                    Label(hint, systemImage: "lightbulb.fill")
                        .font(.callout)
                        .foregroundStyle(.orange)
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(Color.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Button {
                        withAnimation(.spring) { showHint = true }
                    } label: {
                        Label("Nápověda", systemImage: "lightbulb")
                            .font(.callout.weight(.medium))
                    }
                    .tint(.orange)
                }
            }
        }
        .padding(18)
        .card()
        .onChange(of: question.id) { showHint = false }
    }
}

/// Vstup odpovědi – buď tlačítka s možnostmi, nebo vlastní číselná klávesnice.
struct AnswerInputView: View {
    let question: Question
    let accent: Color
    var disabled = false
    let onAnswer: (Bool) -> Void

    @State private var text = ""
    @State private var shake = 0

    var body: some View {
        Group {
            if question.isChoice {
                choices
            } else {
                VStack(spacing: 12) {
                    display
                    keypad
                }
            }
        }
        .disabled(disabled)
        .onChange(of: question.id) { text = "" }
    }

    // MARK: Možnosti

    private var choices: some View {
        let options = question.choiceOptions
        let columns = options.count <= 3 && options.allSatisfy({ $0.count > 12 })
            ? [GridItem(.flexible())]
            : [GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Array(options.enumerated()), id: \.offset) { i, option in
                Button {
                    onAnswer(question.isCorrect(choice: i))
                } label: {
                    Text(option)
                        .font(.title3.weight(.semibold))
                        .minimumScaleFactor(0.6)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, minHeight: 64)
                        .padding(.horizontal, 8)
                        .background(accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(accent.opacity(0.4), lineWidth: 1.5))
                }
                .buttonStyle(PressableStyle())
            }
        }
    }

    // MARK: Klávesnice

    private var display: some View {
        HStack(spacing: 8) {
            if let prefix = question.prefix {
                Text(prefix).font(.title2.weight(.semibold)).foregroundStyle(.secondary)
            }
            Text(text.isEmpty ? "?" : text)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(text.isEmpty ? Color.secondary.opacity(0.5) : Color.primary)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .frame(minWidth: 80)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(accent.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
                .modifier(ShakeEffect(shakes: CGFloat(shake)))
            if let unit = question.unit {
                Text(unit).font(.title2.weight(.semibold)).foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var keypad: some View {
        Grid(horizontalSpacing: 8, verticalSpacing: 8) {
            GridRow { keyButton("7"); keyButton("8"); keyButton("9"); keyButton("⌫") }
            GridRow { keyButton("4"); keyButton("5"); keyButton("6"); keyButton("−") }
            GridRow { keyButton("1"); keyButton("2"); keyButton("3"); keyButton(question.expectsFraction ? "/" : "") }
            GridRow {
                keyButton("0")
                keyButton(",")
                keyButton("OK").gridCellColumns(2)
            }
        }
    }

    @ViewBuilder
    private func keyButton(_ key: String) -> some View {
        if key.isEmpty {
            Color.clear.frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
        } else {
            let isOK = key == "OK"
            Button {
                press(key)
            } label: {
                Group {
                    if key == "⌫" {
                        Image(systemName: "delete.left.fill")
                    } else {
                        Text(isOK ? "Odeslat" : key)
                    }
                }
                .font(isOK ? .title3.bold() : .title2.weight(.semibold))
                .foregroundStyle(isOK ? .white : .primary)
                .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                .background(isOK ? AnyShapeStyle(accent) : AnyShapeStyle(Color(.secondarySystemGroupedBackground)),
                            in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
            }
            .buttonStyle(PressableStyle())
        }
    }

    private func press(_ key: String) {
        Haptics.tap()
        switch key {
        case "⌫":
            if !text.isEmpty { text.removeLast() }
        case "−":
            // Minus přepíná znaménko celého čísla (u zlomku znaménko čitatele).
            if text.hasPrefix("−") { text.removeFirst() } else { text = "−" + text }
        case ",":
            if !currentPart.contains(","), !text.isEmpty, text.last != "−", text.last != "/" { text += "," }
            else if text.isEmpty || text.last == "−" { text += "0," }
        case "/":
            if !text.contains("/"), !text.isEmpty, !text.contains(","), text.last?.isNumber == true { text += "/" }
        case "OK":
            guard ParsedInput(text) != nil else {
                withAnimation(.default) { shake += 1 }
                Haptics.error()
                return
            }
            onAnswer(question.isCorrect(text))
        default:
            if text.count < 12 { text += key }
        }
    }

    private var currentPart: String {
        if let idx = text.lastIndex(of: "/") { return String(text[text.index(after: idx)...]) }
        return text
    }
}

struct ShakeEffect: GeometryEffect {
    var shakes: CGFloat
    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: 8 * sin(shakes * .pi * 4), y: 0))
    }
}
