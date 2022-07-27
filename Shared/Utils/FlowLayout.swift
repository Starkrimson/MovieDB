//
//  FlowLayout.swift
//  MovieDB
//
//  Created by allie on 26/7/2022.
//

import Foundation
import SwiftUI

/// Flow Layout：排滿自動換行的自訂 Layout 教學 - ChaoCode
/// https://www.youtube.com/watch?v=v8Epp_8ZAOc&list=PLXM8k1EWy5ki1c36h_0hTWgMwt3SRzqVX&index=3
struct FlowLayout: Layout {
    var alignment: TextAlignment = .leading
    var verticalSpacing: CGFloat = 10
    var horizontalSpacing: CGFloat = 10
        
    struct Row {
        var viewRects: [CGRect] = []
        
        var width: CGFloat { viewRects.last?.maxX ?? 0 }
        var height: CGFloat { viewRects.map(\.height).max() ?? 0 }
        
        func getStartX(in bounds: CGRect, alignment: TextAlignment) -> CGFloat {
            switch alignment {
            case .leading:
                return bounds.minX
            case .center:
                return bounds.minX + (bounds.width - width) / 2
            case .trailing:
                return bounds.maxX - width
            }
        }
    }
    
    private func getRows(subviews: Subviews, totalWidth: CGFloat?) -> [Row] {
        guard let totalWidth, !subviews.isEmpty else { return [] }
        var rows = [Row()]
        let proposal = ProposedViewSize(width: totalWidth, height: nil)
        
        subviews.indices.forEach { index in
            let view = subviews[index]
            let size = view.sizeThatFits(proposal)
            let previousRect = rows.last?.viewRects.last ?? .zero
            let hSpacing = rows.last!.viewRects.isEmpty ? 0 : horizontalSpacing

            switch previousRect.maxX + hSpacing + size.width > totalWidth {
            case true: // 换行
                let rect = CGRect(
                    origin: .init(x: 0, y: previousRect.minY + (rows.last?.height ?? 0) + verticalSpacing),
                    size: size
                )
                rows.append(Row(viewRects: [rect]))
            case false: // 同一行
                let rect = CGRect(
                    origin: .init(x: previousRect.maxX + hSpacing, y: previousRect.minY),
                    size: size
                )
                rows[rows.count - 1].viewRects.append(rect)
            }
        }
        
        return rows
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = getRows(subviews: subviews, totalWidth: proposal.width)
        return .init(
            width: rows.map(\.width).max() ?? 0,
            height: rows.last?.viewRects.map(\.maxY).max() ?? 0
        )
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = getRows(subviews: subviews, totalWidth: proposal.width)
        var index = 0
        rows.forEach { row in
            let minX = row.getStartX(in: bounds, alignment: alignment)
            
            row.viewRects.forEach { rect in
                let view = subviews[index]
                defer { index += 1 }
                
                view.place(
                    at: .init(x: rect.minX + minX,
                              y: rect.minY + bounds.minY),
                    proposal: .init(rect.size)
                )
            }
        }
    }
}

struct FlowLayout_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            FlowLayout(alignment: .trailing, verticalSpacing: 15, horizontalSpacing: 15).callAsFunction {
                ForEach("Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.".split(separator: " "), id: \.self) { e in
                    Text(e)
                        .padding()
                        .background(Color.purple)
                }
            }
            .background(Color.secondary)
        }
    }
}
