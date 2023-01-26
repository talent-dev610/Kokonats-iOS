////  HomeDataSource.swift
//  kokonats
//
//  Created by sean on 2021/09/24.
//  
//

import UIKit

class HomeDataSource: NSObject, UITableViewDataSource {
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "sample", for: indexPath)
        return UITableViewCell()
    }
}
