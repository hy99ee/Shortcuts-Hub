import SwiftUI

struct CircleProgress: ProgressViewStyle {
    
    var strokeColor = Color.red
   func makeBody(configuration: Configuration) -> some View {
        return ZStack {
            Circle()
                .trim(from: 0, to: configuration.fractionCompleted ?? 0)
                .stroke(strokeColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}

struct ProgressWheel: View {
    @State private var progress: CGFloat
    private var total: CGFloat

    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    init(total: CGFloat) {
        self.progress = total
        self.total = total
    }
    
    var body: some View {
        ZStack{
            ProgressView(value: progress, total: total)
                .progressViewStyle(CircleProgress())
        }
        .onReceive(timer) { _ in
            if progress > 0.05 {
                progress -= 0.05
            }
        }
        
    }
    
}
