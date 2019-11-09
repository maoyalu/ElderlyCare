//
//  HistoryViewController.swift
//  ElderlyCare
//
//  Created by Lu Yang on 9/11/19.
//  Copyright © 2019 Lu Yang. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {

    
    @IBOutlet weak var tableView: UIView!
    @IBOutlet weak var analysisView: UIView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            analysisView.isHidden = true
            tableView.isHidden = false
        case 1:
            analysisView.isHidden = false
            tableView.isHidden = true
        default:
            break
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
