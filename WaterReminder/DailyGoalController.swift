import UIKit
import AUPickerCell
import RealmSwift

class DailyGoalController: UITableViewController, AUPickerCellDelegate {
    
    var arrayWeight = [String]()
    var arrayActivity = [String]()
    var waterGoalArray = [String]()
    
    var gender = "Male"
    var weight = "70"
    var activity = "1"
    var manual = "2000"
    
    var dailyGoal = 2000
    
    var automaticCounting = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createArrays()
        
        NotificationCenter.default.addObserver(self, selector: #selector(autoNo), name: Notification.Name("autoNo"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(autoYes), name: Notification.Name("autoYes"), object: nil)
    }
    
    @objc func autoYes() {
        automaticCounting = true
        
        tableView.beginUpdates()
        tableView.insertSections([1], with: .fade)
        tableView.endUpdates()
    }
    
    @objc func autoNo() {
        automaticCounting = false
        
        tableView.beginUpdates()
        tableView.deleteSections([1], with: .fade)
        tableView.endUpdates()
    }
    
    func createArrays() {
        for item in 30...150 {
            arrayWeight.append("\(item) kg")
        }
        
        for item in 1...10 {
            arrayActivity.append("\(item) hours")
        }
        
        
        for item in stride(from: 500, to: 10000, by: 100) {
            waterGoalArray.append("\(item) ml")
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        let item = Water()
        item.dailyGoal = dailyGoal
        item.restoToDrink = dailyGoal

        try! realm.write {
            realm.add(item)
        }

        dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: Notification.Name("Goal"), object: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if !automaticCounting {
            return 2
        } else {
            return 3
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !automaticCounting {
            return 1
        } else if section == 1 {
            return 3
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 && indexPath.row == 0 {
            let cell = AUPickerCell(type: .default, reuseIdentifier: "Gender")
            cell.delegate = self
            cell.separatorInset = UIEdgeInsets.zero
            cell.values = ["Male", "Female"]
            cell.selectedRow = 0
            cell.leftLabel.text = "Gender"
            return cell
        } else if indexPath.section == 1 && indexPath.row == 1 {
            let cell = AUPickerCell(type: .default, reuseIdentifier: "Weight")
            cell.delegate = self
            cell.separatorInset = UIEdgeInsets.zero
            cell.values = arrayWeight
            cell.selectedRow = 40
            cell.leftLabel.text = "Weight"
            return cell
        } else if indexPath.section == 1 && indexPath.row == 2 {
            let cell = AUPickerCell(type: .default, reuseIdentifier: "Activity")
            cell.delegate = self
            cell.separatorInset = UIEdgeInsets.zero
            cell.values = arrayActivity
            cell.selectedRow = 0
            cell.leftLabel.text = "Physical Activity"
            return cell
        } else if indexPath.section == 2 && indexPath.row == 0 {
            let cell = AUPickerCell(type: .default, reuseIdentifier: "Goal")
            cell.delegate = self
            cell.separatorInset = UIEdgeInsets.zero
            cell.values = waterGoalArray
            cell.selectedRow = 15
            cell.leftLabel.text = "Daily goal"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "staticCell", for: indexPath) as! StaticCell
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let cell = tableView.cellForRow(at: indexPath) as? AUPickerCell {
            return cell.height
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) as? AUPickerCell {
            cell.selectedInTableView(tableView)
        }
    }
    
    func auPickerCell(_ cell: AUPickerCell, didPick row: Int, value: Any) {
                
        if cell.reuseIdentifier == "Gender" {
            gender = value as! String
        } else if cell.reuseIdentifier == "Weight" {
            weight = value as! String
        } else if cell.reuseIdentifier == "Activity" {
            activity = value as! String
        } else if cell.reuseIdentifier == "Goal" {
            manual = value as! String
        }
        
        let itemWeight = weight.replacingOccurrences(of: " kg", with: "", options: NSString.CompareOptions.literal, range: nil)
        let itemActivity = activity.replacingOccurrences(of: " hours", with: "", options: NSString.CompareOptions.literal, range: nil)
        let itemManual = manual.replacingOccurrences(of: " ml", with: "", options: NSString.CompareOptions.literal, range: nil)
        
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! StaticCell
        
        if !cell.switch.isOn {
            dailyGoal = Int(itemManual)!
        } else {
            if gender == "Male" {
                dailyGoal = Int((Double(itemWeight)! * 0.03 + Double(itemActivity)! * 0.5) * 1000)
            } else {
                dailyGoal = Int((Double(itemWeight)! * 0.025 + Double(itemActivity)! * 0.4) * 1000)
            }
        }
        
    }
}
