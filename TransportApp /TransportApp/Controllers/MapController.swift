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
    
    var isFirstTimeGettingCurrentLocation = true
    
    private lazy var mapView: GMSMapView = {
        let mapView = GMSMapView()
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        return mapView
    }()
    
    private lazy var plusZoomButton: UIButton = {
        let button = UIButton()
        button.setTitle("+", for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(plusOneZoom), for: .touchUpInside)
        button.layer.cornerRadius = 28
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 3
        return button
    }()
    
    private lazy var minusZoomButton: UIButton = {
        let button = UIButton()
        button.setTitle("-", for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(minusOneZoom), for: .touchUpInside)
        button.layer.cornerRadius = 28
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 3
        return button
    }()
    
    private lazy var findStopButton: UIButton = {
        let button = UIButton()
        button.setTitle("Haltestelle finden", for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 28
        button.addTarget(self, action: #selector(findNearestStop), for: .touchUpInside)
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 3
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Karte"
        mapView.delegate = self
        moveCamera()
        makeLayout()
        makeConstraints()
        getBusLocation()
        startTimer()
        getCurrentLocation()
        setupLocationManager()
        getStops()
        
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeLayout() {
        view.addSubview(mapView)
        view.addSubview(plusZoomButton)
        view.addSubview(minusZoomButton)
        view.addSubview(findStopButton)
    }
    
    func makeConstraints() {
        mapView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            make.top.equalToSuperview()
        }
        
        plusZoomButton.snp.makeConstraints { make in
            make.trailing.equalTo(-10)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-150)
            make.height.width.equalTo(56)
        }
        minusZoomButton.snp.makeConstraints { make in
            make.top.equalTo(plusZoomButton.snp.bottom).offset(10)
            make.trailing.equalTo(-10)
            make.height.width.equalTo(56)
        }
        
        findStopButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-10)
            make.height.equalTo(56)
        }
    }
    
    private func moveCamera() {
        let camera = GMSCameraPosition.camera(withLatitude: 51.962981, longitude: 7.625772, zoom: 13)
        mapView.camera = camera
    }
    
    private func createStops(stopModel: StopsModel) {
        for feature in stopModel.features {
            let stopCoordinate = CLLocationCoordinate2D(latitude: feature.geometry.coordinates[1], longitude: feature.geometry.coordinates[0])
            let marker = GMSMarker(position: stopCoordinate)
            marker.title = feature.properties.lbez
            marker.map = mapView
        }
    }
    
    private func getStops() {
        NetworkManager().getAllStops { [weak self] allModels in
            guard let self else { return }
            self.allStopsArray = allModels
        } errorClosure: { error in
            print(error)
        }
    }
    
    private func createBus(busModel: BusModel) {
        mapView.clear()
        for feature in busModel.features {
            let busMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: feature.geometry.coordinates[1], longitude: feature.geometry.coordinates[0]))
            busMarker.title = feature.properties.linientext
            busMarker.snippet = feature.properties.richtungstext
            
            let image = UIImageView(image: UIImage(named: "bus.png"))
            image.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            busMarker.iconView = image
            busMarker.map = mapView
        }
    }
    
    func getCurrentLocation() {
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                self.locationManager.startUpdatingLocation()
            }
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.getBusLocation), userInfo: nil, repeats: true)
    }
    
    private func setupLocationManager() {
        LocationManager.shared.requestLocationAccess()
        LocationManager.shared.locationUpdateHandler = { [weak self] location in
            guard let self else { return }
            self.updateMapLocation(location)
        }
        LocationManager.shared.startUpdatingLocation()
    }
    
    private func updateMapLocation(_ location: CLLocation?) {
        guard let location = location else { return }
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: mapView.camera.zoom)
        mapView.animate(to: camera)
    }
    
    @objc private func findNearestStop() {
        guard let currentLocation = LocationManager.shared.getCurrentLocation()?.coordinate,
              let allStops = allStopsArray?.features else {
            print("Невозможно определить текущее местоположение или отсутствуют данные остановок.")
            return
        }
        
        var closestStop: (stop: Feature, distance: CLLocationDistance)? = nil
        
        for stop in allStops {
            let stopLocation = CLLocation(latitude: stop.geometry.coordinates[1], longitude: stop.geometry.coordinates[0])
            let distance = stopLocation.distance(from: CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude))
            
            if closestStop == nil || distance < closestStop!.distance {
                closestStop = (stop, distance)
            }
        }
        
        if let closestStop = closestStop {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: closestStop.stop.geometry.coordinates[1], longitude: closestStop.stop.geometry.coordinates[0])
            let image = UIImageView(image: UIImage(named: "station.png"))
            image.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            marker.iconView = image
            marker.title = closestStop.stop.properties.lbez
            marker.map = mapView
            mapView.selectedMarker = marker
        }
    }
    
    @objc private func getBusLocation() {
        NetworkManager().getInfoBus { [weak self] allBus in
            guard let self = self else { return }
            self.allBusArray = allBus
            self.createBus(busModel: allBus)
        } errorClosure: { error in
            print(error)
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
}

extension MapController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let busName = marker.title else { return false }
        
        BusInfoPopupController.show(style: .info(
            title: "Businformation",
            subtitle: "Linien \(busName)"
        ))
        
        return true
    }
}

extension MapController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        locationManager.stopUpdatingLocation()
        print(locValue.latitude)
        print(locValue.longitude)

        if isFirstTimeGettingCurrentLocation {
            isFirstTimeGettingCurrentLocation = false
            updateMapLocation(manager.location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else { return }
        locationManager.startUpdatingLocation()
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
}
