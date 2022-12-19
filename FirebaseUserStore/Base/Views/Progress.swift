import SwiftUI

struct HDotsProgress: View {
    @State private var isProgress = false
    var body: some View {
        HStack{
             ForEach(0...3, id: \.self) { index in
                  Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(Color.blue)
                        .scaleEffect(self.isProgress ? 1 : 0.1)
                        .animation(self.isProgress ? Animation.linear(duration:0.5).repeatForever().delay(0.1 * Double(index)) :
                             .default
                        , value: isProgress)
             }
        }
        .onAppear { isProgress = true }
        .padding()
    }
}

