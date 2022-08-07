//
//  SearchViewController.swift
//  Ninano
//
//  Created by Eunbee Kang on 2022/07/16.
//

import UIKit
import CloudKit

class SearchViewController: UIViewController {
    private enum Category: String, CaseIterable {
        case recommended = "니나노의 추천 공연"
        case thisMonth = "이번 달 예정 공연"
        case free = "무료 공연"
        case liked = "내가 구독한 공연"
        
        static let allValues = [recommended, thisMonth, free, liked]
    }
    
    private var articles: APIResponse?
    private var eventList = [Event]()
    private var event: Event?
    
    private let numberOfCells: Int = 8
    
    @IBOutlet private var categoryTableView: UITableView!
    
    @IBAction func didTouchSearchButton(_ sender: UIButton) {
        guard let searchResultView = UIStoryboard(name: "SearchResult", bundle: .main).instantiateViewController(withIdentifier: "SearchResultViewController") as? SearchResultViewController else { return }
        searchResultView.eventList = eventList
        searchResultView.viewCatagory = .searchResult
        self.navigationController?.pushViewController(searchResultView, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        configNavigationTitle()
        configNavigationArea()
        fetchTopStories()
        
        categoryTableView.contentInset.top = 10
    }

    private func configNavigationTitle() {
        let viewWidth = self.view.bounds.width - 115
        print(viewWidth)
        let searchViewTitle = UILabel(frame: CGRect(x: 25, y: 0, width: viewWidth, height: 20))
        searchViewTitle.textAlignment = .left
        searchViewTitle.font = UIFont.preferredFont(forTextStyle: .title2, weight: .bold)
        searchViewTitle.text = "공연 추천"
        self.navigationItem.titleView = searchViewTitle
    }
    
    private func configNavigationArea() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
}

protocol SearchCategoryViewShowable {
    func didTouchCategoryButton(categoryTitle: String, eventList: [Event])
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource, SearchCategoryViewShowable {
    func didTouchCategoryButton(categoryTitle: String, eventList: [Event]) {
        guard let searchResultView = UIStoryboard(name: "SearchResult", bundle: .main).instantiateViewController(withIdentifier: "SearchResultViewController") as? SearchResultViewController else { return }
        searchResultView.eventList = eventList
        searchResultView.viewCatagory = .searchCatagory(navigationTitle: categoryTitle)
        self.navigationController?.pushViewController(searchResultView, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Category.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as? CategoryCell else {
            return UITableViewCell()
        }
        let categoryTitle = Category.allValues[indexPath.row].rawValue
        let attribute = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .subheadline, weight: .semibold)]
        let attributedTitle = NSAttributedString(string: categoryTitle, attributes: attribute)
        
        cell.categoryTitle = categoryTitle
        cell.categoryName.setAttributedTitle(attributedTitle, for: .normal)
        cell.categoryName.titleLabel?.adjustsFontForContentSizeCategory = true
        cell.delegate = self
        
        switch indexPath.row {
        case 0: // 니나노의 추천 공연
            var recommendedEvent: [Event] = []
            var recommendedEventSet: Set<Event> = []
            var setCount: Int
            
            while recommendedEventSet.count < numberOfCells {
                if let randomEvent = eventList.randomElement() {
                    setCount = recommendedEventSet.count
                    recommendedEventSet.insert(randomEvent)
                    if recommendedEventSet.count > setCount {
                        recommendedEvent.append(randomEvent)
                    }
                }
            }
            cell.eventList = recommendedEvent
            
        case 1: // 이번 달 예정 공연
            var thisMonthEvent: [Event] = []
            thisMonthEvent = eventList.filter {
                if let period = $0.period {
                    let dateList = period.periodToDateList()
                    for date in dateList {
                        if Calendar.current.isDateInThisMonth(date) {
                            return true
                        } else {
                            return false
                        }
                    }
                }
                return false
            }
            cell.eventList = thisMonthEvent

        case 2: // 무료 공연
            var freeEvent: [Event] = []
            freeEvent = eventList.filter {
                if let price = $0.price {
                    if price.count == 0 {
                        return true
                    } else if price.contains("무료") {
                        return true
                    } else {
                        return false
                    }
                }
                return false
            }
            cell.eventList = freeEvent
            
        case 3: // 내가 구독한 공연
            cell.eventList = eventList

        default:
            return UITableViewCell()
        }
        cell.searchCategoryViewDelegate = self
        return cell
    }
    
    func fetchTopStories() {
        APICaller.shared.getTopStories { [weak self] result in
            switch result {
            case .success(let articles):
                self?.articles = articles
                // MARK: viewModels를 가져오는데 시간이 걸리므로 가져온 후 CategoryCell에서 eventCollectionView를 reload 함.
                self?.eventList = articles.culturalEventInfo.row.compactMap({
                    
                    Event(
                        title: String($0.title),
                        posterURL: URL(string: ($0.mainImg ?? "") + "DD"),
                        place: String($0.place),
                        area: String($0.guname),
                        period: String($0.date),
                        URL: String($0.orgLink ?? ""),
                        actor: String($0.player),
                        info: String($0.program),
                        price: String($0.useFee)
                    )
                })
                DispatchQueue.main.async {
                    self?.categoryTableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension SearchViewController: CollectionViewTableViewCellDelegate {
    func collectionViewTableViewCellDidTapCell(_ cell: CategoryCell, viewModel: Event) {
//        DispatchQueue.main.async { [weak self] in
            let eventDetailViewController = EventDetailViewController()
            self.navigationController?.pushViewController(eventDetailViewController, animated: true)
//        }
    }
}

//func didTouchCategoryButton(categoryTitle: String, eventList: [Event]) {
//    guard let searchResultView = UIStoryboard(name: "SearchResult", bundle: .main).instantiateViewController(withIdentifier: "SearchResultViewController") as? SearchResultViewController else { return }
//    searchResultView.eventList = eventList
//    searchResultView.viewCatagory = .searchCatagory(navigationTitle: categoryTitle)
//    self.navigationController?.pushViewController(searchResultView, animated: true)
//}
