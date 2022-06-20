//
//  BookingView.swift
//  MorfandoLocal
//
//  Created by Quito Dev on 01/01/2022.
//

import SwiftUI

struct BookingView: View {
    
    // MARK: - VIEW MODEL
    @ObservedObject private var bookingViewModel: BookingViewModel
    
    // MARK: - BOOLEANS
    @State private var isShowingAnimation = true
    @State private var isTouchingDays = false
    @State private var isShowingDays = false
    @State private var isShowingHours = false
    @State private var isStartingDetail = false
    
    // MARK: - VARIABLES
    @EnvironmentObject private var user: User
    @State private var sectorPicked = BookingSectorData()
    @State private var dayPicked = ""
    @State private var hourPicked = BookingBooking()
    @State private var tablesAvailable = [""]
    
    init(userData: User) {
        bookingViewModel = BookingViewModel()
        bookingViewModel.getBookings(placeId: userData.place_id, userId: userData.user_id, userName: userData.user_name)
    }
    
    var body: some View {
        ZStack {
            if bookingViewModel.successGetBookings.bookings.isEmpty {
                CustomProgressView()
            } else {
                ScrollView {
                    ScrollViewReader { scrollViewReader in
                        VStack(alignment: .leading) {
                            // MARK: - HEADER
                            sectorsView
                            
                            // MARK: - BODY
                            daysView
                            
                            // MARK: - FOOTER
                            hoursView
                        }
                        .padding()
                        .id(Constants.scroll)
                        .onChange(of: isTouchingDays, perform: { target in
                            withAnimation { scrollViewReader.scrollTo(Constants.scroll, anchor: isTouchingDays ? .bottomTrailing : .topTrailing) }
                        })
                        .onAppear {
                            isShowingAnimation = true
                            isTouchingDays = false
                            isShowingDays = false
                            isShowingHours = false
                            
                            sectorPicked = BookingSectorData()
                            dayPicked = ""
                            
                            bookingViewModel.getBookings(placeId: user.place_id, userId: user.user_id, userName: user.user_name)
                            withAnimation(.easeOut(duration: 0.3)) { isShowingAnimation = false }
                        }
                        .onDisappear { bookingViewModel.removeListeners() }
                        .opacity(isShowingAnimation ? 0 : 1)
                    }
                }
            }
            
            // MARK: - DATA SOURCE RESPONSE
            dataSourceResponseView
            
            // MARK: - NAVIGATION
            navigationView
        }
        .blackZStack()
    }
}

struct BookingView_Previews: PreviewProvider {
    static var previews: some View {
        BookingView(userData: User()).environmentObject(User())
    }
}

extension BookingView {
    private var sectorsView: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "house").iconWhiteImage()
                Text("Elegí un sector del lugar").titleWhiteText()
            }
            ScrollView(.horizontal) {
                HStack {
                    ForEach(bookingViewModel.successGetBookings.sectors, id: \.self) { sector in
                        Button {
                            withAnimation {
                                isShowingDays = true
                                isShowingHours = false
                                isTouchingDays = false
                                dayPicked = ""
                            }
                            sectorPicked = sector
                        } label: { BookingSectorRowView(bookingSector: sector, isSelected: sectorPicked == sector) }
                    }
                }
            }
        }
        .padding(.bottom, 50)
    }
    
    private var daysView: some View {
        VStack(alignment: .leading) {
            if isShowingDays {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "calendar").iconWhiteImage()
                        Text("Ahora, elegí un día").titleWhiteText()
                    }
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(Array(bookingViewModel.successGetBookings.days.enumerated()), id: \.offset) { index, day in
                                Button {
                                    withAnimation {
                                        isTouchingDays = true
                                        isShowingHours = true
                                    }
                                    dayPicked = day
                                } label: { BookingDaysRowView(bookingDays: day, isSelected: dayPicked == day) }
                            }
                        }
                    }
                }
                .padding(.bottom, 50)
            }
        }
    }
    
    private var hoursView: some View {
        VStack(alignment: .leading) {
            if isShowingHours {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "clock").iconWhiteImage()
                        Text("Por último, elegí un horario").titleWhiteText()
                    }
                    if bookingViewModel.successGetBookings.bookings.filter({
                        $0.schedule.contains(dayPicked) && $0.sector_id.contains(sectorPicked.sector_id)
                    }).isEmpty {
                        Text("Ups! Ya no quedan horarios disponibles para el día elegido...").emptyText().transition(.scale)
                    } else {
                        VStack {
                            ScrollView {
                                ForEach(bookingViewModel.successGetBookings.bookings.filter({
                                    $0.schedule.contains(dayPicked) && $0.sector_id.contains(sectorPicked.sector_id)
                                }), id: \.self) { booking in
                                    Button {
                                        isStartingDetail = true
                                        var bookingUpdated = booking
                                        bookingUpdated.booking_limit = bookingViewModel.getBookingLimit(bookingBooking: booking, table: nil)
                                        hourPicked = bookingUpdated
                                        tablesAvailable = bookingViewModel.getTablesAvailable(bookingBooking: bookingUpdated)
                                    } label: { BookingHoursRowView(bookingBooking: booking) }
                                }
                            }
                        }.frame(height: 300).transition(.scale)
                    }
                }
                .padding(.bottom, 10)
            }
        }
    }
    
    private var dataSourceResponseView: some View {
        VStack {
            if !bookingViewModel.failureGetBookings.isEmpty {
                CustomAlertView(description: bookingViewModel.failureGetBookings)
            }
        }
    }
    
    private var navigationView: some View {
        VStack {
            NavigationLink(isActive: $isStartingDetail) {
                BookingDetailView(viewModel: bookingViewModel, booking: hourPicked, tables: tablesAvailable)
            } label: { EmptyView() }.isDetailLink(false)
        }
    }
}
