//
//  MapView.swift
//  WeatherDashboardTemplate

//  Created by Zonish Sheikh

import SwiftUI
import MapKit
import SwiftData

struct MapView: View {

    @EnvironmentObject var vm: MainAppViewModel
    @Environment(\.openURL) private var openURL

    // Default London region
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 51.5074,
                longitude: -0.1278
            ),
            latitudinalMeters: 3000,
            longitudinalMeters: 3000
        )
    )

    var body: some View {
        ZStack {

            // Background
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.35),
                    Color.purple.opacity(0.15)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 12) {

                // MAP
                Map(position: $cameraPosition) {
                    ForEach(vm.pois.prefix(5)) { poi in
                        Annotation(poi.name, coordinate: poi.coordinate) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.red)
                                .onTapGesture {
                                    zoomOnPOI(poi)
                                }
                                .contextMenu {
                                    Button("Search on Google") {
                                        openGoogleSearch(for: poi.name)
                                    }
                                }
                        }
                    }
                }
                .ignoresSafeArea(.container, edges: .top)
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                // Title
                Text("Top 5 Tourist Attractions in \(vm.activePlaceName)")
                    .font(.headline)

                // POI List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(vm.pois.prefix(5)) { poi in
                            poiRow(poi)
                                .onTapGesture {
                                    centerMap(on: poi)
                                }
                                .onLongPressGesture {
                                    openGoogleSearch(for: poi.name)
                                }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 28)
                }
            }
        }
        .onChange(of: vm.pois) { _, newPOIs in
            if let first = newPOIs.first {
                focusInitialPOI(first)
            }
        }
    }

    // MARK: - POI Row
    private func poiRow(_ poi: AnnotationModel) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "mappin.circle.fill")
                .foregroundColor(.orange)

            Text(poi.name)
                .font(.subheadline)

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
        )
    }

    // MARK: - Map Controls
    private func centerMap(on poi: AnnotationModel) {
        cameraPosition = .region(
            MKCoordinateRegion(
                center: poi.coordinate,
                span: MKCoordinateSpan(
                    latitudeDelta: 0.01,
                    longitudeDelta: 0.01
                )
            )
        )
    }

    private func zoomOnPOI(_ poi: AnnotationModel) {
        cameraPosition = .region(
            MKCoordinateRegion(
                center: poi.coordinate,
                latitudinalMeters: 500,
                longitudinalMeters: 500
            )
        )
    }

    private func focusInitialPOI(_ poi: AnnotationModel) {
        cameraPosition = .region(
            MKCoordinateRegion(
                center: poi.coordinate,
                latitudinalMeters: 1200,
                longitudinalMeters: 1200
            )
        )
    }

    // MARK: - Google Search
    private func openGoogleSearch(for name: String) {
        let query = name.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) ?? name

        if let url = URL(string: "https://www.google.com/search?q=\(query)") {
            openURL(url)
        }
    }
}

#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    MapView()
        .environmentObject(vm)
}

#Preview("Full Dashboard") {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    NavBarView()
        .environmentObject(vm)
}
