//
//  ViewController.swift
//  StatsTest
//
//  Created by ky0me22 on 2020/10/21.
//

import UIKit

// https://stackoverflow.com/questions/46985116/swift-get-mobile-data-current-usage-figure
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getStrage()
        getCellularData()
    }

    func getStrage() {
        guard let attributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
              let totalSize = (attributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value,
              let freeSize = (attributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value
        else { return }
        let total = ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .binary)
        let free = ByteCountFormatter.string(fromByteCount: freeSize, countStyle: .binary)
        Swift.print("\(free) / \(total)")
    }

    func getCellularData() {
        let cdu = CellularDataUsage()
        Swift.print(cdu.wifiCompelete, cdu.wwanCompelete)
    }
}

