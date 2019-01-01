//
//  ProjectConfig.swift
//  Roundware
//
//  Created by Taylor Snead on 10/23/18.
//

import Foundation
import CoreLocation


struct Project: Codable {
    let id: Int
    let name: String
    private let latitude: Double
    private let longitude: Double

    /// Static maximum distance an asset can be heard from.
    let recording_radius: Double
    let out_of_range_url: String
    let out_of_range_distance: Double
    let geo_listen_enabled: Bool
    let repeat_mode: String
    let ordering: String
}


extension Project {
    var location: CLLocation {
        return CLLocation(
            latitude: self.latitude,
            longitude: self.longitude
        )
    }

    /// Time to wait between checking for newly published assets
    /// - units: seconds
    var asset_refresh_interval: Double {
        return RWFrameworkConfig.getConfigValueAsNumber("asset_refresh_interval").doubleValue
    }
}
