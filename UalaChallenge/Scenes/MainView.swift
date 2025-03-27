//
//  MainView.swift
//  UalaChallenge
//
//  Created by Luis Barrios on 23/3/25.
//
import SwiftUI

struct MainView<ViewModel>:View where ViewModel: CityListViewModel {
    @StateObject private var viewModel: ViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var isListVisible: Bool = true

    init(viewModel: @autoclosure @escaping () -> ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height || UIDevice.current.userInterfaceIdiom == .pad
            ZStack {
                if let city = viewModel.selectedCity  {

                    VStack{
                        if (!isLandscape || !isListVisible) {
                            HStack {
                                Button(action: {

                                    isListVisible = true
                                    if !isLandscape {
                                        viewModel.setSelectedCity(nil)
                                    }

                                }) {
                                    Image(systemName: "chevron.left")
                                        .padding()
                                }
                                Text(viewModel.selectedCity?.name ?? "No City Selected")
                                    .font(.headline)
                                    .padding()
                                Spacer()
                            }
                            .background(Color(UIColor.systemGray6))
                        }
                        CityMapView(city:city)
                    }

                } else {
                    VStack{
                        if !isListVisible {
                            HStack{
                                Button(action: {
                                    isListVisible = true
                                }) {
                                    Image(systemName: "sidebar.leading")
                                }

                                Spacer()
                            }.padding([.top,.leading])
                        }
                        Spacer()
                        Text("Select a city to view details")
                        Spacer()
                    }
                }
                HStack {
                    if isListVisible || (!isLandscape && viewModel.selectedCity == nil) {

                        CityListView(
                            viewModel: viewModel,
                            showHideButton: isLandscape,
                            toggleListVisibility: {
                                isListVisible.toggle()
                            }
                        )
                        .frame(
                            width: isLandscape ? geometry.size.width / 2  : geometry.size.width
                        )
                        if (isLandscape) {
                            Spacer()
                        }
                    }
                }

                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5) // Make it larger
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.5)) // Semi-transparent background
                        .edgesIgnoringSafeArea(.all)
                }
            }
            .onChange(of: viewModel.selectedCity) {
                if  viewModel.selectedCity != nil, !isLandscape {
                    isListVisible = false
                }
            }
            .onChange(of: UIDevice.current.orientation) { previousOrientation,newOrientation in
                if UIDevice.current.userInterfaceIdiom != .pad {
                    if  previousOrientation.isPortrait && newOrientation.isLandscape && viewModel.selectedCity != nil {
                        isListVisible = previousOrientation.isPortrait && newOrientation.isLandscape && viewModel.selectedCity != nil
                    }

                    if  previousOrientation.isLandscape && newOrientation.isPortrait && viewModel.selectedCity != nil {
                        isListVisible = false
                    }
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let mockService = MockCityApiService()
        mockService.cities = [
            City(name: "New York", id: 1, country: "USA", coordinates: Coordinates(latitude: 40.7128, longitude: -74.0060)),
            City(name: "Los Angeles", id: 2, country: "USA", coordinates: Coordinates(latitude: 34.0522, longitude: -118.2437))
        ]
        mockService.favoriteCities = [1]

        let viewModel = CityListViewModelImpl(cityApiService: mockService)
        return MainView(viewModel: viewModel)
    }
}
