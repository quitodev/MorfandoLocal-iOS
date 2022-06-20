//
//  BookingSectorRowView.swift
//  MorfandoLocal
//
//  Created by Quito Dev on 01/01/2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct BookingSectorRowView: View {
    
    var bookingSector: BookingSectorData
    var isSelected: Bool
    
    var body: some View {
        VStack {
            sectorImageView
            sectorNameView
        }.padding(5)
    }
}

struct BookingSectorRowView_Previews: PreviewProvider {
    static var previews: some View {
        BookingSectorRowView(bookingSector: BookingSectorData(), isSelected: false)
    }
}

extension BookingSectorRowView {
    private var sectorImageView: some View {
        VStack {
            if bookingSector.sector_image == Constants.empty {
                Image(Constants.imageSector).circleImage(width: 220, height: 220, isSelected: isSelected)
            } else {
                WebImage(url: URL(string: bookingSector.sector_image)).placeholder { ProgressView() }
                    .circleWebImage(width: 220, height: 220, isSelected: isSelected)
            }
        }
    }
    
    private var sectorNameView: some View {
        VStack {
            Text(bookingSector.sector_name).font(.system(size: 20, weight: .semibold, design: .rounded)).foregroundColor(isSelected ? Constants.salmonRegular : .white)
        }
    }
}
