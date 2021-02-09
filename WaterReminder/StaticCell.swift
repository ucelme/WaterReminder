import UIKit

class StaticCell: UITableViewCell {

    @IBOutlet weak var `switch`: UISwitch!
    
    @IBAction func toggleSwitch(_ sender: UISwitch) {
        if sender.isOn {
            NotificationCenter.default.post(name: Notification.Name("autoYes"), object: nil)
        } else {
            NotificationCenter.default.post(name: Notification.Name("autoNo"), object: nil)
        }

    }
    
}
