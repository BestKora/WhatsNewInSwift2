//: Playground - noun: a place where people can play

import UIKit
import GameplayKit

//1. myMap из mikeash https://www.mikeash.com/pyblog/friday-qa-2015-06-19-the-best-of-whats-new-in-swift.html

extension CollectionType {
    func myMap<U>(f: Self.Generator.Element -> U) -> [U] {
        var result: [U] = []
        for elt in self {
            result.append(f(elt))
        }
        return result
    }
}

// Применим для массива [1, 2, 3, 4] - получаем массив [2, 4, 6, 8]
let aArray = [1, 2, 3, 4].myMap({ $0 * 2 })
print (aArray)

// Применим для слайсов [1, 2, 3, 4] - получаем массив [32, 36, 40, 44, 48]
let aArray2 = [10, 12, 14, 16, 18, 20, 22, 24, 26, 28]
let aSlice = aArray2[3..<8].myMap({ $0 * 2 })
print (aSlice)

// Применим для stride 5.stride(through: 15.6, by: 1.5) - получаем массив
// ["5", "6", "8", "9", ...]
let aStrideMap = 5.stride(through: 15.6, by: 1.5)
                  .map(String.init)
                  .myMap({ $0.componentsSeparatedByString(".").first!})
print (aStrideMap)

// Применим Dictionary - получаем массив значений
var aDictionary = [10:"Есть", 12:"в", 14:"светлости", 16:"осенних", 18:"вечеров"]
let aDictionaryMap = aDictionary.myMap({ $0.1 })
print (aDictionaryMap )

// Получаем для Set([7, 12, 33, 4]) - массив[ 24, 14, 8, 66]
let setMap = Set([7, 12, 33, 4]).myMap({ $0 * 2 })
print (setMap)

var testString = "Прелесть".characters.myMap({String($0).uppercaseString + "_" })
testString

//2. shuffle() Swift 1.2
// Тасование Фишера–Йетса
//----- Пример глобальной функции "перемешивания" элементов коллекции---
//----- и возвращения новой коллекции, то есть не по месту
func shuffle<C: MutableCollectionType where C.Index == Int>(var list: C) -> C {
    let c = list.count
    if c < 2 { return list }
    for i in 0..<(c - 1) {
        let j = Int(arc4random_uniform(UInt32(c - i))) + i
         if i != j {
        swap(&list[i + list.startIndex], &list[j + list.startIndex])
        }
    }
    return list
}

// Константы:  числа и строки

shuffle([1, 2, 3, 4, 5, 6, 7, 8])
shuffle(["Есть","в","светлости","осенних", "вечеров"])

// Переменные:  строки
var strings1 = ["Багряных", "листьев", "легкий", "шелест"]
shuffle(strings1)
strings1

// Переменные:  числа
var numbers1 = [10, 12, 14, 16, 18, 20, 22, 24, 26, 28]
shuffle(numbers1)
numbers1

// Переменные:  слайсы
var strings4 = ["Есть","в","светлости","осенних", "вечеров", "Багряных", "листьев", "легкий", "шелест"]
strings4[1..<5]
shuffle(strings4[1..<5])
strings4[1..<5]

//-- Swift 1.2 Расширение класса Array ---

extension Array {
//-mutating функция "перемешивания" элементов массива по месту---
    mutating func shuffleInPlace() {
        if count < 2 { return}
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            if i != j {
                swap(&self[i], &self[j])
            }
        }
    }
    
//- NON mutating функция возвращает массив "перемешанных" элементов
    func shuffle() -> [Element] {
        var list = self
        list.shuffleInPlace()
        return list
    }
}

// Пример array методов
var numbers = [1, 2, 3, 4, 5, 6, 7, 8]
numbers.shuffleInPlace()
let shuffledNumbers = numbers.shuffle()

strings1.shuffleInPlace()
let shuffledStrings = strings1.shuffle()

// strings1[1..<3].shuffle() // Ошибка

//3. shuffle() Swift 2//
// Тасование Фишера–Йетса как расширения протоколов

extension CollectionType {
//---- Возвращается массив перемешанных элементов коллекции
    @warn_unused_result(mutable_variant="shuffleInPlace")
    func shuffled() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollectionType where Index == Int {
// mutating функция "перемешивания" элементов коллекции по месту
    mutating func shuffleInPlace() {
        // пустая или состоящая из 1 элемента не "перемешивается"
        if count < 2 { return}
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i + startIndex], &self[j + startIndex])
        }
    }
}

// Теперь мы можем применять нотацию с "точкой" 
// ко всем типам, подтверждающим эти протоколы

//  -- Array --
var numbers3 = [1, 2, 3, 4, 5, 6, 7]
numbers3[1..<5].sortInPlace()
numbers3.shuffleInPlace()
numbers3

//  -- Set --
var aSet = Set([1,4,3,8,9,10]).shuffled()
aSet.shuffleInPlace()
aSet

//  -- ArraySlice --
numbers3[1..<4].shuffleInPlace()
numbers3
var rangeA = numbers3[1..<5].shuffled()
rangeA.shuffleInPlace()
rangeA
numbers3

var sString = ["1","4","3","8","9","10"]
var sStringSlice = sString[1..<4].shuffled()
sStringSlice.shuffleInPlace()
sStringSlice
sString

//  -- Stride --
var sixStrings = 5.stride(through: 15.6, by:1.8)
                   .map(String.init)
                   .shuffle()
sixStrings.shuffleInPlace()
sixStrings

//  GameplayKit перемешивание массивов Фишера–Йетса
let shuffled = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(sString)

