//
//  CategoryCell.swift
//  Ninano
//
//  Created by Eunbee Kang on 2022/07/17.
//

import UIKit

class CategoryCell: UITableViewCell {
    var categoryTitle: String?
    var eventList: [Event] = [] {
        // MARK: fetchTopStories()에서 viewModels를 가져오는데 시간이 걸리므로 가져온 후 eventCollectionView를 reload 함.
        didSet {
            eventCollectionView.reloadData()
        }
    }
    
    weak var delegate: CollectionViewTableViewCellDelegate?
    
    @IBOutlet weak var categoryName: UIButton!
    @IBOutlet weak var categoryChevron: UIButton!
    @IBOutlet weak var eventCollectionView: UICollectionView!
    
    var searchCategoryViewDelegate: SearchCategoryViewShowable?
    
    @IBAction func didTapCategoryName(_ sender: UIButton) {
        searchCategoryViewDelegate?.didTouchCategoryButton(categoryTitle: categoryTitle ?? "", eventList: eventList)
    }
}

protocol CollectionViewTableViewCellDelegate: AnyObject {
    func collectionViewTableViewCellDidTapCell(_ cell: CategoryCell, viewModel: Event)
}

extension CategoryCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flow = collectionViewLayout as? UICollectionViewFlowLayout else {
            return CGSize()
        }
        
        let viewWidth = contentView.bounds.width
        let inset = (25 / 390) * viewWidth
        let spacing = (14 / 390) * viewWidth
        
        let width = (viewWidth - (inset * 2) - (spacing * 2)) / 3
        let height = (4 / 3) * width
        
        flow.minimumInteritemSpacing = spacing
        flow.sectionInset.left = inset
        
        return CGSize(width: width, height: height)
    }
}

extension CategoryCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eventList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventCell", for: indexPath) as? EventCell else {
            return UICollectionViewCell()
        }

        cell.contentView.layer.cornerRadius = 10
        cell.configure(with: eventList[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let eventDetailView = UIStoryboard(name: "EventDetail", bundle: .main).instantiateViewController(withIdentifier: "EventDetailViewController") as? EventDetailViewController else { return }
        eventDetailView.event = eventList[indexPath.row]
        if let viewModel = eventDetailView.event {
            self.delegate?.collectionViewTableViewCellDidTapCell(self, viewModel: viewModel)
        }
    }
}

//func didTouchCategoryButton(categoryTitle: String, eventList: [Event]) {
//    guard let searchResultView = UIStoryboard(name: "SearchResult", bundle: .main).instantiateViewController(withIdentifier: "SearchResultViewController") as? SearchResultViewController else { return }
//    searchResultView.eventList = eventList
//    searchResultView.viewCatagory = .searchCatagory(navigationTitle: categoryTitle)
//    self.navigationController?.pushViewController(searchResultView, animated: true)
//}
