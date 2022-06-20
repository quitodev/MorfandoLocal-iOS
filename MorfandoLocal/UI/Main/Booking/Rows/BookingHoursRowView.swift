//
//  BookingScheduleRowView.swift
//  MorfandoLocal
//
//  Created by Quito Dev on 01/01/2022.
//

import SwiftUI

struct BookingHoursRowView: View {
    
    var bookingBooking: BookingBooking
    
    var body: some View {
        ZStack {
            backgroundView
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    scheduleView
                    tablesView
                }
                Spacer()
                iconView
            }.padding(.leading, 15).padding(.trailing, 15).padding(.top, 10).padding(.bottom, 10)
        }.cornerRadius(10)
    }
}

struct BookingHoursRowView_Previews: PreviewProvider {
    static var previews: some View {
        BookingHoursRowView(bookingBooking: BookingBooking())
    }
}

extension BookingHoursRowView {
    private var backgroundView: some View {
        VStack {
            Constants.grayDark
        }
    }
    
    private var scheduleView: some View {
        VStack {
            Text(bookingBooking.schedule).font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(Constants.creamLight)
        }
    }
    
    private var tablesView: some View {
        VStack {
            if Int(bookingBooking.tables_count) == 1 {
                Text("Queda 1 mesa").foregroundColor(Constants.salmonDark)
            } else {
                Text("Quedan \(bookingBooking.tables_count) mesas").foregroundColor(Int(bookingBooking.tables_count)! < 3 ? Constants.salmonDark : .green)
            }
        }
    }
    
    private var iconView: some View {
        VStack {
            Text("¡Reservá!").font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(Constants.salmonRegular)
        }
    }
}
