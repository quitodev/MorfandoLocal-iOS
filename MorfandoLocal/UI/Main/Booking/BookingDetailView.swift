//
//  BookingDetailView.swift
//  MorfandoLocal
//
//  Created by Quito Dev on 01/01/2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct BookingDetailView: View {
    
    // MARK: - VIEW MODEL
    @ObservedObject private var bookingViewModel: BookingViewModel
    
    // MARK: - BOOLEANS
    @State private var isScrollingTop = false
    @State private var isChoosingPeople = false
    @State private var isBookingConfirmed = false
    @State private var isShowingTableAlert = false
    
    // MARK: - VARIABLES
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var user: User
    @State private var tables: [String] = []
    @State private var bookingLimit: Int?
    @State private var comments = ""
    @State private var people = 1.0
    private var bookingBooking: BookingBooking
    private var tablesAvailable: [String]
    
    init(viewModel: BookingViewModel, booking: BookingBooking, tables: [String]) {
        bookingViewModel = viewModel
        bookingBooking = booking
        tablesAvailable = tables
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                ScrollViewReader { scrollViewReader in
                    ZStack {
                        VStack {
                            // MARK: - HEADER
                            imageView
                            
                            VStack {
                                // MARK: - BODY
                                VStack {
                                    titleView
                                    scheduleView
                                    placeNameView
                                    sectorNameView
                                    userNameView
                                    peopleView
                                    tablesView
                                    limitView
                                    commentsView
                                }
                                
                                // MARK: - FOOTER
                                VStack {
                                    continueView
                                    backView
                                    limitAdviceView
                                }
                            }.padding()
                        }
                    }.grayZStack()
                    .id(Constants.scroll)
                    .onChange(of: isScrollingTop, perform: { target in
                        scrollViewReader.scrollTo(Constants.scroll, anchor: .top)
                    })
                }
            }
            
            // MARK: - DATA SOURCE RESPONSE
            dataSourceResponseView
        }.blackZStack()
    }
}

struct BookingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        BookingDetailView(viewModel: BookingViewModel(), booking: BookingBooking(), tables: [""]).environmentObject(User())
    }
}

extension BookingDetailView {
    private var imageView: some View {
        VStack {
            if bookingBooking.sector_image == Constants.empty {
                Image(Constants.imageSector).rectangleImage(width: UIScreen.main.bounds.width - 30, height: 270)
            } else {
                WebImage(url: URL(string: bookingBooking.sector_image)).placeholder {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }.rectangleWebImage(width: UIScreen.main.bounds.width - 30, height: 270)
            }
        }
    }
    
    private var titleView: some View {
        VStack {
            Text("Confirmá tu reserva").titleBlackText()
        }
    }
    
    private var scheduleView: some View {
        VStack {
            HStack {
                Image(systemName: "clock.fill").iconSalmonRegularImage()
                Text("Día y horario").subtitleGrayText()
            }.padding(.top, 15)
            Text(bookingBooking.schedule).descriptionBlackText()
        }
    }
    
    private var placeNameView: some View {
        VStack {
            HStack {
                Image(systemName: "pin.fill").iconSalmonRegularImage()
                Text("Lugar").subtitleGrayText()
            }.padding(.top, 15)
            Text(bookingBooking.place_name).descriptionBlackText()
        }
    }
    
    private var sectorNameView: some View {
        VStack {
            HStack {
                Image(systemName: "house.fill").iconSalmonRegularImage()
                Text("Sector").subtitleGrayText()
            }.padding(.top, 15)
            Text(bookingBooking.sector_name).descriptionBlackText()
        }
    }
    
    private var userNameView: some View {
        VStack {
            HStack {
                Image(systemName: "person.crop.circle.fill").iconSalmonRegularImage()
                Text("A nombre de").subtitleGrayText()
            }.padding(.top, 15)
            Text(bookingBooking.user_name).descriptionBlackText()
        }
    }
    
    private var peopleView: some View {
        VStack {
            HStack {
                Image(systemName: "person.3.fill").iconSalmonRegularImage()
                Text("Reserva para").subtitleGrayText()
            }.padding(.top, 15)
            Slider(
                 value: $people,
                 in: 1...Double(bookingBooking.booking_people),
                 step: 1,
                 onEditingChanged: { editing in
                     isChoosingPeople = editing
                 }
            ).frame(width: UIScreen.main.bounds.width - 100)
            if people == 1.0 {
                Text("1 persona").descriptionBlueText(isChoosing: isChoosingPeople)
            } else { Text("\(Int(people)) personas").descriptionBlueText(isChoosing: isChoosingPeople) }
        }
    }
    
