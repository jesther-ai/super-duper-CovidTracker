//
//  ViewController.swift
//  COVID Tracker
//
//  Created by Jesther Silvestre on 6/8/21.
//

import UIKit
import Charts
class ViewController: UIViewController {
    
    //Creating TableView
    private let tableView: UITableView = Configuration.shared.configuredTableView
    private var scope:APICaller.DataScope = .national
    
    private var dayData:[DayData] = [] {
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
                Configuration.shared.createGraph(dayData: self.dayData, tableView: self.tableView)
            }
        }
    }
    
    
    
    
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
        cell.textLabel?.text = Configuration.shared.createText(with: data)
        
        return cell
    }
    
}
