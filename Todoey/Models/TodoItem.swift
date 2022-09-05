import Foundation

struct TodoItem : Encodable, Decodable {
    let title: String
    var done: Bool
    
    
    init(_ title: String, _ done: Bool) {
        self.title = title
        self.done = done
    }
    
}
