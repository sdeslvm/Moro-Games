import Foundation
import SwiftUI

struct MoroGamesEntryScreen: View {
    @StateObject private var loader: MoroGamesWebLoader

    init(loader: MoroGamesWebLoader) {
        _loader = StateObject(wrappedValue: loader)
    }

    var body: some View {
        ZStack {
            MoroGamesWebViewBox(loader: loader)
                .opacity(loader.state == .finished ? 1 : 0.5)
            switch loader.state {
            case .progressing(let percent):
                MoroGamesProgressIndicator(value: percent)
            case .failure(let err):
                MoroGamesErrorIndicator(err: err)  // err теперь String
            case .noConnection:
                MoroGamesOfflineIndicator()
            default:
                EmptyView()
            }
        }
    }
}

private struct MoroGamesProgressIndicator: View {
    let value: Double
    var body: some View {
        GeometryReader { geo in
            MoroGamesLoadingOverlay(progress: value)
                .frame(width: geo.size.width, height: geo.size.height)
                .background(Color.black)
        }
    }
}

private struct MoroGamesErrorIndicator: View {
    let err: String  // было Error, стало String
    var body: some View {
        Text("Ошибка: \(err)").foregroundColor(.red)
    }
}

private struct MoroGamesOfflineIndicator: View {
    var body: some View {
        Text("Нет соединения").foregroundColor(.gray)
    }
}
