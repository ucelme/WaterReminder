import UIKit
import UserNotifications

class NotificationController: UITableViewController {
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    var minutesFrom = 0
    var secondsFrom = 0
    
    var intervals = ["15 minutes", "30 minutes", "1 hour", "2 hours", "3 hours", "4 hours", "5 hours"]
    var intervalsInt = [15, 30, 1, 2, 3, 4, 5]

    var intervalString = ""
    var intervalInt = 3600
    
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var intervalLabel: UILabel!
    
    var toolBar = UIToolbar()
    var pickerFrom = UIDatePicker()
    var pickerTo = UIDatePicker()
    var timePicker = UIPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
        switch indexPath.row {
              case 0: fromTime()
              case 1: toTime()
              case 2: invervalTime()
              default: break
              }
        }
    }
    
    @IBAction func notificationSwitch(_ sender: UISwitch) {
        
        if !UserDefaults.standard.bool(forKey: "Premium") {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "Premium")
            self.present(controller, animated: true, completion: nil)
            sender.isOn = false
        } else {
            if sender.isOn {
                requestAutorization()
            }
        }
    }
    
    func requestAutorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        notificationCenter.getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
        }
    }
    
    func scheduleNotification(id: String, interval: Int) {
                
        let content = UNMutableNotificationContent()
                
        content.title = "Water reminder"
        content.body = "It's time to drink water!"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(interval), repeats: true)
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }
    
    func fromTime() {
        pickerFrom.datePickerMode = .time
        pickerFrom.preferredDatePickerStyle = .wheels
        pickerFrom.locale = Locale(identifier: "en_GB")
        pickerFrom.autoresizingMask = .flexibleWidth
        pickerFrom.contentMode = .center
        pickerFrom.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 350, width: UIScreen.main.bounds.size.width, height: 350)
        
        UIView.transition(with: self.view, duration: 0.25, options: [.curveEaseIn], animations: {
            self.view.addSubview(self.pickerFrom)
        }, completion: nil)

        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 350, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.isTranslucent = true
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClickFrom))
        toolBar.setItems([doneButton], animated: false)

        self.view.addSubview(toolBar)
    }
    
    func toTime() {
        pickerTo.datePickerMode = .time
        pickerTo.preferredDatePickerStyle = .wheels
        pickerTo.locale = Locale(identifier: "en_GB")
        pickerTo.autoresizingMask = .flexibleWidth
        pickerTo.contentMode = .center
        pickerTo.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 350, width: UIScreen.main.bounds.size.width, height: 350)
        
        UIView.transition(with: self.view, duration: 0.25, options: [.curveEaseIn], animations: {
            self.view.addSubview(self.pickerTo)
        }, completion: nil)

        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 350, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.isTranslucent = true
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClickTo))
        toolBar.setItems([doneButton], animated: false)

        self.view.addSubview(toolBar)
    }
    
    func invervalTime() {
        timePicker.delegate = self
        timePicker.dataSource = self

        timePicker.autoresizingMask = .flexibleWidth
        timePicker.contentMode = .center
        timePicker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 350, width: UIScreen.main.bounds.size.width, height: 350)
        
        UIView.transition(with: self.view, duration: 0.25, options: [.curveEaseIn], animations: {
            self.view.addSubview(self.timePicker)
        }, completion: nil)

        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 350, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.isTranslucent = true
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClickInterval))
        toolBar.setItems([doneButton], animated: false)

        self.view.addSubview(toolBar)
    }

    @objc func doneClickFrom() {
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        timeFormatter.dateStyle = .none
        timeFormatter.locale = Locale(identifier: "en_GB")

        let strDate = timeFormatter.string(from: pickerFrom.date)

        fromLabel.text = strDate
        
        toolBar.removeFromSuperview()
        pickerFrom.removeFromSuperview()
    }
    
    @objc func doneClickTo() {
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        timeFormatter.dateStyle = .none
        timeFormatter.locale = Locale(identifier: "en_GB")

        let strDate = timeFormatter.string(from: pickerTo.date)

        toLabel.text = strDate

        toolBar.removeFromSuperview()
        pickerTo.removeFromSuperview()
    }
    
    @objc func doneClickInterval() {

        intervalLabel.text = intervalString
        
        toolBar.removeFromSuperview()
        timePicker.removeFromSuperview()
    }

    @objc func cancelClick() {
        toolBar.removeFromSuperview()
        pickerTo.removeFromSuperview()
        pickerFrom.removeFromSuperview()
        timePicker.removeFromSuperview()
    }
}

extension NotificationController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return intervals.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return intervals[row].description
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        intervalString = "\(intervals[row].description)"
        
        if row == 0 || row == 1 {
            intervalInt = intervalsInt[row] * 60
        } else {
            intervalInt = intervalsInt[row] * 3600
        }
        
        let id = UUID().uuidString
        scheduleNotification(id: id, interval: intervalInt)
    }
}
