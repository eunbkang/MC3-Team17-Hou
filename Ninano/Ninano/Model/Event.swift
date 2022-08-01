//
//  SearchEventModel.swift
//  Ninano
//
//  Created by Eunbee Kang on 2022/07/27.
//

import Foundation

class Event {
    
    let title: String
    let posterURL: URL?
    var posterData: Data?
    let place: String?
    let area: String?
    let period: String?
    let URL: String?
    let actor: String?
    let info: String?
    let price: String?
    
    init(title: String, posterURL: URL?, place: String, area: String, period: String, URL: String?, actor: String, info: String, price: String) {
        self.title = title
        self.posterURL = posterURL
        self.place = place
        self.area = area
        self.period = period
        self.URL = URL
        self.actor = actor
        self.info = info
        self.price = price
    }
    
    func fetchImage(url: URL?, completion: @escaping (Bool) -> Void) {
        if let url = url {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let data = data, error == nil else {
                    completion(false)
                    return
                }
                self?.posterData = data
                completion(true)
            }.resume()
        } else {
            completion(false)
        }
    }
}

extension Event: Hashable {
    static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.title == rhs.title && lhs.posterURL == rhs.posterURL && lhs.place == rhs.place && lhs.area == rhs.area && lhs.period == rhs.period && lhs.URL == rhs.URL && lhs.actor == rhs.actor && lhs.info == rhs.info && lhs.price == rhs.price
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(posterURL)
        hasher.combine(place)
        hasher.combine(area)
        hasher.combine(period)
        hasher.combine(URL)
        hasher.combine(actor)
        hasher.combine(info)
        hasher.combine(price)
    }
}
