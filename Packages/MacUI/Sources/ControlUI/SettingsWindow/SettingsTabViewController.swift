//
//  SettingsTabViewController.swift
//  ControlUI
//
//  CotEditor
//  https://coteditor.com
//
//  Created by 1024jp on 2018-11-13.
//
//  ---------------------------------------------------------------------------
//
//  © 2018-2025 1024jp
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

final class SettingsTabViewController: NSTabViewController {
    
    // MARK: Private properties
    
    /// The user default key to store the last opened pane.
    private let lastPaneIdentifier: String = "lastPreferencesPaneIdentifier"
    
    
    // MARK: Tab View Controller Methods
    
    override var selectedTabViewItemIndex: Int {
        
        didSet {
            if self.isViewLoaded {  // avoid storing initial state
                UserDefaults.standard.setValue(self.tabViewItems[selectedTabViewItemIndex].identifier as? String, forKey: self.lastPaneIdentifier)
            }
        }
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // select last used pane
        if let identifier = UserDefaults.standard.string(forKey: self.lastPaneIdentifier),
           let index = self.tabViewItems.firstIndex(where: { $0.identifier as? String == identifier })
        {
            self.selectedTabViewItemIndex = index
        }
        
        self.title = self.tabViewItems[self.selectedTabViewItemIndex].label
    }
    
    
    override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        
        super.tabView(tabView, didSelect: tabViewItem)
        
        guard let tabViewItem else { return assertionFailure() }
        
        self.switchPane(to: tabViewItem)
    }
    
    
    // MARK: Private Methods
    
    /// Resizes the window frame to fit to the new view.
    ///
    /// - Parameter tabViewItem: The tab view item to switch.
    private func switchPane(to tabViewItem: NSTabViewItem) {
        
        guard let contentSize = tabViewItem.view?.frame.size else { return assertionFailure() }
        
        // initialize tabView's frame size
        guard let window = self.view.window else {
            self.view.frame.size = contentSize
            return
        }
        
        let label = tabViewItem.label
        let animates = !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        if animates {
            NSAnimationContext.runAnimationGroup { _ in
                self.view.isHidden = true
                window.animator().setFrame(for: contentSize)
                
            } completionHandler: { [weak self] in
                Task { @MainActor in
                    self?.view.isHidden = false
                    self?.title = label
                }
            }
        } else {
            window.setFrame(for: contentSize)
            self.title = label
        }
    }
}


private extension NSWindow {
    
    /// Updates window frame for the given contentSize.
    ///
    /// - Parameters:
    ///   - contentSize: The frame rectangle for the window content view.
    ///   - flag: Specifies whether the window redraws the views that need to be displayed.
    func setFrame(for contentSize: NSSize, display flag: Bool = false) {
        
        let frameSize = self.frameRect(forContentRect: NSRect(origin: .zero, size: contentSize)).size
        let frame = NSRect(origin: self.frame.origin, size: frameSize)
            .offsetBy(dx: 0, dy: self.frame.height - frameSize.height)
        
        self.setFrame(frame, display: flag)
    }
}
