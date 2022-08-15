//
//  ErrorTips.swift
//  MovieDB
//
//  Created by allie on 27/7/2022.
//

import SwiftUI

struct ErrorTips: View {
    let error: Error
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.red)
            Text((error as? AppError)?.localizedDescription ?? error.localizedDescription)
        }
    }
}

struct ErrorTips_Previews: PreviewProvider {
    static var previews: some View {
        ErrorTips(error: AppError.sample("Sample error"))
    }
}
