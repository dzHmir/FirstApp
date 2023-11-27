//
//  MapController.swift
//  TransportApp
//
//  Created by Dzmitry Hmir on 21.09.23.
//

import UIKit
import SnapKit
import GoogleMaps
import CoreLocation

class MapController: UIViewController {
    
    var allStopsArray: StopsModel?
    var allBusArray: BusModel?
    
    let locationManager = CLLocationManager()
    var cameraPosition = GMSCameraPosition()
    weak var timer: Timer?
    
 //   let searchController = UISearchController(searchResultsController: nil)
    
    private lazy var mapView: GMSMapView = {
        let mapView = GMSMapView()
        
        return mapView
    }()
    
    private lazy var plusZoomButton: UIButton = {
        let button = UIButton()
        button.setTitle("+", for: .normal)
        button.backgroundColor = .gray.withAlphaComponent(0.5)
        button.addTarget(self, action: #selector(plusOneZoom), for: .touchUpInside)
        button.layer.cornerRadius = 28
        return button
    }()
    
    private lazy var minusZoomButton: UIButton = {
        let button = UIButton()
        button.setTitle("-", for: .normal)
        button.backgroundColor = .gray.withAlphaComponent(0.5)
        button.addTarget(self, action: #selector(minusOneZoom), for: .touchUpInside)
        button.layer.cornerRadius = 28
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Karte"
        moveCamera()
        makeLayout()
        makeConstraints()
//        setupSearchBar()
        //getStops()
        getBusLocation()
        startTimer()
        getCurrentLocation()
  
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeLayout() {
        view.addSubview(plusZoomButton)
        view.addSubview(minusZoomButton)
    }
    
    func makeConstraints() {
        mapView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            make.top.equalToSuperview()
        }
        
        plusZoomButton.snp.makeConstraints { make in
            make.trailing.equalTo(-16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(160)
            make.height.width.equalTo(56)
        }
        minusZoomButton.snp.makeConstraints { make in
            make.top.equalTo(plusZoomButton.snp.bottom).offset(10)
            make.trailing.equalTo(-16)
            make.height.width.equalTo(56)
        }
    }
    
    @objc func plusOneZoom(_ sender: UIButton) {
        let zoom = GMSCameraUpdate.zoomIn()
        mapView.animate(with: zoom)
    }
    
    @objc func minusOneZoom(_ sender: UIButton) {
        let zoom = GMSCameraUpdate.zoomOut()
        mapView.animate(with: zoom)
    }
    
    private func moveCamera() {
        let camera = GMSCameraPosition.camera(withLatitude: 51.962981, longitude: 7.625772, zoom: 13)
        mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        view.addSubview(mapView)
        mapView.delegate = self
    }
    
//    private func setupSearchBar() {
//        self.searchController.searchResultsUpdater = self
//        self.searchController.obscuresBackgroundDuringPresentation = false
//        self.searchController.hidesNavigationBarDuringPresentation = false
//        self.navigationItem.searchController = searchController
//        self.definesPresentationContext = false
//        self.navigationItem.hidesSearchBarWhenScrolling = false
//    }
    
    private func createStops(stopModel: StopsModel) {
        for feature in stopModel.features {
            guard let longitude = feature.geometry.coordinates.first,
                  let latitude = feature.geometry.coordinates.last else { continue }
            
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: latitude , longitude: longitude)
            
            let image = UIImageView()
            image.image = UIImage(named: "station.png")
            mapView.addSubview(image)
            image.snp.makeConstraints { make in
                make.height.width.equalTo(15)
            }
            
            marker.iconView = image
            marker.map = self.mapView
        }
    }
    
    private func getStops() {
        NetworkManager().getAllStops { [weak self] allModels in
            guard let self else { return }
            self.allStopsArray = allModels
            self.createStops(stopModel: allModels)
        } errorClosure: { error in
            print(error)
        }
    }
    
    private func createBus (busModel: BusModel) {
        mapView.clear()
        for feature in busModel.features {
            guard let longitude = feature.geometry.coordinates.first,
                  let latitude = feature.geometry.coordinates.last else { continue }
            
            let busMarker = BusMarker(position: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), busID: "12345")
            busMarker.position = CLLocationCoordinate2D(latitude: latitude , longitude: longitude)
            busMarker.title = "Мой маркер"
            busMarker.snippet = "Дополнительная информация"
            
            let image = UIImageView()
            image.image = UIImage(named: "bus.png")
            mapView.addSubview(image)
            
            image.snp.makeConstraints { make in
                make.height.width.equalTo(15)
            }
            busMarker.iconView = image
            busMarker.map = self.mapView
        }
    }
    
    @objc private func getBusLocation() {
        NetworkManager().getInfoBus { allBus in
            self.allBusArray = allBus
            self.createBus(busModel: allBus)
            //            self.locationManager.startUpdatingLocation()
        } errorClosure: { error in
            print(error)
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.getBusLocation), userInfo: nil, repeats: true)
    }
    
    func getCurrentLocation() {
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        DispatchQueue.global().async {
              if CLLocationManager.locationServicesEnabled() {
                  self.locationManager.delegate = self
                  self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                  self.locationManager.startUpdatingLocation()
              }
        }
    }
}

extension MapController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        locationManager.stopUpdatingLocation()
        print(locValue.latitude)
        print(locValue.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else { return }
        locationManager.startUpdatingLocation()
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
}

extension MapController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        print(text)
    }
}

extension  MapController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let tappedBusMarker = marker as? BusMarker {
            let busCoordinate = tappedBusMarker.position

            if let closestStop = findClosestStop(to: busCoordinate) {
                print("Ближайшая остановка: \(String(describing: closestStop.title))")

            }
        }
        return true
    }
        func findClosestStop(to busCoordinate: CLLocationCoordinate2D) -> GMSMarker? {
            var closestStop: GMSMarker?
              var shortestDistance: CLLocationDistance = .greatestFiniteMagnitude

              // Убедитесь, что allStopsArray не равен nil и содержит элементы для перебора
              guard let unwrappedStopsArray = allStopsArray else { return nil }

            for stopModel in unwrappedStopsArray.features {
                  // Теперь stopModel здесь представляет StopsModel, а не StopsModel?
                let stopCoordinate = stopModel.geometry.coordinates
                print(stopCoordinate)
                let stopLocation = CLLocation(latitude: stopCoordinate[0], longitude: stopCoordinate[1])
                  let busLocation = CLLocation(latitude: busCoordinate.latitude, longitude: busCoordinate.longitude)
                  let distance = busLocation.distance(from: stopLocation)
    

                  if distance < shortestDistance {
                      shortestDistance = distance
         //             closestStop = GMSMarker(position: CLLocationCoordinate2D(latitude: stopCoordinate[0], longitude:[1]))
//                      closestStop?.title = stopModel.title
//                      closestStop?.snippet = stopModel.subtitle
                  }
              }

              return closestStop
          }
}
extension Int {
    func toDouble() -> Double? {
        return Double(self)
    }
}
    
   

//let detailVC = DetailInfoBusController()
////    detailVC.isModalInPresentation = true
//if let sheet = detailVC.sheetPresentationController {
//    sheet.preferredCornerRadius = 40
//    sheet.detents = [.custom(resolver: { context in
//        0.4 * context.maximumDetentValue
//    }), .large()]
//    sheet.largestUndimmedDetentIdentifier = .medium
//    sheet.prefersGrabberVisible = true
//}
//present(detailVC, animated: true)
//return true
