import Foundation

struct Article: Decodable {
    let title: String
    let sections: [Section]
    
    struct Section: Decodable {
        let title: String?
        let body: [BodyElement]
        
        enum BodyElement: Decodable {
            case text(String)
            case image(URL)
        }
        
        enum CodingKeys: String, CodingKey {
            case title, body = "body_elements"
        }
    }
}

// MARK: - Parsing body elements

extension Article.Section.BodyElement {
    
    private enum ImageKeys: String, CodingKey {
        case imageURL = "image_url"
    }
    
    init(from decoder: Decoder) throws {
        if let text = try? decoder.singleValueContainer().decode(String.self) {
            self = .text(text)
        } else if let json = try? decoder.container(keyedBy: ImageKeys.self) {
            let url = try json.decode(URL.self, forKey: .imageURL)
            self = .image(url)
        } else {
            throw Article.Section.BodyElement.decodingError(for: decoder)
        }
    }
    
    private static func decodingError(for decoder: Decoder) -> DecodingError {
        let description = """
            Expected a String or a Dictionary containing a
            '\(ImageKeys.imageURL.stringValue)' key with value.
            """
        return .typeMismatch(self, .init(codingPath: decoder.codingPath, debugDescription: description))
    }
}
