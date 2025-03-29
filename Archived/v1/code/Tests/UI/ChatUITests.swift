import XCTest
import SnapshotTesting
@testable import MinimalAIChat

class ChatUITests: XCTestCase {
    var view: ChatView!
    var viewModel: ChatViewModel!
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
        super.setUp()
        viewModel = ChatViewModel()
        view = ChatView(viewModel: viewModel)
    }
    
    func testEmptyChatView() {
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 400, height: 600)
        
        assertSnapshot(matching: hostingController, as: .image)
    }
    
    func testChatViewWithMessages() {
        // Add some test messages
        viewModel.messages = [
            ChatMessage(content: "Hello!", isUser: true),
            ChatMessage(content: "Hi there!", isUser: false),
            ChatMessage(content: "How are you?", isUser: true),
            ChatMessage(content: "I'm doing great, thanks!", isUser: false)
        ]
        
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 400, height: 600)
        
        assertSnapshot(matching: hostingController, as: .image)
    }
    
    func testChatViewWithLoadingState() {
        viewModel.isLoading = true
        
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 400, height: 600)
        
        assertSnapshot(matching: hostingController, as: .image)
    }
    
    func testChatViewWithLongMessages() {
        let longMessage = String(repeating: "This is a very long message that should wrap to multiple lines. ", count: 5)
        
        viewModel.messages = [
            ChatMessage(content: longMessage, isUser: true),
            ChatMessage(content: "This is a response to the long message.", isUser: false)
        ]
        
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 400, height: 600)
        
        assertSnapshot(matching: hostingController, as: .image)
    }
    
    func testChatViewWithManyMessages() {
        // Add 20 messages to test scrolling
        for i in 0..<20 {
            viewModel.messages.append(ChatMessage(content: "Message \(i)", isUser: i % 2 == 0))
        }
        
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 400, height: 600)
        
        assertSnapshot(matching: hostingController, as: .image)
    }
    
    func testSendMessage() throws {
        // Given
        let messageTextField = app.textFields["Type a message..."]
        let sendButton = app.buttons["Send Message"]
        
        // When
        messageTextField.tap()
        messageTextField.typeText("Hello, AI!")
        sendButton.tap()
        
        // Then
        let messageBubble = app.staticTexts["Hello, AI!"]
        XCTAssertTrue(messageBubble.waitForExistence(timeout: 5))
    }
    
    func testEmptyMessageCannotBeSent() throws {
        // Given
        let messageTextField = app.textFields["Type a message..."]
        let sendButton = app.buttons["Send Message"]
        
        // When
        messageTextField.tap()
        messageTextField.typeText("   ")
        
        // Then
        XCTAssertFalse(sendButton.isEnabled)
    }
    
    func testMessageListScrollsToBottom() throws {
        // Given
        let messageTextField = app.textFields["Type a message..."]
        let sendButton = app.buttons["Send Message"]
        
        // When
        for i in 1...10 {
            messageTextField.tap()
            messageTextField.typeText("Message \(i)\n")
            sendButton.tap()
        }
        
        // Then
        let lastMessage = app.staticTexts["Message 10"]
        XCTAssertTrue(lastMessage.waitForExistence(timeout: 5))
    }
    
    func testErrorHandling() throws {
        // Given
        let messageTextField = app.textFields["Type a message..."]
        let sendButton = app.buttons["Send Message"]
        
        // When
        messageTextField.tap()
        messageTextField.typeText("Error Test")
        sendButton.tap()
        
        // Then
        let errorMessage = app.staticTexts["Sorry, I encountered an error. Please try again."]
        XCTAssertTrue(errorMessage.waitForExistence(timeout: 5))
    }
    
    func testClearMessages() throws {
        // Given
        let messageTextField = app.textFields["Type a message..."]
        let sendButton = app.buttons["Send Message"]
        let clearButton = app.buttons["Clear Messages"]
        
        // When
        messageTextField.tap()
        messageTextField.typeText("Test Message")
        sendButton.tap()
        clearButton.tap()
        
        // Then
        let messageBubble = app.staticTexts["Test Message"]
        XCTAssertFalse(messageBubble.exists)
    }
} 