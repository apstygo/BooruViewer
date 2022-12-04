import Foundation

@propertyWrapper
struct Indirect<T> {

    var wrappedValue: T {
        get {
            box.value
        }
        set {
            box.value = newValue
        }
    }

    private let box: Box<T>

    init(wrappedValue: T) {
        self.box = Box(wrappedValue)
    }

}

private final class Box<T> {
    var value: T

    init(_ value: T) {
        self.value = value
    }
}
