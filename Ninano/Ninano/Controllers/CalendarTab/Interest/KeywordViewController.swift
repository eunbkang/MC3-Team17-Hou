//
//  KeywordViewController.swift
//  Ninano
//
//  Created by KYUBO A. SHIM on 2022/07/14.
//

import UIKit

class KeywordViewController: UIViewController {
    
    private var articles: APIResponse?
    private var eventList = [Event]()
    var keywordViewModel = KeywordDataModel()
    var tempKeyword: [Event] = []

    @IBOutlet weak var keywordTableView: UITableView!
    @IBOutlet weak var isEmptyLabel: UILabel!
    let alarmTitle = "레버 관심설정의 새로운 공연일정이 추가되었습니다."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchTopStories()
        layout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if tempKeyword.isEmpty {
            isEmptyLabel.isHidden = false
        } else {
            isEmptyLabel.isHidden = true
        }
    }
}

extension KeywordViewController {
    
    func layout() {
        keywordTableView.delegate = self
        keywordTableView.dataSource = self
        keywordTableView.rowHeight = 90
        keywordTableView.separatorStyle = .none
        keywordTableView.showsVerticalScrollIndicator = false
        isEmptyLabel.isHidden = true
    }
}

extension KeywordViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempKeyword.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "noticeKeyword", for: indexPath) as? KeywordTableViewCell else { return UITableViewCell.init() }

        cell.keywordImage.image = UIImage(data: tempKeyword[indexPath.row].posterData ?? Data())
        cell.keywordTitle.text = tempKeyword[indexPath.row].title
        cell.keywordDate.text = tempKeyword[indexPath.row].period
        cell.keywordImage.layer.cornerRadius = 15
        cell.keywordTitle.font = UIFont.preferredFont(forTextStyle: .subheadline, weight: .bold)
        cell.keywordBackgroundCell.layer.cornerRadius = 15
        cell.connectionArrow.image = UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let eventDetailView = UIStoryboard(name: "EventDetail", bundle: .main).instantiateViewController(withIdentifier: "EventDetailViewController") as? EventDetailViewController else { return }
        eventDetailView.event = self.tempKeyword[indexPath.item]
        self.navigationController?.pushViewController(eventDetailView, animated: true)
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
                        posterURL: URL(string: $0.mainImg ?? ""),
                        place: String($0.place),
                        area: String($0.guname),
                        period: String($0.date),
                        URL: String($0.orgLink ?? ""),
                        actor: String($0.player),
                        info: String($0.program),
                        price: String($0.useFee)
                    )
                })
                
                self?.filterDataKeyword()
                
                self?.tempKeyword.forEach({ event in
                    event.fetchImage(url: event.posterURL) { success in
                        if success {
                            DispatchQueue.main.async {
                                self?.keywordTableView.reloadData()
                            }
                        }
                    }
                })
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func filterDataKeyword() {
        for keyword in keywordViewModel.keywordItems {
            for tempData in eventList {
                guard let tempString = keyword.keywordSubs else {return}
                if tempData.title.contains(tempString) {
                    tempKeyword.append(tempData)
                }
            }
        }
    }
}
