import Quick
import Nimble
import SwiftUI
@testable import MinimalAIChat

class ChatViewTests: QuickSpec {
    override func spec() {
        describe("ChatView") {
            var view: ChatView!
            var viewModel: ChatViewModel!
            
            beforeEach {
                viewModel = ChatViewModel()
                view = ChatView(viewModel: viewModel)
            }
            
            context("when initialized") {
                it("should have an empty message list") {
                    expect(viewModel.messages).to(beEmpty())
                }
                
                it("should have an empty input text") {
                    expect(viewModel.inputText).to(equal(""))
                }
            }
            
            context("when sending a message") {
                it("should add the message to the list") {
                    let message = "Hello, AI!"
                    viewModel.inputText = message
                    viewModel.sendMessage()
                    
                    expect(viewModel.messages).to(haveCount(1))
                    expect(viewModel.messages.first?.content).to(equal(message))
                }
                
                it("should clear the input text after sending") {
                    viewModel.inputText = "Test message"
                    viewModel.sendMessage()
                    
                    expect(viewModel.inputText).to(equal(""))
                }
            }
            
            context("when receiving an AI response") {
                it("should add the response to the message list") {
                    let userMessage = "Hello"
                    let aiResponse = "Hi there!"
                    
                    viewModel.inputText = userMessage
                    viewModel.sendMessage()
                    viewModel.receiveAIResponse(aiResponse)
                    
                    expect(viewModel.messages).to(haveCount(2))
                    expect(viewModel.messages.last?.content).to(equal(aiResponse))
                }
            }
        }
    }
} 