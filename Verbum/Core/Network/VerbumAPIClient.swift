import Foundation

/// URLSession-based API client equivalent to Retrofit.
actor VerbumAPIClient {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder

    init(baseURLString: String = "https://api.verbum.app/v1/") {
        self.baseURL = URL(string: baseURLString)!
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
    }

    // MARK: - Missal
    func getMissalReadings(date: String) async throws -> MissalReadingsDto {
        try await get("missal/readings/\(date)")
    }

    func getVerseOfTheDay() async throws -> VerseOfTheDayDto {
        try await get("missal/verse-of-the-day")
    }

    // MARK: - AI
    func sendAiMessage(request: AiChatRequestDto) async throws -> AiChatResponseDto {
        try await post("ai/chat", body: request)
    }

    // MARK: - Community
    func getCommunityFeed(page: Int, size: Int) async throws -> [CommunityPostDto] {
        try await get("community/feed?page=\(page)&size=\(size)")
    }

    func createPost(_ dto: CommunityPostDto) async throws -> CommunityPostDto {
        try await post("community/posts", body: dto)
    }

    func deletePost(id: String) async throws {
        try await delete("community/posts/\(id)")
    }

    func amenPost(id: String) async throws {
        let _: EmptyResponse = try await post("community/posts/\(id)/amen", body: EmptyBody())
    }

    // MARK: - Users
    func getUserProfile(id: String) async throws -> UserProfileDto {
        try await get("users/\(id)")
    }

    func followUser(id: String) async throws {
        let _: EmptyResponse = try await post("users/\(id)/follow", body: EmptyBody())
    }

    func unfollowUser(id: String) async throws {
        try await delete("users/\(id)/follow")
    }

    // MARK: - Groups
    func getStudyGroups() async throws -> [BibleStudyGroupDto] {
        try await get("groups")
    }

    func getStudyGroup(id: String) async throws -> BibleStudyGroupDto {
        try await get("groups/\(id)")
    }

    func createStudyGroup(_ group: BibleStudyGroupDto) async throws -> BibleStudyGroupDto {
        try await post("groups", body: group)
    }

    func joinStudyGroup(id: String) async throws {
        let _: EmptyResponse = try await post("groups/\(id)/join", body: EmptyBody())
    }

    // MARK: - Private Helpers

    private func get<T: Decodable>(_ path: String) async throws -> T {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let (data, response) = try await session.data(for: request)
        try validateResponse(response)
        return try decoder.decode(T.self, from: data)
    }

    private func post<B: Encodable, T: Decodable>(_ path: String, body: B) async throws -> T {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        let (data, response) = try await session.data(for: request)
        try validateResponse(response)
        return try decoder.decode(T.self, from: data)
    }

    private func delete(_ path: String) async throws {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        let (_, response) = try await session.data(for: request)
        try validateResponse(response)
    }

    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}

private struct EmptyBody: Encodable {}
private struct EmptyResponse: Decodable {}
