
/// Action should represent some change.
public protocol Action: Codable {}

/// This protocol represent an ability to dispatch different things to redux store.
public protocol DispatcherProtocol {
    func dispatch(action: Action)
}

/// Example of disptach extension
extension DispatcherProtocol {
    public func dispatch(actions: [Action]) {
        actions.forEach { dispatch(action: $0) }
    }
    
    public func dispatch(action: Action?) {
        guard let action = action else { return }
        dispatch(action: action)
    }
    
    /// etc.
}