//4. Protocol extensions and the death of the pipe-forward operator
// Алгоритм Лу́на (англ. Luhn algorithm) — алгоритм вычисления контрольной цифры номера пластиковой карт.
// http://airspeedvelocity.net/2015/06/23/protocol-extensions-and-the-death-of-the-pipe-forward-operator/

extension Int {
    init?(c: Character) {
        guard let i = Int(String(c)) else { return nil }
        self = i
    }
}

extension SequenceType {
    func mapEveryNth(n: Int, transform: Generator.Element -> Generator.Element)
        -> [Generator.Element]  {
            
            // перечисление начинается с 0, поэтому для того, 
            // чтобы это работало с n-м элементом,
            // а не с 0-м, n+1-м и т.д., нам необходимо добавить 1:
            let isNth = { ($0 + 1) % n == 0 }
            
            return enumerate().map { i, x in
                isNth(i) ? transform(x) : x
            }
    }
}

extension SequenceType where Generator.Element: IntegerType {
    func sum() -> Generator.Element {
        return reduce(0, combine: +)
    }
}

extension IntegerType {
    func isMultipleOf(of: Self) -> Bool {
        return self % of == 0
    }
}

extension String {
    func luhnchecksum() -> Bool {
        return characters
            .flatMap(Int.init)
            .reverse()
            .mapEveryNth(2) { $0 < 5 ? $0*2 : $0*2 - 9 }
            .sum()
            .isMultipleOf(10)
    }
}

let ccNum = "4012 8888 8888 1881"

print( ccNum.luhnchecksum() ? "👍" : "👎" )

//5.optional protocol methods.

protocol MyClassDelegate {
    func shouldDoThingOne() -> Bool
    func shouldDoThingTwo() -> Bool
}

extension MyClassDelegate {
    func shouldDoThingOne() -> Bool {
        // это полезно и всегда должно выполняться
        return true
    }
    
    func shouldDoThingTwo() -> Bool {
        // это вредно и не должно выполняться без специального рассмотрения
        return false
    }
}


//6.Methods which exist solely in the extension are not dynamically dispatched and cannot be overridden.

protocol TheProtocol {
    func method1()
}
extension TheProtocol {
    func method1() {
        print("Called method1 from TheProtocol")
    }
    func method2() {
        print("Called method2 from TheProtocol")
    }
}

struct Struct1: TheProtocol {
    func method1() {
        print("Called method1 from struct 1")
    }
    
    func method2() {
        print("Called method2 from struct 1")
    }
}


let s2 = Struct1()
s2.method1()
s2.method2()
let s1: TheProtocol = Struct1()
s1.method1()
s1.method2()

//6. Убираем дупликаты 
// http://sketchytech.blogspot.ru/2015/06/living-in-post-oop-world-protocols-rule.html

extension RangeReplaceableCollectionType where Generator.Element: Equatable {
    mutating func deleteDuplicates() {
        let s = self.reduce(Self()){
            ac, x in ac.contains(x) ? ac : ac + [x]
        }
        self = s
    }
    
}
var arr = [1,2,3,4,5,6,6,5,4,3]

//arr.deleteDuplicates()
var aaSlice = arr [0..<8]
aaSlice.deleteDuplicates()

var stringHello = "Hello, playground"

var charView = stringHello.characters

charView.deleteDuplicates()
String(charView) // "Helo, paygrund"

//: 7. Демистификация map и flatMap
//: http://www.uraimo.com/2015/10/08/Swift2-map-flatmap-demystified/

let strings = ["1","2", "r", "3"]
var ints = strings.flatMap{Int ($0)}
ints

let ar1 = ["1","2","3","a"]
var ar1m = ar1.flatMap {Int($0)}
              .map {$0 * 2}
ar1m /* [Int?] with content [.Some(1),.Some(2),.Some(3),nil] */
ar1m = ar1m.map {$0 * 2}
ar1m

//8. использование C-function из stdlib.h

var array = [3, 14, 15, 9, 2, 6, 5]
qsort(&array, array.count, sizeofValue(array[0])) { a, b in
    return Int32(UnsafePointer<Int>(a).memory - UnsafePointer<Int>(b).memory)
}
print(array)

//typedef void (*dispatch_function_t)(void *); //-- C
typealias dispatch_function_t =
    @convention(c) (UnsafeMutablePointer<Void>) -> Void //-- Swift


//9. Работа со слайсами
var a222 = [3, 14, 15, 9, 2, 6, 5, 6, 9, 11, 4, 13]
var s222 = a222[5..<10]
s222.shuffleInPlace()
s222.sortInPlace()// 5..<10
s222.insertContentsOf(a222, at: 6)

a222
a222.removeFirst()
a222

var a = Array(0..<10)
a[5..<10].removeFirst()
a
var s = Array(0..<10)[5..<10]
s.indices
s[5] = 99
s
s.removeFirst()
s
s.indices
s

//=====recursion slices =====
//https://forums.developer.apple.com/message/12774#12774

extension SequenceType {
    func headTail() -> (Generator.Element, GeneratorSequence<Generator>)? {
        var g = self.generate()
        return g.next().map{($0, GeneratorSequence(g))}
    }  
}
extension SequenceType {
    func reduce(combine: (Generator.Element, Generator.Element) -> Generator.Element) -> Generator.Element? {
        return self.headTail().map {
            (head, tail) in
            tail
                .reduce(combine)
                .map{combine(head, $0)}
                ?? head
        }
    }
}
[1, 2, 3].reduce(+) //
let sPower = Array(1...5).reduce{ a, b in b * a}! // Факториал 5
print (sPower)
["1", "2", "3"].reduce(+) // "123"
"hello".characters.reduce { a, b in b}    // "o"



