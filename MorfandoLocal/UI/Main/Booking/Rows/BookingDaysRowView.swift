//
//  BookingDayRowView.swift
//  MorfandoLocal
//
//  Created by Quito Dev on 01/01/2022.
//

import SwiftUI

struct BookingDaysRowView: View {
    
    var bookingDays: String
    var isSelected: Bool
    
    var body: some View {
        ZStack {
            Spacer()
            backgroundView
            VStack {
                Spacer()
                nameDayView
                Spacer()
                numberDayView
                Spacer()
                nameMonthView
                Spacer()
            }.frame(width: 50).padding(8)
            Spacer()
        }.cornerRadius(10)
    }
}

struct BookingDaysRowView_Previews: PreviewProvider {
    static var previews: some View {
        BookingDaysRowView(bookingDays: "Lun 01 Ene", isSelected: false)
    }
}

extension BookingDaysRowView {
    private var backgroundView: some View {
        VStack {
            isSelected ? Constants.grayRegular : Constants.grayDark
        }
    }
    
    private var nameDayView: some View {
        VStack {
            Text(bookingDays.prefix(3)).font(.system(size: 18, weight: .bold, design: .rounded)).foregroundColor(Constants.salmonRegular)
        }
    }
    
    private var numberDayView: some View {
        VStack {
            Text(bookingDays.prefix(6).suffix(2)).font(.system(size: 30, weight: .bold, design: .rounded)).foregroundColor(Constants.creamDark)
        }
    }
    
    private var nameMonthView: some View {
        VStack {
            Text(bookingDays.suffix(3)).font(.system(size: 18, weight: .bold, design: .rounded)).foregroundColor(Constants.creamLight)
        }
    }
}
