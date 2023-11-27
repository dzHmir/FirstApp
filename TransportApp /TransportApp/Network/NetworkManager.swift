//
//  NetworkManager.swift
//  TransportApp
//
//  Created by Dzmitry Hmir on 15.09.23.
//

import Foundation
import Moya

typealias ArraySuccess<T: Decodable> = (([T]) -> Void)
typealias ObjectSuccess<T: Decodable> = ((T) -> Void)
typealias ErrorClosure = (String) -> Void

class NetworkManager {
    private let provider = MoyaProvider<BackendAPI>(plugins: [NetworkLoggerPlugin()])
    
    func getAllStops (success: ObjectSuccess<StopsModel>?, errorClosure: ErrorClosure?) {
        provider.request(.getAllStops) { result in
            switch result {
            case .success(let response):
                do {
                    let data = try JSONDecoder().decode(StopsModel.self, from: response.data)
                    success?(data)
                } catch let error {
                    errorClosure?(error.localizedDescription)
                    print(error)
                }
                
            case .failure(let error):
                print("Ошибка: \(error)")
                errorClosure?(error.localizedDescription)
            }
        }
    }
    
    func getInfoBus(success: ObjectSuccess<BusModel>?, errorClosure: ErrorClosure?) {
        provider.request(.getBus) { result in
            switch result {
            case .success(let response):
                do {
                    let data = try JSONDecoder().decode(BusModel.self, from: response.data)
                    success?(data)
                } catch let error {
                    errorClosure?(error.localizedDescription)
                    print(error)
                }
                
            case .failure(let error):
                print("Ошибка: \(error)")
                errorClosure?(error.localizedDescription)
            }
        }
    }
    
    func getStopInfo(nr: String, completion: @escaping (InfoStopModel?) -> Void) {
            provider.request(.getStopInfo(nr: nr)) { result in
                switch result {
                case .success(let response):
                    do {
                        let stopInfo = try JSONDecoder().decode(InfoStopModel.self, from: response.data)
                        completion(stopInfo)
                    } catch {
                        print("Ошибка декодирования: \(error.localizedDescription)")
                        completion(nil)
                    }

                case .failure(let error):
                    print("Ошибка запроса: \(error.localizedDescription)")
                    completion(nil)
                }
            }
        }
    
    
    func getFutureDepartures(success: ObjectSuccess<[FutureDeparturesModel]>?, errorClosure: ErrorClosure?) {
        provider.request(.getFutureDepartures(nr: "4670501")) { result in
            switch result {
            case .success(let response):
                do {
                    let data = try JSONDecoder().decode([FutureDeparturesModel].self, from: response.data)
                    success?(data)
                } catch let error {
                    errorClosure?(error.localizedDescription)
                    print(error)
                }
                
            case .failure(let error):
                print("Ошибка: \(error)")
                errorClosure?(error.localizedDescription)
            }
        }
    }
    
    func getFahrten(success: ObjectSuccess<[String]>?, errorClosure: ErrorClosure?) {
        provider.request(.getFahrten) { result in
            switch result {
            case .success(let response):
                do {
                    let data = try JSONDecoder().decode([String].self, from: response.data)
                    success?(data)
                } catch let error {
                    errorClosure?(error.localizedDescription)
                    print(error)
                }
                
            case .failure(let error):
                print("Ошибка: \(error)")
                errorClosure?(error.localizedDescription)
            }
        }
    }
    
    func getTrips(success: ObjectSuccess<TripModel>?, errorClosure: ErrorClosure?) {
        provider.request(.getTrips(fahrtbezeichner: "151023_100005_10_9_11")) { result in
            switch result {
            case .success(let response):
                do {
                    let data = try JSONDecoder().decode(TripModel.self, from: response.data)
                    success?(data)
                } catch let error {
                    errorClosure?(error.localizedDescription)
                    print(error)
                }
                
            case .failure(let error):
                print("Ошибка: \(error)")
                errorClosure?(error.localizedDescription)
            }
        }
    }
    
    func getFahrzeug(success: ObjectSuccess<FahrzeugModel>?, errorClosure: ErrorClosure?) {
        provider.request(.getFahrzeuge(fahrtbezeichner: "161023_100044_6_11_12")) { result in
            switch result {
            case .success(let response):
                do {
                    let data = try JSONDecoder().decode(FahrzeugModel.self, from: response.data)
                    success?(data)
                } catch let error {
                    errorClosure?(error.localizedDescription)
                    print(error)
                }
                
            case .failure(let error):
                print("Ошибка: \(error)")
                errorClosure?(error.localizedDescription)
            }
        }
    }
}
