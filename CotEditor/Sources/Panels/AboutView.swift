//
//  AboutView.swift
//
//  CotEditor
//  https://coteditor.com
//
//  Created by 1024jp on 2024-03-15.
//
//  ---------------------------------------------------------------------------
//
//  © 2024-2025 1024jp
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

import SwiftUI
import AppKit.NSApplication

struct AboutView: View {
    
    private enum Pane: CaseIterable {
        
        case credits
        case license
        
        var label: String {
            
            switch self {
                case .credits:
                    String(localized: "Credits", table: "About", comment: "button label")
                case .license:
                    String(localized: "Licenses", table: "About", comment: "button label")
            }
        }
    }
    
    
    @State private var pane: Pane = .credits
    
    
    var body: some View {
        
        HStack(spacing: 0) {
            VStack(spacing: 6) {
                Image(nsImage: NSApp.applicationIconImage)
                    .accessibilityLabel(String(localized: "\(Bundle.main.bundleName) icon", table: "About", comment: "%@ is application name"))
                Text(Bundle.main.bundleName)
                    .font(.title)
                Text("Version \(Bundle.main.shortVersion) (\(Bundle.main.bundleVersion))",
                     tableName: "About",
                     comment: "%1$@ is version number and %2$@ is build number")
                .textSelection(.enabled)
                
                Link(String("coteditor.com"),
                     destination: URL(string: "https://coteditor.com")!)
                .foregroundStyle(.tint)
                
                Text(Bundle.main.copyright)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
            .fixedSize()
            .accessibilitySortPriority(1)
            .scenePadding([.leading, .vertical])
            .padding(.trailing)
            .frame(minWidth: 200)
            
            Divider()
            
            VStack(spacing: 0) {
                HStack {
                    ForEach(Pane.allCases, id: \.self) { pane in
                        TabPickerButtonView(pane.label, isSelected: self.pane == pane) {
                            withAnimation {
                                self.pane = pane
                            }
                        }
                    }
                }
                .accessibilityRepresentation {
                    Picker(selection: $pane) {
                        ForEach(Pane.allCases, id: \.self) {
                            Text($0.label)
                        }
                    } label: {
                        EmptyView()
                    }
                }
                .padding(.vertical, 6)
                Divider()
                
                ScrollView(.vertical) {
                    switch self.pane {
                        case .credits:
                            CreditsView()
                        case .license:
                            LicenseView()
                    }
                }
            }
            .background()
        }
        .controlSize(.small)
        .frame(width: 540, height: 320)
    }
}


private struct TabPickerButtonView: View {
    
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    @Environment(\.colorSchemeContrast) private var contrast
    
    @State private var isHovered = false
    
    
    init(_ title: String, isSelected: Bool, action: @escaping () -> Void) {
        
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }
    
    
    var body: some View {
        
        Button(self.title, action: self.action)
            .buttonStyle(.borderless)
            .brightness(-0.2)
            .padding(.vertical, 1)
            .padding(.horizontal, 4)
            .background(.fill.opacity(self.backgroundOpacity), in: .rect(cornerRadius: 3))
            .overlay(self.contrast == .increased
                     ? RoundedRectangle(cornerRadius: 3).stroke(.tertiary)
                     : nil)
            .onHover { self.isHovered = $0 }
            .accessibilityAddTraits(self.isSelected ? .isSelected : [])
            .accessibilityRemoveTraits(self.isSelected ? [] : .isSelected)
    }
    
    
    private var backgroundOpacity: Double {
        
        if self.isHovered {
            1
        } else if self.isSelected {
            0.5
        } else {
            0
        }
    }
}


// MARK: -

private struct Credits: Decodable {
    
    struct Contributor: Decodable {
        
        var name: String
        var url: String?
    }
    
    var project: [Contributor] = []
    var original: Contributor?
    var localization: [String: [Contributor]] = [:]
    var contributors: [Contributor] = []
}


private struct CreditsView: View {
    
    @Namespace private var accessibility
    
