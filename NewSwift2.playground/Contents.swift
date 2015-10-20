

import UIKit

//:## Что нового в Swift 2
//:
//: 1. Вместо **println**  в Swift 1 **print** в Swift 2,
//: та же функция - другое название

    print ("Hello, world!")
    print ("Hello, world!", terminator: "")


//: 2. Благодаря расширению протокола, изменилось использование глобальных функций
//:    для Arrays

    let names = ["Катя", "Ваня", "Аня", "Максим"]

//  В **Swift 1** было так:
//
//         if contains (names, "Катя") {
//                  println ("Катя")
//         }
//
//         var numberOfItems = count(names)
//
//  В **Swift 2** стало так:

    if names.contains("Катя") {
        print ("Катя")
    }
    let numberOfItems = names.count
    let index = names.indexOf("Аня")

//    для String

    let str = "Hello, world!"

//  В **Swift 1.0** было так:
//         let length = countElements (str)
//
//  В **Swift 1.2** было так:
//         let length = count (str)
//
//  В **Swift 2** стало (возможно, последний раз) так:

    let length = str.characters.count


// Swift 1.2
let a: [Int] = [1,2,3]

// здесь мы используем map как метод Array
let b = a.map{ $0 + 1 }
// здесь мы вызываем глобально определенную map функцию
//    map([1,2,3]) { $0 + 1 }

let set = Set([1,2,3])

// не работает, так как нет map метода для Set
//    set.map{ $0 + 1 }
// глобальная функция map работает на Set
//    map(set) { $0 + 1 }

// Swift 2

let a1: [Int] = [1,2,3]

let b1 = a.map{ $0 + 1 }
let set1 = Set([1,2,3])
let anotherSet = set.map{ $0 + 1 }
let sum = (1...100)
    .filter { $0 % 2 != 0 }
    .map    { $0 * 2 }
    .reduce(0) { $0 + $1 }

print(sum)
// prints out 5000

//: 3. Появилось предупреждение о том, что не следует использовать **var**, если переменная не изменяется. Нужно использовать **let**


//: 4.  Оператор do {} while заменен на repeat {} while
//
//    В **Swift 1** было:
//        var counter = 10
//        do { print("осталось \(couter)")
//             --counter
//        } while counter > 0

//  В **Swift 2** стало так: ( тот же смый код, оператор do задействован в другом месте)

    var counter = 10
    repeat{ print("осталось \(counter)")
        --counter
    } while counter > 0

//: 5. #available обеспечивает работу с различными платформами iOS
//

    let nf = NSNumberFormatter()
    if #available(iOS 9.0, *) {
        nf.numberStyle = .OrdinalStyle
    } else {
        // Вернуться в более ранние версии
    }

    let output = nf.stringFromNumber(7)
    print(output)

