public enum AIService: String, Codable, CaseIterable, Identifiable {
    case openAI = "OpenAI"
    case claude = "Claude"
    case deepSeek = "DeepSeek"
    
    public var id: String { self.rawValue }
    
    public var displayName: String {
        switch self {
        case .openAI: return "OpenAI"
        case .claude: return "Claude"
        case .deepSeek: return "DeepSeek"
        }
    }
    
    public var url: URL {
        switch self {
        case .openAI:
            return URL(string: "https://chat.openai.com")!
        case .claude:
            return URL(string: "https://claude.ai")!
        case .deepSeek:
            return URL(string: "https://chat.deepseek.com")!
        }
    }
    
    public var icon: String {
        switch self {
        case .openAI: return "openai-icon"
        case .claude: return "anthropic-icon"
        case .deepSeek: return "deepseek-icon"
        }
    }
} 