    @State private var credits: Credits = .init()
    
    
    var body: some View {
        
        VStack(spacing: 6) {
            SectionView(String(localized: "The CotEditor Project", table: "About", comment: "section heading")) {
                ForEach(self.credits.project, id: \.name) {
                    ContributorView(contributor: $0)
                }
            }
            
            SectionView(String(localized: "Localization", table: "About", comment: "section heading")) {
                Grid(alignment: .leadingFirstTextBaseline, verticalSpacing: 4) {
                    ForEach(self.credits.localization.sorted(using: KeyPathComparator(\.key)), id: \.key) { item in
                        GridRow {
                            Text(Locale.current.localizedString(forIdentifier: item.key)!)
                                .foregroundStyle(.secondary)
                                .gridColumnAlignment(.trailing)
                                .accessibilityLabeledPair(role: .label, id: item.key, in: self.accessibility)
                            VStack(alignment: .leading, spacing: 3) {
                                ForEach(item.value, id: \.name) {
                                    ContributorView(contributor: $0)
                                }
                            }
                            .accessibilityLabeledPair(role: .content, id: item.key, in: self.accessibility)
                        }
                    }
                }
            }
            
            SectionView(String(localized: "Code Contributors", table: "About", comment: "section heading")) {
                Text(self.credits.contributors.map(\.name).sorted(using: .localized), format: .list(type: .and))
                    .textSelection(.enabled)
            }
            
            SectionView(String(localized: "Special Thanks", table: "About", comment: "section heading")) {
                Grid(alignment: .leadingFirstTextBaseline, verticalSpacing: 4) {
                    GridRow {
                        Text("original developer", tableName: "About")
                            .foregroundStyle(.secondary)
                            .gridColumnAlignment(.trailing)
                        if let original = self.credits.original {
                            ContributorView(contributor: original)
                        }
                    }
                    Text("and everyone who supports CotEditor!", tableName: "About",
                         comment: "last line of the Special Thanks section")
                }
            }
            
            Image(systemName: "dog")
                .symbolVariant(.fill)
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
            
            Text("CotEditor is an open source program\nlicensed under the Apache License, Version 2.0.", tableName: "About")
                .textSelection(.enabled)
            Link(String("https://github.com/coteditor"),
                 destination: URL(string: "https://github.com/coteditor")!)
            .foregroundStyle(.tint)
        }
        .task {
            guard
                let url = Bundle.main.url(forResource: "Credits", withExtension: "json"),
                let data = try? Data(contentsOf: url),
                let credits = try? JSONDecoder().decode(Credits.self, from: data)
            else { return assertionFailure() }
            self.credits = credits
        }
        .multilineTextAlignment(.center)
        .lineSpacing(2)
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    
    private struct SectionView<Content: View>: View {
        
        var label: String
        var content: () -> Content
        
        
        init(_ label: String, @ViewBuilder content: @escaping () -> Content) {
            
            self.label = label
            self.content = content
        }
        
        
        var body: some View {
            
            Section {
                self.content()
                    .padding(.bottom, 14)
            } header: {
                Text(self.label)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    
    private struct ContributorView: View {
        
        var contributor: Credits.Contributor
        
        
        var body: some View {
            
            HStack(spacing: 2) {
                Text(self.contributor.name)
                    .textSelection(.enabled)
                LinkButton(url: self.contributor.url ?? "")
                    .foregroundStyle(.tint)
            }
        }
    }
}


// MARK: -

private struct LicenseView: View {
    
#if SPARKLE
    private let hasSparkle = true
#else
    private let hasSparkle = false
#endif
    
    var body: some View {
        
        LazyVStack(alignment: .leading, spacing: 16) {
            Text("CotEditor uses the following awesome technologies. We are deeply grateful for those who let us use their valuable work.", tableName: "About")
                .lineSpacing(2)
            
            ItemView(name: "Yams",
                     url: "https://github.com/jpsim/Yams",
                     license: "MIT license")
            ItemView(name: "WFColorCode",
                     url: "https://github.com/1024jp/WFColorCode",
                     license: "MIT license")
            
            if self.hasSparkle {
                ItemView(name: "Sparkle",
                         url: "https://sparkle-project.org",
                         license: "MIT license",
                         description: String(localized: "only on non-AppStore version", table: "About",
                                             comment: "annotation for the Sparkle framework license"))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
    
    
    private struct ItemView: View {
        
        var name: String
        var url: String
        var license: String
        var description: String?
        
        @State private var content: String = ""
        
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .center, spacing: 4) {
                    Text(self.name)
                        .fontWeight(.semibold)
                    
                    LinkButton(url: self.url)
                        .foregroundStyle(.tint)
                    
                    if let description {
                        Text(" (\(description))")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Text(self.license)
                    .fontWeight(.medium)
                    .opacity(0.8)
                Text(self.content)
                    .foregroundStyle(.secondary)
                    .environment(\.locale, Locale(languageCode: .english))
                    .environment(\.layoutDirection, .leftToRight)
            }
            .onAppear {
                guard
                    let url = Bundle.main.url(forResource: self.name, withExtension: "txt", subdirectory: "Licenses"),
                    let string = try? String(contentsOf: url, encoding: .utf8)
                else { return assertionFailure() }
                
                self.content = string
            }
        }
    }
}


// MARK: - Preview

#Preview {
    AboutView()
}