//: 6. Управление ошибками БОЛЬШАЯ ТЕМА
//
//    В **Swift 1** было:
//
//    var err: NSError?
//
//    if let filePath = NSBundle.mainBundle().pathForResource("example", ofType: "txt") {
//        let contents = NSString (contentsOfFile: filePath, encoding: NSUTF8StringEncoding, error: &err)
//
//    if err == nil {
//        // Ура!
//    } else {
//        // Ошибка!
//        }
//    }
//
//      В **Swift 2** новое управление ошибками try /catch

    if let filePath = NSBundle.mainBundle().pathForResource("example", ofType: "txt") {
        do {
        let contents = try NSString (contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
            // Ура!
        } catch {
            //  Ошибка!
        }
    }

//      В **Swift 2** новое управление ошибками try!, если не хотим управления ошибками и точно знаем,
//                                                    что такой файл есть
//      Не рекомендуется использовать, но если есть абсолютная уверенность,то можно

if let filePath = NSBundle.mainBundle().pathForResource("example", ofType: "txt") {
        let contents = try! NSString (contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
    print (contents)
}

//: 7. Управление ошибками БОЛЬШАЯ ТЕМА
//:         Вы можете создать свои собственные ошибки
//:         Для этого нужно создать перечисление enum, которое подтверждает протокол ErrorType
//:         Каждый элемент перечисления - соответствующая ошибка, возникающая при определенных 
//:         обстоятельствах, которая может иметь ассиированное с ней значение

enum CoinWalletError: ErrorType {
    case ExceedsMaximumBalance
    case InsufficientFunds(shortAmount: Int)
}
let priceList = ["unicorn tears": 60]
//   Класс "Кошелек"
class CoinWallet: CustomStringConvertible {
    private let maximumBalance = 1000
    private(set) var balance: Int = 0
    
    var description: String {
        return "CoinWallet with \(balance) balance"
    }
    
    func deposit(amount: Int) throws {
        if balance + amount > maximumBalance {
            throw CoinWalletError.ExceedsMaximumBalance
        }
        
        balance += amount
    }
    
//    func makePurchase(amount: Int, seller: String) {
//        balance -= amount
//        
//        if balance < 0 {
//            fatalError("Not enough coins to make the purchase!")
//        }
//    }
    
    func makePurchase(amount: Int, seller: String) throws {
        if amount > balance {
            throw CoinWalletError.InsufficientFunds(shortAmount: amount - balance)
        }
        
        balance -= amount
    }
}

//   Вспомогательная функция
func starterWallet() -> CoinWallet {
    let myWallet = CoinWallet()
    try! myWallet.deposit(100)
    return myWallet
}
//   Работаем с "Кошельком"
let wallet = starterWallet()

do {
    try wallet.deposit(9500)
} catch CoinWalletError.ExceedsMaximumBalance {
    print("You cannot deposit that many coins!")
}

wallet

//: 8. Новые ключевые слова defer и guard

func beginReceipt() {
    print("Beginning new purchase receipt:")
}

func endReceipt() {
    print("End of receipt. Have a nice day.")
}

do {
    beginReceipt()
    defer {
        endReceipt()
    }
    
    guard let price = priceList["unicorn tears"] else {
        fatalError()
    }
    
    try wallet.makePurchase(price, seller: "Mic")
} catch CoinWalletError.InsufficientFunds(let shortAmount) {
    print("Insufficient funds! You need \(shortAmount) more coins to make that purchase!")
}

// 9. Enums

enum Exp {
    case Number(Int)
    indirect case Plus(Exp, Exp)
    indirect case Minus(Exp, Exp)
}

enum Animals {
    case Dog, Cat, Troll, Dragon
}
let an = Animals.Dragon
print (an)

enum Either<T1, T2> {
    case First(T1)
    case Second(T2)
}

let first = Either<Int, String>.First(4)
let second = Either<Int, String>.Second("four")


 enum Tree {
    case Empty
    indirect case Node(value:Int,left:Tree,right:Tree)
}

let tree1 = Tree.Node(value: 1, left: Tree.Empty, right: Tree.Empty)
let tree2 = Tree.Node(value: 2, left: Tree.Empty, right: Tree.Empty)
let tree3 = Tree.Node(value: 3, left: Tree.Empty, right: Tree.Empty)
let tree4 = Tree.Node(value: 4, left: tree1, right: tree2)
let tree5 = Tree.Node(value: 5, left: tree3, right: Tree.Empty)
let tree = Tree.Node(value: 6, left: tree4, right: tree5)

func evaluateTree(tree:Tree) -> Int {
    switch tree {
    case .Empty:
        return 0
    case .Node(let value, let left, let right):
        return value + evaluateTree(left) + evaluateTree(right)
    }
}

print("\(evaluateTree(tree))")

//: 10. OptionSetType

struct MyFontStyle : OptionSetType {
    let rawValue : Int
    static let Bold = MyFontStyle(rawValue: 1)
    static let Italic = MyFontStyle(rawValue: 2)
    static let Strikethrough = MyFontStyle(rawValue: 3)
    
}

//: 11. Функции и методы


func save(name: String, encrypt: Bool) {
    print ("function")}
class Widget {
    func save(name: String, encrypt: Bool) {
        print ("method") }
}

    save("thing", encrypt: false)
    let winget = Widget()
    winget.save ("thing", encrypt: false)

//: 12. Область видимости do {}

let mm = 1
do {
    let mm = "Good!"
    print (mm)
}
print (mm)

//: 13. defer

func whatsNew () {
    defer { print ("1") }
    do {
        defer {print ("2")}
        if 1 < 2 {
            print ("3")
        }
    }
    print ("4")
}

whatsNew ()

//: 13. guard

struct Person {
    let name: String
    let age: Int
    let address: String?
}

func createPersonFromJSON(jsonDict: [String: AnyObject]) -> Person? {
    if let name: String = jsonDict["name"] as? String,
        let age: Int = jsonDict["age"] as? Int,
        let address: String = jsonDict["address"] as? String {
            return Person(name: name, age: age, address: address)
    } else {
        return nil
    }
}

// Consider this the data coming from the API (after it's been deserialized). This data tends to be very messy
let personDictionary: [String : AnyObject] = [
    "name": "Аня",
    "age": 25,
    "address": "Москва, ул. Тверская 4 кор 6, кв. 7"
]
 let personAnn = createPersonFromJSON (personDictionary)

print ("\(personAnn)")
func createPersonFromJSON2(jsonDict: [String: AnyObject]) -> Person? {
    let name: String? = jsonDict["name"] as? String
    if name == nil {
        return nil
    }
    let age: Int? = jsonDict["age"] as? Int
    if age == nil {
        return nil
    }
    let address: String? = jsonDict["address"] as? String
    return Person(name: name!, age: age!, address: address)
}

let personDictionary2: [String : AnyObject] = [
    "name": "Аня",
    "age": 25]
let personAnn2 = createPersonFromJSON2 (personDictionary2)

print ("\(personAnn2)")
func createPersonFromJSON3(jsonDict: [String: AnyObject]) -> Person? {
    guard let name = jsonDict["name"] as? String,
        let age = jsonDict["age"] as? Int else {
            return nil
    }
    
    let address = jsonDict["address"] as? String
    return Person(name: name, age: age, address: address)
}

let personAnn3 = createPersonFromJSON3 (personDictionary2)

print ("\(personAnn3)")

let personAnn4 = createPersonFromJSON3 (personDictionary)

print ("\(personAnn4)")
//: 14. Pattern Matching
//:     Optionals

var username: String?
var password: String?

switch (username, password) {
case let (username?, password?):
    print("Success!")
case let (username?, nil):
    print("Password is missing")
case let (nil, password?):
    print("Username is missing")
case (nil, nil):
    print("Both username and password are missing")
}

// 15. Pattern matching if case

// A generic тип 'number', который может быть представлен либо целым значением,
// либо значением с плавающей точкой, либо булевским значением.
enum Number {
    case IntegerValue(Int)
    case DoubleValue(Double)
    case BooleanValue(Bool)
}
// 1.Проверка определенного варианта (case)

let myNumber : Number = .IntegerValue (3)

if case .IntegerValue = myNumber {
    print("myNumber is an integer")
}

//Swift 1.2 версия
switch myNumber {
    case .IntegerValue: print ("myNumber is an integer")
    default: break
}

// 2. Получение ассоциативного значения

if case let .IntegerValue(theInt) = myNumber {
    print("myNumber is the integer \(theInt)")
}

// guard

func getObjectInArray1<T>(array: [T], atIndex index: Number) -> T? {
    guard case let .IntegerValue(idx) = index else {
        print("Этот метод принимает только integer аргументы!")
        return nil
    }
    return array[idx]
}

let idxNumber1 : Number = .IntegerValue (2)
let arr1 = [2,3,7,8]
let obj1 = getObjectInArray1(arr1, atIndex: idxNumber1)

// 3. Отбор с помощью предложения where

func getObjectInArray<T>(array: [T], atIndex index: Number) -> T? {
    guard case let .IntegerValue(idx) = index where idx >= 0 && idx < array.count else {
        print("Этот метод принимает только integer аргументы, которые находятся в заданнах границах!")
        return nil
    }
    return array[idx]
}

let idxNumber : Number = .IntegerValue (1)
let arr = [2,3,7,8]
let obj = getObjectInArray1(arr, atIndex: idxNumber)



// 4. Соответствие диапазону range

let examResult = 49

//Swift 1.2 версия
switch examResult {
    case 0...49: print("Fail!")
    case 50...100: print("Pass!")
    default: break
}

//Swift 2 версия

if case 0...49 = examResult {
    print("Fail!")
} else if case 50...100 = examResult {
    print("Pass!")
}

let userInfo = (id: "petersmith", name: "Peter Smith", age: 18, email: "simon")
if case (_, _, 0..<18, _) = userInfo {
    print("Вам не разрешено рнгистрировать account, так как вам нет 18 лет.")
} else if case (_, _, _, let email) = userInfo where email == "" {
    print("Ваш email - пустой. Пожалуйста, заполнитн ваш email.")
} else {
    print("Можно продолжить!\n\n\n")
}

// 16. Pattern matching for case

enum EngineeringField : String {
    case Civil, Mechanical, Electrical, Chemical, Nuclear
}

enum Entity {
    case EngineeringStudent(name: String, year: Int, dept: EngineeringField)
    case HumanitiesStudent(name: String, year: Int, dept: String)
    case EngineeringProf(name: String, dept: EngineeringField)
    case HumanitiesProf(name: String, dept: String)
}

// Список присутствующих студентов.
var currentlyPresent = [
    Entity.EngineeringProf(name: "Alice", dept: .Mechanical),
    Entity.EngineeringStudent(name: "Belinda", year: 2016, dept: .Mechanical),
    Entity.EngineeringStudent(name: "Charlie", year: 2017, dept: .Chemical),
    Entity.HumanitiesStudent(name: "David", year: 2017, dept: "English Literature"),
    Entity.HumanitiesStudent(name: "Evelyn", year: 2018, dept: "Philosophy"),
    Entity.EngineeringStudent(name: "Farhad", year: 2017, dept: .Mechanical)
]


// Итерируем только ао студентам с инженерной специальностью
for case let .EngineeringStudent(name, _, dept) in currentlyPresent {
    print("\(name), who studies \(dept) Engineering, is present.")
 
}

/* Консоль:
Belinda, who studies Mechanical Engineering, is present.
Charlie, who studies Chemical Engineering, is present.
Farhad, who studies Mechanical Engineering, is present.
*/
// 17. Pattern matching while


enum Status {
    case Continue(Int)
    case Finished
}

func doSomething(input: Int) -> Status {
    if input > 5 {
        return .Finished
    } else {
        // Do work
        print("Doing work with input \(input)")
        return .Continue(input + 1)
    }
}

var latestStatus = doSomething(1)

while case let .Continue(nextInput) = latestStatus {
    latestStatus = doSomething(nextInput)
}
/* Output:
Doing work with input 1
Doing work with input 2
Doing work with input 3
Doing work with input 4
Doing work with input 5
*/

// 18. Pattern для "развертывания" (unwrapping) многочисленных Optional

var username1: String?  = "ilya"
var password1: String?

switch (username1, password1) {
case let (username1?, password1?):
    print("Success!")
case let (username1?, nil):
    print("Password is missing")
case let (nil, password1?):
    print("Username is missing")
case (nil, nil):
    print("Both username and password are missing")
}

// 19. Error handling

enum MyErrorType : ErrorType {
    case SomeErrorCause
    case AnotherErrorCause
}

func testFunction1(number:Int)throws -> Int? {
    if number > 10 {
        return nil
    } else {return number}
}


func testFunction(number:Int) throws -> Int{
    if number > 10 {
        throw MyErrorType.SomeErrorCause
    } else {return number}
}

do {
    let a = try testFunction(12)
    print (a)
} catch {
    print("ошибка...")
}

do {
    let a = try testFunction(7)
    print (a)
} catch {
    print("ошибка...")
}

do {
    let a = try testFunction(12)
        print (a)
} catch MyErrorType.SomeErrorCause {
        print("ошибка SomeErrorCause")
} catch MyErrorType.AnotherErrorCause {
        print("ошибка AnotherErrorCause")
}
// Ошибки как Optional

let aTry = try? testFunction(12)
let aTrySuccess = try? testFunction(7)
print (aTrySuccess)


let aTrySucc = try! testFunction(7)
print (aTrySucc)

// defer
func testFunction2 (number:Int) throws -> Int{
    defer { print("очистка")}
    if number > 10 {
        throw MyErrorType.SomeErrorCause
    } else {return number}
}

let aTry2 = try? testFunction2(12)
let aTrySucc2 = try? testFunction2(7)

/* Output:
очистка
очистка
*/

// Реальный пример из http://natashatherobot.com/swift-2-0-try/
// Данные после сериализации

let todoItemDictionary: [String : AnyObject] = [
    "completed": false,
    "due_on": "2015-07-08",
    "description": "Facebook app and contest"
]

//Модель для последующего использования в приложении

struct TodoItem {
    
    let description: String  // Описание задачи, которую нужно выполнить
    let dueDate: String?     // Дата исполнения, не всегда в графике
    var completed: Bool    // Отслеживает, выполнен этот элемент списка или нет
}

// Парсер для преобразования данных в Модель
struct TodoItemParser {
    
    enum Error: ErrorType {
        case InvalidData
    }
    
    func parse(fromData data: [String : AnyObject]) throws -> TodoItem {
        
        // defer будет выполненяться независимо от того,успешен парсинг или нет!
        defer { print("parsing complete!") }
        
        // испльзуем guard чтобы сфокусироваться на успешной ветке
        guard let content = data["description"] as? String,
            completed = data["completed"] as? Bool,
            dueDate = data["due_on"] as? String?
            else {
                // управляем одним из вариантов ошибок
                throw Error.InvalidData
        }
        
        return TodoItem(description: content, dueDate: dueDate, completed: completed)
    }
}

// Теперь выполним парсинг данных в Модель с использованием конструкции
// do - try - catch для обработки ошибок в Swift!
// для "хороших" данных

do {
    // успех!
    let todoItem = try TodoItemParser().parse(fromData: todoItemDictionary)
    print(todoItem)
} catch TodoItemParser.Error.InvalidData {
    // "падение"
    // заметьте, что мы можем специфицировать ошибку, которую мы поймали
    // или можем просто использовать catch для "ловли" всех собственных ошибок
    print("😱 the data is invalid!!!")
}

/* Output:
parsing complete!
TodoItem(description: "Facebook app and contest", 
                            dueDate: Optional("2015-07-08"), completed: false)
*/

// для "плохих" данных

do {
    let todoItem = try TodoItemParser().parse(fromData: ["badDataTroll" : "😈"])
    print(todoItem)
} catch TodoItemParser.Error.InvalidData {
    print("😱 the data is invalid!!!")
}

/* Output:
parsing complete!
😱 the data is invalid!!!
*/

// Вместо do - try - catch блока, можем интерпретировать данные как optional
// для "хороших" данных

let todoItem = try? TodoItemParser().parse(fromData: todoItemDictionary)
if let todoItem = todoItem {  // todoItem - Optional, не забудьте ее "развернуть"!
    print("The todo item parsing was a success! 🎉")
}

// для "плохих" данных
let invalidTodoTime = try? TodoItemParser().parse(fromData: ["badDataTroll" : "😈"])

