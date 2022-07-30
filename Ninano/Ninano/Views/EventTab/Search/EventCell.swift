//
//  EventCell.swift
//  Ninano
//
//  Created by Eunbee Kang on 2022/07/17.
//

import UIKit

class EventCell: UICollectionViewCell {
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var posterButton: UIButton!
    
    func configure(with viewModel: Event) {
        posterImage.image = UIImage(named: "tempPoster")
        if let data = viewModel.posterData {
            posterImage.image = UIImage(data: data)
        } else if let url = viewModel.posterURL {
            // fetch
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                viewModel.posterData = data
                DispatchQueue.main.async {
                    self?.posterImage.image = UIImage(data: data)
                }
            }.resume()
        }
    }
}
