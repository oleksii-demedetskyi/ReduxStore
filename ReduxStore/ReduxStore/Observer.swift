extension Store {
    public enum ObservationMode {
        case everyUpdate
        case throttleUpdates
    }
    
    class Observer {
        let handleState: (State?) -> ()
        
        static func throttlingHandler(for queue: DispatchQueue,
                                      callback: @escaping (State) -> ()) -> (State?) -> () {
            /// Queue for protecting access to pending props
            let observerQueue = DispatchQueue(label: "com.onemobilesdk.player.observer")
            
            /// Intermediate storage for props
            var pendingState: State?
            
            return { state in
                queue.sync {
                    let isRunningCallbackNeeded = pendingState == nil && state != nil
                    pendingState = state
                    guard isRunningCallbackNeeded else { return }
                    
                    observerQueue.async {
                        var state: State?
                        queue.sync {
                            state = pendingState
                            pendingState = nil
                        }
                        if let state = state {
                            callback(state)
                        }
                    }
                }
            }
        }
        
        static func everyUpdateHandler(for queue: DispatchQueue,
                                       callback: @escaping (State) -> ()) -> (State?) -> () {
            return { state in
                guard let state = state else { return }
                queue.async {
                    callback(state)
                }
            }
        }
        
        init(queue: DispatchQueue, mode: ObservationMode, observer: @escaping (State) -> ()) {
            switch mode {
            case .throttleUpdates:
                handleState = Observer.throttlingHandler(for: queue, callback: observer)
                
            case .everyUpdate:
                handleState = Observer.everyUpdateHandler(for: queue, callback: observer)
            }
        }
    }
}

extension Store.Observer: Hashable {
    
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
    
    static func == (left: Store.Observer, right: Store.Observer) -> Bool {
        return left === right
    }
}
