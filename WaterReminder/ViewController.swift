import UIKit
import CircleProgressView
import RealmSwift

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var drinks: Results<Water>!
    
    var volumes = [Int]()
    
    var toolBar = UIToolbar()
    var picker  = UIPickerView()
    
    var drinkedCount = 0
    
    var dailyGoalValue = 2000
    var restToDrinkValue = 2000
    var drinkedValue = 250
    var totalDrinked = 0

    @IBOutlet weak var circleProgressView: CircleProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var dailyGoal: UILabel!
    @IBOutlet weak var restToDrink: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    
    let numberFormatter = NumberFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        drinkedCount = UserDefaults.standard.integer(forKey: "drinkedCount")
        dailyGoalValue = UserDefaults.standard.integer(forKey: "dailyGoalValue")
        restToDrinkValue = UserDefaults.standard.integer(forKey: "restToDrinkValue")

        numberFormatter.numberStyle = .percent
        
        circleProgressView.progress = 0
        
        createArrays()
        
        progressLabel.text = numberFormatter.string(from: NSNumber(value: self.circleProgressView.progress))!
        
        NotificationCenter.default.addObserver(self, selector: #selector(goal), name: Notification.Name("Goal"), object: nil)
        
        drinks = realm.objects(Water.self)
        
        dayLabel.text = Date.dateToString(Date())()
    }
    
    func createArrays() {
        for item in stride(from: 100, to: 2500, by: 10) {
            volumes.append(item)
        }
    }
    
    @IBAction func resetClicked(_ sender: UIButton) {
        circleProgressView.progress = 0
        progressLabel.text = "0%"
        let goal = realm.objects(Water.self).last!.dailyGoal
        dailyGoal.text = "\(String(describing: goal)) ml"
        restToDrink.text = "\(String(describing: goal)) ml"
        totalDrinked = 0
        dailyGoalValue = goal
        restToDrinkValue = goal
    }
    
    @objc func goal() {
        circleProgressView.progress = 0
        progressLabel.text = "0%"
        let goal = realm.objects(Water.self).last!.dailyGoal
        dailyGoal.text = "\(String(describing: goal)) ml"
        restToDrink.text = "\(String(describing: goal)) ml"
        dailyGoalValue = goal
        restToDrinkValue = goal
        UserDefaults.standard.set(dailyGoalValue, forKey: "dailyGoalValue")
        UserDefaults.standard.set(restToDrinkValue, forKey: "restToDrinkValue")

    }

    @IBAction func dailyGoal(_ sender: UITapGestureRecognizer) {
        print(1)
    }
    
    @IBAction func drinkWater(_ sender: UIButton) {
        picker = UIPickerView.init()
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = .white
        picker.setValue(UIColor.black, forKey: "textColor")
        picker.selectRow(15, inComponent: 0, animated: true)
        picker.autoresizingMask = .flexibleWidth
        picker.contentMode = .center
        picker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        
        UIView.transition(with: self.view, duration: 0.25, options: [.curveEaseIn], animations: {
            self.view.addSubview(self.picker)
        }, completion: nil)

        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.isTranslucent = true
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClick))
        toolBar.setItems([doneButton, spaceButton, cancelButton], animated: false)

        self.view.addSubview(toolBar)
    }
    
    @objc func doneClick() {
        
        if drinkedCount > 50 && !UserDefaults.standard.bool(forKey: "Premium") {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "Premium")
            self.present(controller, animated: true, completion: nil)
        } else {
            restToDrinkValue -= drinkedValue
            totalDrinked += drinkedValue
            restToDrink.text = "\(restToDrinkValue) ml"
            
            let progress = Double(totalDrinked) / Double(dailyGoalValue)
            print(progress)
            circleProgressView.progress = progress
            progressLabel.text = "\(Int(progress * 100))%"
            
            drinkedCount += 1
            UserDefaults.standard.set(drinkedCount, forKey: "drinkedCount")
            
            toolBar.removeFromSuperview()
            picker.removeFromSuperview()
        }
    }
    
    @objc func cancelClick() {
        toolBar.removeFromSuperview()
        picker.removeFromSuperview()
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return volumes.count
    }
        
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        volumes[row].description
    }
        
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        drinkedValue = volumes[row]
    }
    
    // MARK: - Helpers
    @objc func delay(_ delay:Double, closure: @escaping ()-> Void) {
        let delayTime = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: delayTime, execute: closure)
    }


}

