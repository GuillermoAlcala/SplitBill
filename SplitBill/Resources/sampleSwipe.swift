//
//  sampleSwipe.swift
//  SplitBill
//
//  Created by GuillermoChaconAlcala on 30/05/26.
//

import Foundation
//
//  View+CustomSwipeActions.swift
//  SplitBill
//

import SwiftUI

extension View {
    /// Swipe genérico que acepta cualquier conjunto de botones.
    /// Uso:
    /// ```
    /// .customSwipeActions {
    ///     SwipeButton.delete { delete(split) }
    ///     SwipeButton.edit   { edit(split) }
    /// }
    /// ```
    func customSwipeActions<Content: View>(
        edge: HorizontalEdge = .trailing,
        allowsFullSwipe: Bool = false,
        @ViewBuilder content: () -> Content
    ) -> some View {
        self.swipeActions(edge: edge, allowsFullSwipe: allowsFullSwipe) {
            content()
        }
    }
}

/// Botones pre-configurados para el swipe.
/// Encapsula estilo + animación para que sea consistente en toda la app.
struct SwipeButton: View {
    let title: String
    let systemImage: String
    let tint: Color
    let role: ButtonRole?
    let action: () -> Void
    
    var body: some View {
        Button(role: role) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                action()
            }
        } label: {
            Label(title, systemImage: systemImage)
        }
        .tint(tint)
    }
    
    // MARK: - Botones pre-definidos
    
    static func delete(action: @escaping () -> Void) -> SwipeButton {
        SwipeButton(
            title: "Delete",
            systemImage: "trash",
            tint: .pink,
            role: .destructive,
            action: action
        )
    }
    
    static func edit(action: @escaping () -> Void) -> SwipeButton {
        SwipeButton(
            title: "Edit",
            systemImage: "pencil",
            tint: .indigo,
            role: nil,
            action: action
        )
    }
    
    static func duplicate(action: @escaping () -> Void) -> SwipeButton {
        SwipeButton(
            title: "Duplicate",
            systemImage: "doc.on.doc",
            tint: .orange,
            role: nil,
            action: action
        )
    }
    
    static func share(action: @escaping () -> Void) -> SwipeButton {
        SwipeButton(
            title: "Share",
            systemImage: "square.and.arrow.up",
            tint: .blue,
            role: nil,
            action: action
        )
    }
}
// como se usa directo en el Foreach
//ForEach(splitQuery) { split in
//    rowSplit(split: split)
//        .customSwipeActions {
//            SwipeButton.delete { deleteRow(split) }
//            SwipeButton.edit   { editRow(split) }
//            SwipeButton.share  { shareRow(split) }
//        }
//}
