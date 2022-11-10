//
//  ErrorTips.swift
//  MovieDB
//
//  Created by allie on 27/7/2022.
//

import SwiftUI

struct ErrorTips: View {
    let error: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.red)
            Text(error)
        }
    }
}

struct ErrorTips_Previews: PreviewProvider {
    static var previews: some View {
        ErrorTips(error: "Sample error")
    }
}
