//
//  CharacterCountOptionsSheetView.swift
//
//  CotEditor
//  https://coteditor.com
//
//  Created by 1024jp on 2022-07-12.
//
//  ---------------------------------------------------------------------------
//
//  © 2022-2025 1024jp
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

struct CharacterCountOptionsSheetView: View {
    
    var completionHandler: () -> Void
    
    var dismiss: () -> Void = { }
    
    
    // MARK: View
    
    var body: some View {
        
        VStack(spacing: 20) {
            CharacterCountOptionsView()
            
            HStack {
                HelpLink(anchor: "howto_count_characters")
                
                Spacer()
                
                SubmitButtonGroup(String(localized: "Start", table: "AdvancedCharacterCount", comment: "button label")) {
                    self.completionHandler()
                    self.dismiss()
                } cancelAction: {
                    self.dismiss()
                }
            }
        }
        .fixedSize()
        .scenePadding()
    }
}


// MARK: - Preview

#Preview {
    CharacterCountOptionsSheetView { }
}