    private var tablesView: some View {
        VStack {
            HStack {
                Image(systemName: "fork.knife").iconSalmonRegularImage()
                Text(isBookingConfirmed ? "Mesas" : "Mesas disponibles").subtitleGrayText()
            }.padding(.top, 15)
            VStack(alignment: .leading) {
                ScrollView(.horizontal) {
                    HStack {
                        if isBookingConfirmed {
                            ForEach(tables, id: \.self) { table in
                                TagButtonView(
                                    data: table,
                                    imageRight: "checkmark.circle",
                                    isEnabled: false,
                                    isSelected: true
                                )
                            }
                        } else {
                            ForEach(tablesAvailable.sorted(by: {
                                Int($0.replacingOccurrences(of: "Mesa ", with: ""))! < Int($1.replacingOccurrences(of: "Mesa ", with: ""))!
                            }), id: \.self) { table in
                                Button {
                                    if tables.contains(table) {
                                        tables = tables.filter({ $0 != table })
                                        
                                        if tables.filter({ $0 != table }).count > 0 {
                                            var listLimit: [Int] = []
                                            tables.filter({ $0 != table }).forEach { tableSelected in
                                                listLimit.append(bookingViewModel.getBookingLimit(bookingBooking: bookingBooking, table: tableSelected))
                                            }
                                            bookingLimit = listLimit.min()! < bookingBooking.booking_limit ? listLimit.min() : nil
                                        } else {
                                            bookingLimit = nil
                                        }
                                    } else {
                                        tables.append(table)
                                        
                                        let limit = bookingViewModel.getBookingLimit(bookingBooking: bookingBooking, table: table)
                                        bookingLimit = limit < bookingBooking.booking_limit ? limit : bookingLimit
                                    }
                                    
                                } label: {
                                    TagButtonView(
                                        data: table,
                                        imageRight: tables.contains(table) ? "checkmark.circle" : "xmark.circle",
                                        isEnabled: true,
                                        isSelected: tables.contains(table)
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var limitView: some View {
        VStack {
            HStack {
                Image(systemName: "person.crop.circle.badge.clock").iconSalmonRegularImage()
                Text("Tiempo de reserva").subtitleGrayText()
            }.padding(.top, 15)
            if bookingLimit == nil {
                switch bookingBooking.booking_limit {
                case 1:
                    if bookingBooking.booking_limit < bookingViewModel.successGetBookings.ubication.booking_limit {
                        Text("1 hora").descriptionRedText()
                    } else {
                        Text("1 hora").descriptionBlackText()
                    }
                case 2:
                    if bookingBooking.booking_limit < bookingViewModel.successGetBookings.ubication.booking_limit {
                        Text("1 hora y 30 minutos").descriptionRedText()
                    } else {
                        Text("1 hora y 30 minutos").descriptionBlackText()
                    }
                case 3:
                    if bookingBooking.booking_limit < bookingViewModel.successGetBookings.ubication.booking_limit {
                        Text("2 horas").descriptionRedText()
                    } else {
                        Text("2 horas").descriptionBlackText()
                    }
                case 4:
                    if bookingBooking.booking_limit < bookingViewModel.successGetBookings.ubication.booking_limit {
                        Text("2 horas y 30 minutos").descriptionRedText()
                    } else {
                        Text("2 horas y 30 minutos").descriptionBlackText()
                    }
                case 5:
                    if bookingBooking.booking_limit < bookingViewModel.successGetBookings.ubication.booking_limit {
                        Text("3 horas").descriptionRedText()
                    } else {
                        Text("3 horas").descriptionBlackText()
                    }
                default:
                    if bookingBooking.booking_limit < bookingViewModel.successGetBookings.ubication.booking_limit {
                        Text("30 minutos").descriptionRedText()
                    } else {
                        Text("30 minutos").descriptionBlackText()
                    }
                }
            } else {
                switch bookingLimit {
                case 1:
                    if bookingLimit! < bookingViewModel.successGetBookings.ubication.booking_limit {
                        Text("1 hora").descriptionRedText()
                    } else {
                        Text("1 hora").descriptionBlackText()
                    }
                case 2:
                    if bookingLimit! < bookingViewModel.successGetBookings.ubication.booking_limit {
                        Text("1 hora y 30 minutos").descriptionRedText()
                    } else {
                        Text("1 hora y 30 minutos").descriptionBlackText()
                    }
                case 3:
                    if bookingLimit! < bookingViewModel.successGetBookings.ubication.booking_limit {
                        Text("2 horas").descriptionRedText()
                    } else {
                        Text("2 horas").descriptionBlackText()
                    }
                case 4:
                    if bookingLimit! < bookingViewModel.successGetBookings.ubication.booking_limit {
                        Text("2 horas y 30 minutos").descriptionRedText()
                    } else {
                        Text("2 horas y 30 minutos").descriptionBlackText()
                    }
                case 5:
                    if bookingLimit! < bookingViewModel.successGetBookings.ubication.booking_limit {
                        Text("3 horas").descriptionRedText()
                    } else {
                        Text("3 horas").descriptionBlackText()
                    }
                default:
                    if bookingLimit! < bookingViewModel.successGetBookings.ubication.booking_limit {
                        Text("30 minutos").descriptionRedText()
                    } else {
                        Text("30 minutos").descriptionBlackText()
                    }
                }
            }
        }
    }
    
    private var commentsView: some View {
        VStack {
            HStack {
                Image(systemName: "text.bubble.fill").iconSalmonRegularImage()
                Text("Comentarios (opcional)").subtitleGrayText()
            }.padding(.top, 15)
            if isBookingConfirmed {
                TextField("", text: $comments).disabledTextField(keyboard: .alphabet).onReceive(comments.publisher.collect()) {
                    comments = String($0.prefix(150))
                }
            } else {
                TextField("", text: $comments).enabledTextField(keyboard: .alphabet).placeholder(when: comments.isEmpty) {
                    Text("Algo que quieras agregar...").placeholderGrayText()
                }
            }
        }
    }
    
    private var continueView: some View {
        VStack {
            Button {
                if tables.isEmpty {
                    isShowingTableAlert = true
                } else {
                    isScrollingTop.toggle()
                    isBookingConfirmed = true
                    comments = comments.isEmpty ? Constants.noInfoAdded : comments
                    
                    var bookingData = BookingBooking()
                    bookingData = bookingBooking
                    bookingData.comments = comments
                    bookingData.booking_limit = bookingLimit ?? bookingBooking.booking_limit
                    bookingData.people = Int(people)
                    bookingData.tables = tables
                    bookingData.tables_count = "\(tables.count)"
                    
                    getQRCode(bookingData: bookingData, bookingId: bookingBooking.booking_id)
                }
            } label: {
                HStack {
                    Image(systemName: "checkmark").buttonImage()
                    Text("CONFIRMAR RESERVA").buttonText()
                 }.frame(width: UIScreen.main.bounds.width - 100)
            }.firstButton()
        }
    }
    
    private var backView: some View {
        VStack {
            Button {
                dismiss()
            } label: {
                HStack {
                    Image(systemName: "arrowshape.turn.up.left.fill").buttonImage()
                    Text("CERRAR").buttonText()
                 }.frame(width: UIScreen.main.bounds.width - 100)
            }.lastButton()
        }
    }
    
    private var limitAdviceView: some View {
        VStack {
            Text("El tiempo de reserva varía según horario de cierre y mesas disponibles.").subtitleGrayText().padding(.bottom, 15)
        }
    }
    
    private var dataSourceResponseView: some View {
        VStack {
            if bookingViewModel.loadingUpdateBookings {
                CustomProgressView()
            } else {
                if bookingViewModel.successUpdateBookings == Constants.success {
                    CustomConfirmView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                                bookingViewModel.successUpdateBookings = ""
                                bookingViewModel.getBookings(placeId: user.place_id, userId: user.user_id, userName: user.user_name)
                                dismiss()
                            }
                        }
                }
                if !bookingViewModel.failureUpdateBookings.isEmpty {
                    CustomAlertView(description: bookingViewModel.failureUpdateBookings)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { isBookingConfirmed = false }
                        }
                }
                
                // MARK: - SHOW ALERTS
                if isShowingTableAlert {
                    CustomAlertView(description: Constants.tableAlert)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { isShowingTableAlert = false }
                        }
                }
            }
        }
    }
    
    private func getQRCode(bookingData: BookingBooking, bookingId: String) {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            //print("ERROR QR 1")
            return
        }
        let bookingIdUpdated = "\(bookingId.components(separatedBy: "_")[2])_\(bookingId.components(separatedBy: "_")[3])_\(bookingId.components(separatedBy: "_")[4])"
        let data = bookingIdUpdated.data(using: .ascii, allowLossyConversion: false)
        filter.setValue(data, forKey: "inputMessage")
        guard let ciimage = filter.outputImage else {
            //print("ERROR QR 2")
            return
        }
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledCIImage = ciimage.transformed(by: transform)
        let uiImage = UIImage(ciImage: scaledCIImage)
        if let imageData = uiImage.jpegData(compressionQuality: 0.50) {
            bookingViewModel.setBookings(bookingBooking: bookingData, bookingQr: imageData)
        } else {
            //print("ERROR QR 3")
        }
    }
}
