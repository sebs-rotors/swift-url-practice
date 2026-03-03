@main
struct App {
    static func main() {
        let router = URLRouter()

        router.register(scheme: "dom") { url in
            print("DOM MODE ACTIVATED")
        }

        router.handle("dom://theDominator")

        router.register(scheme: "sebisidor") { url in
            print("This part is no gay:D")
        }

        router.handle("sebisidor://Code")
    }
}
