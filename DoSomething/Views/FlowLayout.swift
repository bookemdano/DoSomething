//
//  FlowLayout.swift
//  MacLab
//
//  Created by Daniel Francis on 1/10/25.
//

import SwiftUICore
import SwiftUI

struct FlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    private let items: Data
    private let spacing: CGFloat
    private let content: (Data.Element) -> Content
    
    init(items: Data, spacing: CGFloat, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.items = items
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            wrapContent(in: geometry.size)
        }
    }
    
    private func wrapContent(in size: CGSize) -> some View {
        var width: CGFloat = 0
        var rows: [[Data.Element]] = [[]]
        
        for item in items {
            let itemSize = CGSize(width: 80, height: 30) // Customize item size
            if width + itemSize.width + spacing > size.width {
                rows.append([item])
                width = itemSize.width + spacing
            } else {
                rows[rows.count - 1].append(item)
                width += itemSize.width + spacing
            }
        }

        
        return ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: spacing) {
                ForEach(rows, id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(row, id: \.self) { item in
                            content(item)
                        }
                    }
                }
            }
            .frame(maxHeight: size.height)
        }
    }
}
