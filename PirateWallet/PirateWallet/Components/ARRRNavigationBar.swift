//
//  ARRRNavigationBar.swift
//  PirateWallet
//
//  Created by Lokesh on 17/09/24.
//

import SwiftUI
struct ARRRNavigationBar<LeadingContent: View, HeadingContent: View, TrailingContent: View>: View {
    
    var leadingItem: LeadingContent
    var headerItem: HeadingContent
    var trailingItem: TrailingContent
    
    init(@ViewBuilder leadingItem: () -> LeadingContent,
                      @ViewBuilder headerItem: () -> HeadingContent,
                      @ViewBuilder trailingItem: () -> TrailingContent) {
        self.leadingItem = leadingItem()
        self.headerItem = headerItem()
        self.trailingItem = trailingItem()
    }
    
    var body: some View {
        HStack {
            leadingItem
            Spacer()
            headerItem
            Spacer()
            trailingItem
        }
        .padding(.bottom,10)
    }
}

extension View {
    func ARRRNavigationBar<LeadingContent: View,
                            HeadingContent: View,
                            TrailingContent: View>(
                                                    @ViewBuilder leadingItem: () -> LeadingContent,
                                                    @ViewBuilder headerItem: () -> HeadingContent,
                                                    @ViewBuilder trailingItem: () -> TrailingContent) -> some View {
        self.modifier(ARRRNavigationBarModifier(leadingItem:
                                                    leadingItem,
                                                 headerItem: headerItem,
                                                 trailingItem: trailingItem)
        )
    }
}
struct ARRRNavigationBarModifier<LeadingContent: View, HeadingContent: View, TrailingContent: View>: ViewModifier {
    var leadingItem: LeadingContent
    var headerItem: HeadingContent
    var trailingItem: TrailingContent
    
    init(@ViewBuilder leadingItem: () -> LeadingContent,
         @ViewBuilder headerItem: () -> HeadingContent,
         @ViewBuilder trailingItem: () -> TrailingContent) {
        self.leadingItem = leadingItem()
        self.headerItem = headerItem()
        self.trailingItem = trailingItem()
    }
    
    func body(content: Content) -> some View {
        ZStack {
            ARRRBackground().edgesIgnoringSafeArea(.all)
            VStack {
                ARRRNavigationBar(leadingItem: { leadingItem },
                                   headerItem: { headerItem },
                                   trailingItem: { trailingItem } )
                    .padding(.horizontal, 25)
                content
            }
        }
    }
}
