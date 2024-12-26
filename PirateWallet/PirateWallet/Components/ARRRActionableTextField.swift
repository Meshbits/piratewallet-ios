//
//  ARRRActionableTextField.swift
//  PirateWallet
//
//  Created by Lokesh on 05/12/24.
//

import SwiftUI
struct ARRRActionableTextField: View {
    
    var title: String
    var placeholder: String = ""
    var accessoryIcon: Image?
    var action: (() -> Void)?
    var contentType: UITextContentType?
    var keyboardType: UIKeyboardType
    var autocorrect = false
    var autocapitalize = false
    var subtitleView: AnyView
    var onCommit: () -> Void
    var onEditingChanged: (Bool) -> Void
    var inactiveColor: Color = .zGray2
    var activeColor: Color
    
    @Binding var text: String
    
    
    
    var accessoryView: AnyView {
        if let img = accessoryIcon, let action = action {
            return AnyView(
                Button(action: {
                    action()
                }) {
                    img.resizable()
                }
            )
        } else {
            return AnyView(EmptyView())
        }
    }
    
    var isActive: Bool {
        text.count > 0
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center) {
                Text(title)
                    .foregroundColor(isActive ? .zLightGray : .white)
                
                TextField(placeholder,
                          text: $text,
                          onEditingChanged: self.onEditingChanged,
                          onCommit: self.onCommit)
                
                    .accentColor(.white)
                    .foregroundColor(Color.white)
                    .textContentType(contentType)
                    .keyboardType(keyboardType)
                    .autocapitalization(autocapitalize ? .none : .sentences)
                    .disableAutocorrection(!autocorrect)
                    
                accessoryView
                    .frame(width: 25, height: 25)
                    .padding(.bottom,4)
            }.overlay(
                Baseline().stroke(isActive ? activeColor : inactiveColor ,lineWidth: 1)
            )
            .font(.body)
                
            subtitleView
        }
        
    }
    
    init(title: String,
         subtitleView: AnyView? = nil,
         contentType: UITextContentType? = nil,
         keyboardType: UIKeyboardType  = .default,
         binding: Binding<String>,
         action: (() -> Void)? = nil,
         accessoryIcon: Image? = nil,
         activeColor: Color = .zAmberGradient2,
         onEditingChanged: @escaping (Bool) -> Void,
         onCommit: @escaping () -> Void) {
        
        self.title = title
        self.accessoryIcon = accessoryIcon
        self.action = action
        if let subtitle = subtitleView {
            self.subtitleView = AnyView(subtitle)
        } else {
            self.subtitleView = AnyView(EmptyView())
        }
        self.contentType = contentType
        self.keyboardType = keyboardType
        self._text = binding
        self.onCommit = onCommit
        self.onEditingChanged = onEditingChanged
        self.activeColor = activeColor
    }
    
}

