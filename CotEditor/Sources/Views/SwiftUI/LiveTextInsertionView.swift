//
//  LiveTextInsertionView.swift
//
//  CotEditor
//  https://coteditor.com
//
//  Created by 1024jp on 2023-11-13.
//
//  ---------------------------------------------------------------------------
//
//  © 2023-2025 1024jp
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import AppKit
import SwiftUI
import VisionKit

extension ImageAnalysis: @retroactive @unchecked Sendable { }


struct LiveTextInsertionView: View {
    
    var image: NSImage
    var length: Double = 500
    var actionHandler: (String) -> Void
    
    var dismiss: () -> Void = { }
    
    private static let analyzer = ImageAnalyzer()
    
    @State private var result: Result<ImageAnalysis, any Error>?
    
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 0) {
            Image(nsImage: self.image)
                .resizable()
                .scaledToFit()
                .overlay { OverlayView(result: self.result) }
                .frame(width: !self.image.isPortrait ? self.length : nil,
                       height: self.image.isPortrait ? self.length : nil)
            
            Divider()
            
            HStack(alignment: .firstTextBaseline) {
                HelpLink(anchor: "howto_insert_camera_text")
                Spacer()
                
                if case .success(let analysis) = self.result, !analysis.transcript.isEmpty {
                    Button(String(localized: "Insert", table: "LiveTextInsertion", comment: "button label")) {
                        self.actionHandler(analysis.transcript)
                        self.dismiss()
                    }.keyboardShortcut(.defaultAction)
                } else {
                    Button(String(localized: "Close", table: "LiveTextInsertion", comment: "button label")) {
                        self.dismiss()
                    }
                }
            }
            .padding(.top, 10)
            .scenePadding([.horizontal, .bottom])
        }
        .task {
            self.result = await Task {
                try await Self.analyzer.analyze(self.image, orientation: .up, configuration: .init([.text]))
            }.result
        }
        .controlSize(.small)
        .fixedSize()
    }
    
    
    private struct OverlayView: View {
        
        var result: Result<ImageAnalysis, any Error>?
        
        
        var body: some View {
            
            switch self.result {
                case .success(let analysis) where !analysis.transcript.isEmpty:
                    LiveTextOverlayView(analysis: analysis)
                    
                case .success:
                    Text("No text detected", tableName: "LiveTextInsertion")
                        .padding(.horizontal, 4)
                        .modifier(HUDStyle())
                    
                case .failure(let error):
                    VStack(spacing: 4) {
                        Label(String(localized: "Detection failed", table: "LiveTextInsertion"), systemImage: "exclamationmark.triangle")
                            .symbolVariant(.fill)
                        Text(error.localizedDescription)
                            .lineLimit(nil)
                            .controlSize(.small)
                    }
                    .padding(.horizontal, 4)
                    .modifier(HUDStyle())
                    
                case nil:
                    ProgressView()
                        .modifier(HUDStyle())
            }
        }
    }
}


private struct HUDStyle: ViewModifier {
    
    func body(content: Content) -> some View {
        
        content
            .padding(6)
            .background(.ultraThinMaterial, in: .rect(cornerRadius: 8))
            .padding(8)
    }
}


private struct LiveTextOverlayView: NSViewRepresentable {
    
    typealias NSViewType = ImageAnalysisOverlayView
    
    let analysis: ImageAnalysis
    
    
    func makeNSView(context: Context) -> ImageAnalysisOverlayView {
        
        let nsView = ImageAnalysisOverlayView()
        nsView.preferredInteractionTypes = .textSelection
        nsView.analysis = self.analysis
        nsView.selectableItemsHighlighted = true
        
        return nsView
    }
    
    
    func updateNSView(_ nsView: ImageAnalysisOverlayView, context: Context) {
        
    }
}


private extension NSImage {
    
    var isPortrait: Bool {
        
        self.size.width >= self.size.height
    }
}


// MARK: - Preview

#Preview {
    LiveTextInsertionView(image: NSApp.applicationIconImage, length: 200) { _ in }
}
