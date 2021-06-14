//
//  APICaller.swift
//  COVID Tracker
//
//  Created by Jesther Silvestre on 6/8/21.
//

import Foundation
class APICaller {
    static let shared = APICaller();
    
    private init() {}
    //constants
    private struct Constants{
        static let allStatesUrl = URL(string:"https://api.covidtracking.com/v2/states.json")
    }
    
    enum DataScope {
        case national
        case states(State)
    }
    //getData
    public func getCovidData(for scope: DataScope, completion: @escaping (Result<[DayData], Error>) -> Void) {
        //grabbing url API
        let urlString:String = {
            switch scope{
            case .national: return "https://api.covidtracking.com/v2/us/daily.json";
            case .states(let state): return "https://api.covidtracking.com/v2/states/\(state.state_code.lowercased())/daily.json"
            }
        }()
        
        guard let url = URL(string: urlString) else {return}
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            //validate we have the data from API
            guard let data = data, error == nil else {return}
            do{
                let result = try JSONDecoder().decode(CovidDataResponse.self, from: data)
                let models:[DayData] = result.data.compactMap{
                    guard let value = $0.cases?.total.value, let date = DateFormatter.dayFormatter.date(from: $0.date) else{return nil}
                    return DayData(date: date, count: value)
                }
                completion(.success(models))
            }
            catch{
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    
    public func getStateList(completion:@escaping (Result<[State], Error>) -> Void) {
        //grabbing url API
        guard let url = Constants.allStatesUrl else {return}
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            //validate we have the data from API
            guard let data = data, error == nil else {return}
            do{
                let result = try JSONDecoder().decode(StateListResponse.self, from: data)
                let states = result.data
                completion(.success(states))
            }
            catch{
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

//MARK: - Date Formatter
extension DateFormatter {
    static let dayFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        formatter.timeZone = .current
        formatter.locale = .current
        return formatter
    }()
    static let prettyFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeZone = .current
        formatter.locale = .current
        return formatter
    }()
}
