import Foundation

struct SebURL {
    let scheme: String
    let host: String
    let path: String
    let query: [String: String]

    init?(_ raw: String) {
        guard let url = URL(string: raw),
            let scheme = url.scheme,
            let host = url.host
        else { return nil }

        self.scheme = scheme
        self.host = host
        self.path = url.path

        var queryDict: [String: String] = [:]
        if let items = URLComponents(string: raw)?.queryItems {
            for item in items {
                queryDict[item.name] = item.value ?? ""
            }
        }
        self.query = queryDict
    }
}

typealias URLHandler = (SebURL) -> Void

class URLRouter {
    private var handlers: [String: URLHandler] = [:]

    func register(scheme: String, handler: @escaping URLHandler) {
        handlers[scheme] = handler
    }

    func handle(_ raw: String) {
        guard let url = SebURL(raw),
            let handler = handlers[url.scheme]
        else {
            print("NO HANDLER FOR THAT BS HANDLER: (raw)")
            return
        }
        handler(url)
    }
}

extension String {
    var asFile: URL {
        return URL(fileURLWithPath: self)
    }
}
