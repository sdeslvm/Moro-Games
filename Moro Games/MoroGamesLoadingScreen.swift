import SwiftUI

// MARK: - Протоколы для улучшения расширяемости

protocol ProgressDisplayable {
    var progressPercentage: Int { get }
}

protocol BackgroundProviding {
    associatedtype BackgroundContent: View
    func makeBackground() -> BackgroundContent
}

// MARK: - Расширенная структура загрузки

struct MoroGamesLoadingOverlay: View, ProgressDisplayable {
    let progress: Double
    @State private var pulse = false
    var progressPercentage: Int { Int(progress * 100) }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Фон: logo + затемнение
                Image("logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .ignoresSafeArea()
                    .overlay(Color.black.opacity(0.45))

                VStack {
                    Spacer()
                    // Пульсирующий логотип
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.38)
                        .scaleEffect(pulse ? 1.02 : 0.82)
                        .shadow(color: .black.opacity(0.25), radius: 16, y: 8)
                        .animation(
                            Animation.easeInOut(duration: 1.1).repeatForever(autoreverses: true),
                            value: pulse
                        )
                        .onAppear { pulse = true }
                        .padding(.bottom, 36)
                    // Прогрессбар и проценты
                    VStack(spacing: 14) {
                        Text("Loading \(progressPercentage)%")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .shadow(radius: 1)
                        MoroGamesProgressBar(value: progress)
                            .frame(width: geo.size.width * 0.52, height: 10)
                    }
                    .padding(14)
                    .background(Color.black.opacity(0.22))
                    .cornerRadius(14)
                    .padding(.bottom, geo.size.height * 0.18)
                    Spacer()
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }
}

// MARK: - Фоновые представления

struct MoroGamesBackground: View, BackgroundProviding {
    func makeBackground() -> some View {
        Image("background")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }

    var body: some View {
        makeBackground()
    }
}

// MARK: - Индикатор прогресса с анимацией

struct MoroGamesProgressBar: View {
    let value: Double
    @State private var shimmerOffset: CGFloat = -1
    @State private var particleAnimation: Bool = false

    var body: some View {
        GeometryReader { geometry in
            progressContainer(in: geometry)
                .onAppear {
                    startAnimations()
                }
        }
    }

    private func progressContainer(in geometry: GeometryProxy) -> some View {
        ZStack(alignment: .leading) {
            backgroundTrack(height: geometry.size.height)
            progressTrack(in: geometry)
            particleOverlay(in: geometry)
        }
    }

    private func backgroundTrack(height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: height / 2)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#0D1117"), Color(hex: "#1C2128"), Color(hex: "#0D1117"),
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: height)
            .overlay(
                RoundedRectangle(cornerRadius: height / 2)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#00D4FF").opacity(0.3),
                                Color(hex: "#FF0080").opacity(0.3),
                                Color(hex: "#00D4FF").opacity(0.3),
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.8), radius: 8, y: 4)
    }

    private func progressTrack(in geometry: GeometryProxy) -> some View {
        let width = CGFloat(value) * geometry.size.width
        let height = geometry.size.height

        return ZStack {
            // Основной неоновый градиент
            RoundedRectangle(cornerRadius: height / 2)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#00D4FF"),
                            Color(hex: "#0099CC"),
                            Color(hex: "#FF0080"),
                            Color(hex: "#CC0066"),
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: width, height: height)
                .shadow(color: Color(hex: "#00D4FF").opacity(0.8), radius: 12, y: 0)
                .shadow(color: Color(hex: "#FF0080").opacity(0.6), radius: 8, y: 0)

            // Анимированный шиммер эффект
            RoundedRectangle(cornerRadius: height / 2)
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.clear, location: 0),
                            .init(color: Color.white.opacity(0.6), location: 0.5),
                            .init(color: Color.clear, location: 1),
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: width, height: height)
                .offset(x: shimmerOffset * width)
                .mask(
                    RoundedRectangle(cornerRadius: height / 2)
                        .frame(width: width, height: height)
                )

            // Внутреннее свечение
            RoundedRectangle(cornerRadius: height / 2)
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.4),
                            Color.clear,
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: height / 2
                    )
                )
                .frame(width: width, height: height * 0.6)
        }
        .animation(.linear(duration: 0.3), value: value)
    }

    private func particleOverlay(in geometry: GeometryProxy) -> some View {
        let width = CGFloat(value) * geometry.size.width
        let height = geometry.size.height

        return ZStack {
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color(hex: index % 2 == 0 ? "#00D4FF" : "#FF0080").opacity(0.8),
                                Color.clear,
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 2
                        )
                    )
                    .frame(width: 3, height: 3)
                    .offset(
                        x: (width * 0.8) * (CGFloat(index) / 7.0) - width * 0.4,
                        y: particleAnimation
                            ? sin(Double(index) * 0.8) * Double(height * 0.3)
                            : -sin(Double(index) * 0.8) * Double(height * 0.3)
                    )
                    .opacity(value > 0.1 ? 1 : 0)
                    .animation(
                        Animation.easeInOut(duration: 2.0 + Double(index) * 0.2)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.1),
                        value: particleAnimation
                    )
            }
        }
        .frame(width: width, height: height)
    }

    private func startAnimations() {
        // Шиммер анимация
        withAnimation(Animation.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            shimmerOffset = 1
        }

        // Частицы анимация
        withAnimation {
            particleAnimation = true
        }
    }
}

// MARK: - Превью

#Preview("Vertical") {
    MoroGamesLoadingOverlay(progress: 0.2)
}

#Preview("Horizontal") {
    MoroGamesLoadingOverlay(progress: 0.2)
        .previewInterfaceOrientation(.landscapeRight)
}
