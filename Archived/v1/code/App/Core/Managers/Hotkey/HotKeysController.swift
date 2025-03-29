import Foundation
import Carbon

/// A controller that manages global hotkeys
@MainActor
public final class HotKeysController: Sendable {
    public static let shared = HotKeysController()
    
    private var eventHandlerRef: EventHandlerRef?
    private var handlers: [EventHotKeyID: @Sendable () -> Void] = [:]
    
    private init() {
        setupEventHandler()
    }
    
    private func setupEventHandler() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        
        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, event, _) -> OSStatus in
                var hotkeyID = EventHotKeyID()
                let err = GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotkeyID
                )
                
                guard err == noErr else { return err }
                
                HotKeysController.shared.handleHotKey(hotkeyID)
                return noErr
            },
            1,
            &eventType,
            nil,
            &eventHandlerRef
        )
        
        guard status == noErr else {
            fatalError("Failed to install event handler")
        }
    }
    
    func registerHandler(for hotKeyID: EventHotKeyID, handler: @Sendable @escaping () -> Void) {
        handlers[hotKeyID] = handler
    }
    
    func unregisterHandler(for hotKeyID: EventHotKeyID) {
        handlers.removeValue(forKey: hotKeyID)
    }
    
    private func handleHotKey(_ hotKeyID: EventHotKeyID) {
        if let handler = handlers[hotKeyID] {
            handler()
        }
    }
    
    deinit {
        if let eventHandlerRef = eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
        }
    }
} 