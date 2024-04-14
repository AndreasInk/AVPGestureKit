# AVPGestureKit
## Extend Apple Vision Pro's hand tracking gestures

### Very WIP right now, but will keep updating. 
### So far it supports thumbs up, waving, and fist gestures, with more gestures soon.

### Tutorial Setup
1. Add this package to dependancies in your Swift package or add this package through Swift Package Manager in your Xcode Project

```swift
    .package(url: "https://github.com/AndreasInk/AVPGestureKit.git", branch: "main")
```

2. Add a StateObject of GestureViewModel within your app lifecycle, GestureViewModel controls the gesture state
3. Open an immersive space, then call await gestureViewModel.start()
4. Make a thumbs up, see the console print left hand thumbs up. Wave, see the console print left hand wave or update your view to show this rather than printing.
5. Change your SwiftUI view's state based on the gesture state, like below...

```swift
struct GestureTestView: View {
    @EnvironmentObject var viewModel: GestureViewModel
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    var body: some View {
        ZStack {
            Group {
                if viewModel.state == .thumbsUp {
                    // Show some view
                } else if viewModel.state == .wave {
                    // Show some view
                }
            }
            Text(viewModel.state.emoji)
                .font(.largeTitle)
                .padding()
                .background {
                    Circle()
                        .fill(.thickMaterial)
                }
        }
        .frame(minWidth: 1000, minHeight: 1000)
        .animation(.interactiveSpring, value: viewModel.state.emoji)
        .task {
            await openImmersiveSpace(id: "ImmersiveSpace")
            await viewModel.start()
        }
    }
}
```
6. Setup your app lifecycle, ensure you pass GestureViewModel as an environmentObject and have an ImmersiveSpace with some id (if following above, id == "ImmersiveSpace")
```swift
import SwiftUI
import AVPGestureKit

@main
struct MechFightApp: App {
    @StateObject var viewModel = GestureViewModel()
    var body: some Scene {
        WindowGroup {
            VStack {
                ContentView()
                    .overlay(alignment: .top) {
                        GestureTestView()
                    }
            }
            .environmentObject(viewModel)
        }
        .windowStyle(.volumetric)

        ImmersiveSpace(id: "ImmersiveSpace") {
            
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
```

### Advanced Setup
**TODO**

[![X Post of the framework in action](https://github.com/AndreasInk/AVPGestureKit/assets/67549402/9754cbd5-7d37-4089-8488-ae381ff980e3)](https://twitter.com/i/status/1770268102590103964)
