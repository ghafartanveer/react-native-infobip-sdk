

import Foundation

enum APIResponse {
    case Success(Identity?)
    case Failure(String?)
}

typealias APICompletion = (APIResponse) -> ()

class APIManager {
    class func obtainToken(apiKey: String, parameters: [String: Any], completion : @escaping APICompletion) {
        var request = URLRequest(url: URL(string: "https://pw3w1m.api.infobip.com/webrtc/1/token")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        // request.addValue("App 440ee51b0443c759ee58044e2cbfd8ad-d92c487b-a076-4f6c-bdd6-3a73bc99beeb", forHTTPHeaderField: "Authorization")
        request.addValue(apiKey, forHTTPHeaderField: "Authorization")
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters)
        
        let dataTask = URLSession.shared.dataTask(with: request) { data, resppnse, error in
            guard let responseData = data, let identity = try? JSONDecoder().decode(Identity.self, from: responseData) else {
                completion(.Failure("error"))
                return
            }
            
            completion(.Success(identity))
        }
        
        dataTask.resume()
    }

}   
