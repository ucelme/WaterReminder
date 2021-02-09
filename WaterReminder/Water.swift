import RealmSwift

let realm = try! Realm()

class Water: Object {
    @objc dynamic var dailyGoal = 2000
    @objc dynamic var restoToDrink = 2000
}
