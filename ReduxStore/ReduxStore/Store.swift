public class Store<State>: DispatcherProtocol {
    
    public init(state: State, reducer: @escaping (State, Action) -> State) {
        self.state = state
        self.reducer = reducer
    }
    
    private(set) var state: State
    private let reducer: (State, Action) -> State
    
    private let queue = DispatchQueue(label: "com.redux.store")
    
    public func dispatch(action: Action) {
        queue.async {
            self.state = self.reducer(self.state, action)
            self.observers.forEach { $0.handleState(self.state) }
        }
    }
    
    private var observers: Set<Observer> = []
    
    func addObserver(on queue: DispatchQueue = .main,
                     mode: ObservationMode = .throttleUpdates,
                     callback: @escaping (State) -> ()) -> () -> () {
        let observer = Observer(queue: queue, mode: mode, observer: callback)
        
        self.queue.async {
            self.observers.insert(observer)
            observer.handleState(self.state)
        }
        
        return {
            self.queue.async {
                self.observers.remove(observer)
                observer.handleState(nil)
            }
        }
    }
}
