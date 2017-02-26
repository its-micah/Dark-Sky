//
//  ViewController.swift
//  Dark Sky
//
//  Created by Micah Lanier on 2/16/17.
//  Copyright © 2017 Micah Lanier. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private let key = "0e10185923bb59676b987eacb6261b5a"

    override func viewDidLoad() {
        super.viewDidLoad()
        let baseURL = URL(string: "https://api.darksky.net/forecast/\(key)/")
        let location = "41.8661,-88.1070"
        let forecastURL = URL(string: location, relativeTo: baseURL)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

