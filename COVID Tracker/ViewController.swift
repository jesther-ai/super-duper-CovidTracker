//
//  ViewController.swift
//  COVID Tracker
//
//  Created by Jesther Silvestre on 6/8/21.
//

import UIKit
import Charts
class ViewController: UIViewController {
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    //Creating TableView
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var dayData:[DayData] = [] {
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private var scope:APICaller.DataScope = .national
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Covid Cases"
        configureTable()
        createFilterButton()
        fetchData()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func configureTable(){
        view.addSubview(tableView)
        tableView.dataSource = self
    }
    
    private func fetchData(){
        APICaller.shared.getCovidData(for: scope) { [weak self] result in
            switch result{
            case .success(let dayData): self?.dayData = dayData;
            case .failure(let error): print(error);
            }
        }
    }
    
    private func createFilterButton(){
        let buttonTitle:String = {
            switch scope {
                case .national:return "National";
                case .states(let state): return state.name
            }
        }()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: buttonTitle, style: .done, target: self, action: #selector(didTapFilter))
    }
    
    @objc private func didTapFilter(){
        let vc = FilterViewController()
        vc.completion = {[weak self] state in
            self?.scope = .states(state)
            self?.fetchData()
            self?.createFilterButton()
        }
        let navVc = UINavigationController(rootViewController: vc)
        present(navVc, animated: true)
    }
}
//MARK: - tableViewStuff
extension ViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dayData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = dayData[indexPath.row]
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = createText(with: data)
        
        return cell
    }
    
    private func createText(with data: DayData) -> String?{
        let dateString = DateFormatter.prettyFormatter.string(from: data.date)
        let total = Self.numberFormatter.string(from: NSNumber(value: data.count))
        return "\(dateString): \(total ?? "\(data.count)")"
    }
    
}
