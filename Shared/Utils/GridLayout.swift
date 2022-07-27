//
//  GridLayout.swift
//  MovieDB
//
//  Created by allie on 27/7/2022.
//
import SwiftUI

/// 等宽铺满容器的 Grid Layout
/// 根据 estimatedItemWidth 动态计算 column 数
struct GridLayout: Layout {
    
    /// 每个 item 预估的宽度，或者说最大宽度
    var estimatedItemWidth: CGFloat = 375
    
    var verticalSpacing: CGFloat = 10
    var horizontalSpacing: CGFloat = 10
    
    private func getRects(subviews: Subviews, totalWidth: CGFloat?) -> [CGRect] {
        guard let totalWidth else { return [] }

        let columns = (totalWidth / estimatedItemWidth).rounded(.up)
        let itemWidth = ((totalWidth - (horizontalSpacing * (columns - 1))) / columns).rounded(.down)
        
        return subviews.indices.reduce([CGRect]()) { rects, index in
            let previousRect = rects.last ?? .zero
            let itemHeight = subviews[index].sizeThatFits(.init(width: itemWidth, height: nil)).height
            var rect = CGRect(origin: .zero, size: .init(width: itemWidth, height: itemHeight))
            if previousRect.maxX + horizontalSpacing + itemWidth > totalWidth {
                // 换行
                let maxHeight = rects.map(\.height).max() ?? 0
                rect.origin = .init(x: 0, y: previousRect.minY + maxHeight + (rects.isEmpty ? 0 : verticalSpacing))
            } else {
                // 同一行
                rect.origin = .init(
                    x: previousRect.maxX + (rects.isEmpty ? 0 : horizontalSpacing),
                    y: previousRect.minY
                )            }
            return rects + [rect]
        }
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rects = getRects(subviews: subviews, totalWidth: proposal.width)
        return .init(width: proposal.width ?? 0, height: rects.last?.maxY ?? 0)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rects = getRects(subviews: subviews, totalWidth: proposal.width)
        
        rects.indices.forEach { index in
            let rect = rects[index]
            let view = subviews[index]
            view.place(
                at: .init(x: rect.minX, y: rect.minY + bounds.minY),
                proposal: .init(rect.size)
            )
        }
    }
}

import Kingfisher
struct GridLayout_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            Text("GridLayout")
            GridLayout(estimatedItemWidth: 320, verticalSpacing: 5, horizontalSpacing: 5).callAsFunction {
                ForEach(mockMovies[0].images?.backdrops ?? []) { image in
                    VStack {
                        KFImage(URL(string: image.filePath?.imagePath(.face(w: 500, h: 282)) ?? ""))
                            .resizable()
                            .aspectRatio(500/282, contentMode: .fill)
                        Text(image.filePath ?? "")
                        Text("\(image.width ?? 0) * \(image.height ?? 0)")
                    }
                }
            }
        }
        .frame(width: 720)
    }
}
