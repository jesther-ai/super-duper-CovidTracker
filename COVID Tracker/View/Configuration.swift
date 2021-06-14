//
//  Configuration.swift
//  COVID Tracker
//
//  Created by Jesther Silvestre on 6/14/21.
//

import Foundation
import UIKit
import Charts


class Configuration:UIViewController {
    static let shared = Configuration()
    
    //table Configuration
    public let configuredTableView:UITableView = {
        let table = UITableView(frame: .zero)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    public let configuredTableViewFilter:UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    
    //text Configuration
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    public func createText(with data: DayData) -> String?{
        let dateString = DateFormatter.prettyFormatter.string(from: data.date)
        let total = Self.numberFormatter.string(from: NSNumber(value: data.count))
        return "\(dateString): \(total ?? "\(data.count)")"
    }
    
    
    
    @objc public func didTapClose(){
        dismiss(animated: true, completion: nil)
    }
    
    //Graph Configuration
    
    public func createGraph(dayData:[DayData], tableView: UITableView){
        let set = dayData.prefix(30)
        var entries:[BarChartDataEntry] = []
        for index in 0..<set.count{
            let data = set[index]
            entries.append(.init(x: Double(index), y: Double(data.count)))
        }
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width/1.5))
        headerView.clipsToBounds = true
        
        let dataSet = BarChartDataSet(entries:entries)
        dataSet.colors = ChartColorTemplates.joyful()
        let data:BarChartData = BarChartData(dataSet: dataSet)
        let chart = BarChartView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width/1.5))
        
        
        
        chart.data = data
        headerView.addSubview(chart)
        tableView.tableHeaderView = headerView
    }
    
}
