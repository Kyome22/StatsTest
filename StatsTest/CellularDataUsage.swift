//
//  CellularDataUsage.swift
//  StatsTest
//
//  Created by ky0me22 on 2020/10/21.
//

import Foundation

struct DataUsageInfo {
    var wifiReceived: Int64 = 0
    var wifiSent: Int64 = 0
    var wirelessWanReceived: Int64 = 0
    var wirelessWanSent: Int64 = 0

    var wifi: Int64 {
        return wifiReceived + wifiSent
    }
    var wirelessWan: Int64 {
        return wirelessWanReceived + wirelessWanSent
    }

    mutating func updateInfoByAdding(_ info: DataUsageInfo) {
        self.wifiReceived += info.wifiReceived
        self.wifiSent += info.wifiSent
        self.wirelessWanReceived += info.wirelessWanReceived
        self.wirelessWanSent += info.wirelessWanSent
    }
}

class CellularDataUsage {

    private let wwanInterfacePrefix = "pdp_ip"
    private let wifiInterfacePrefix = "en"

    var wifiCompelete: Int64 {
        return getDataUsage().wifi
    }
    var wwanCompelete: Int64 {
        return getDataUsage().wirelessWan
    }

    private func getDataUsage() -> DataUsageInfo {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        var dataUsageInfo = DataUsageInfo()

        guard getifaddrs(&ifaddr) == 0 else { return dataUsageInfo }
        while let addr = ifaddr {
            guard let info = getDataUsageInfo(from: addr) else {
                ifaddr = addr.pointee.ifa_next
                continue
            }
            dataUsageInfo.updateInfoByAdding(info)
            ifaddr = addr.pointee.ifa_next
        }

        freeifaddrs(ifaddr)

        return dataUsageInfo
    }

    private func getDataUsageInfo(from infoPointer: UnsafeMutablePointer<ifaddrs>) -> DataUsageInfo? {
        let pointer = infoPointer
        let name: String! = String(cString: pointer.pointee.ifa_name)
        let addr = pointer.pointee.ifa_addr.pointee
        guard addr.sa_family == UInt8(AF_LINK) else { return nil }

        return dataUsageInfo(from: pointer, name: name)
    }

    private func dataUsageInfo(from pointer: UnsafeMutablePointer<ifaddrs>, name: String) -> DataUsageInfo {
        var networkData: UnsafeMutablePointer<if_data>?
        var dataUsageInfo = DataUsageInfo()

        if name.hasPrefix(wifiInterfacePrefix) {
            networkData = unsafeBitCast(pointer.pointee.ifa_data, to: UnsafeMutablePointer<if_data>.self)
            if let data = networkData {
                dataUsageInfo.wifiReceived += Int64(data.pointee.ifi_ibytes)
                dataUsageInfo.wifiSent += Int64(data.pointee.ifi_obytes)
            }
        } else if name.hasPrefix(wwanInterfacePrefix) {
            networkData = unsafeBitCast(pointer.pointee.ifa_data, to: UnsafeMutablePointer<if_data>.self)
            if let data = networkData {
                dataUsageInfo.wirelessWanReceived += Int64(data.pointee.ifi_ibytes)
                dataUsageInfo.wirelessWanSent += Int64(data.pointee.ifi_obytes)
            }
        }
        return dataUsageInfo
    }

}
