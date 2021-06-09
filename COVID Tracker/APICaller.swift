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
    
    public func getCovidData(for scope: DataScope, completion: @escaping (Result<String, Error>) -> Void) {}
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

//MARK: - MODELS

struct StateListResponse:Codable{
    let data:[State]
}
struct State: Codable{
    let name:String
    let state_code:String
}
