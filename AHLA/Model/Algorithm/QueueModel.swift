///
///
///Project name: AdHocLoudspeakerArray
/// Class name: OuterRoomInfoModel
/// Creator: Kazuki Fujita
/// Created at: 2023/11/27
/// Updated at: 2024/05/28
///
/// ---Explanation---
/// QueueModel
///
///


import Foundation

class QueueModel<T> : NSObject {
    
    var array = [T]()
    
    init(array: [T]){
        self.array = array
    }
    
    public var isEmpty: Bool {
        return array.isEmpty
    }
    
    public var size: Int{
        return self.array.count
    }
    
    public func enqueue(element: T) {
        self.array.append(element)
    }

    public func dequeue() -> T? {
        if self.array.isEmpty {
          return nil
        } else {
          return array.removeFirst()
        }
    }
    
}
