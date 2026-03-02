# Constructing URLs in Swift

> This document is heavily inspired by the following tutorial:
> [swiftbysundell.com/articles/constructing-urls-in-swift](https://www.swiftbysundell.com/articles/constructing-urls-in-swift/)
>
> I'm using their examples and rewriting explanations for myself to reference and improve my understanding.

---

## Overview

URLs are strings under the hood. They do have a lot more limitations than strings because they have a well-defined format that they must conform to. Because they're strings, you can just use string concatenation to use them — but that's generally inefficient and gets unreadable.

---

## External URL Example

### ❌ String Concatenation

Works, but fragile and hard to read:

```swift
func findRepositories(matching query: String) {
    let api = "https://api.github.com"
    let endpoint = "/search/repositories?q=\(query)"
    let url = URL(string: api + endpoint)
    ...
}
```

### ✅ URLComponents

A cleaner but slightly more complex approach. There's a bit more code, but it improves the utility of the resulting URLs by allowing you to do a lot more with them while the system handles the complexity of putting the URL together and the syntax involved:

```swift
func findRepositories(matching query: String,
                      sortedBy sorting: Sorting) {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.github.com"
    components.path = "/search/repositories"
    components.queryItems = [
        URLQueryItem(name: "q", value: query),
        URLQueryItem(name: "sort", value: sorting.rawValue)
    ]

    // Getting a URL from our components is as simple as
    // accessing the 'url' property.
    let url = components.url
    ...
}
```

> Both options are viable, but `URLComponents` is preferred.

The `URLQueryItem` struct represents a query key-value parameter in the URL — just a way to avoid fragile string interpolation.

---

## Avoiding Repetition with Extensions

What if we want to avoid writing all that `URLComponents()` code for multiple endpoints? **Extensions** to the rescue.

### Step 1 — Define an Endpoint Struct

```swift
struct Endpoint {
    let path: String
    let queryItems: [URLQueryItem]
}
```

### Step 2 — Add Common Endpoints via Extension

You can either use the struct by passing a path and `queryItems` into it every time, or create an extension to `Endpoint` that handles common queries so you don't have to:

```swift
extension Endpoint {
    static func search(matching query: String,
                       sortedBy sorting: Sorting = .recency) -> Endpoint {
        return Endpoint(
            path: "/search/repositories",
            queryItems: [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "sort", value: sorting.rawValue)
            ]
        )
    }
}
```

### Step 3 — Add URL Construction via Extension

This extension handles the actual creation of the URL given `path` and `queryItems`. It works with the common endpoint method above and for single cases:

```swift
extension Endpoint {
    // We still have to keep 'url' as an optional, since we're
    // dealing with dynamic components that could be invalid.
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.github.com"
        components.path = path
        components.queryItems = queryItems

        return components.url
    }
}
```

### Step 4 — Put It All Together with DataLoader

A `DataLoader` type that takes an endpoint and loads its data:

```swift
class DataLoader {
    func request(_ endpoint: Endpoint,
                then handler: @escaping (Result<Data>) -> Void) {
        guard let url = endpoint.url else {
            return handler(.failure(Error.invalidURL))
        }

        let task = urlSession.dataTask(with: url) {
            data, _, error in

            let result = data.map(Result.success) ??
                        .failure(Error.network(error))

            handler(result)
        }

        task.resume()
    }
}
```

With everything in place, you can load the data you want in a single request:

```swift
dataLoader.request(.search(matching: query)) { result in
    ...
}
```

> **Note:** Swift infers the `Endpoint` type from the method signature, so you don't have to write `Endpoint.search(...)`. The `query` itself is defined elsewhere — in this case it would be a repository name.

---

## Local / Static URL Example

With dynamic URLs, conditionals have to be used because there's no guarantee all URL components are valid. With static URLs, either you typed it right or you didn't — so you can avoid most of that using the `StaticString` type. `StaticString`s can't be the result of any dynamic expression, so the whole string needs to be defined as an inline literal.

> **Personal note:** I don't see why this guide forces the `StaticString` type when a plain `String` would do just fine. Gonna have to ask the mentor, or he'll see when he reads this.

Given that information, you can make a `URL` initializer for any static URL with ease:

```swift
extension URL {
    init(staticString string: StaticString) {
        guard let url = URL(string: "\(string)") else {
            preconditionFailure("Invalid static URL string: \(string)")
        }

        self = url
    }
}
```

Used as:

```swift
let url = URL(staticString: "https://myapp.com/faq.html")
// light work
```
