//
//  ContentView.swift
//  example_Async_Await
//
//  Created by Rodolfo on 30/08/23.
//

import SwiftUI

struct ContentView: View {
    
    @State private var user: gitHubUser?
    
    var body: some View {
        VStack(spacing: 20) {
            
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .foregroundColor(.secondary)
            }
            .frame(width: 100, height: 100)
            
                
            Text(user?.login ?? "Login")
                .bold()
                .font(.title3)
            
            Text(user?.bio ?? "Bio")
                .padding()
            Spacer()
        }
        .padding()
        .task {
            do {
                user = try await getUser()
            } catch RspError.invalidUrl {
                debugPrint("invalid URL")
            } catch RspError.invalidData {
                debugPrint("invalida data")
            } catch RspError.invalidResponse {
                debugPrint("invalid response")
            } catch {
                debugPrint("unexpected error")
            }
            
        }
    }
    
    
    func getUser() async throws -> gitHubUser {
        let endPoint = "https://api.github.com/users/rodteixeira"
        guard let url = URL(string: endPoint) else { throw RspError.invalidUrl}
        
    
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw RspError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(gitHubUser.self, from: data)
        } catch {
            throw RspError.invalidData
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct gitHubUser: Decodable {
    let login: String?
    let avatarUrl: String?
    let bio: String?
}

enum RspError: Error {
    case invalidUrl
    case invalidResponse
    case invalidData
}
