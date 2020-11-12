//
//  AppConstants.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 11.11.2020.
//

import Foundation

struct AppConstants {
    
    struct OAuthCredentials {
        static let clientID = "d49788ffcad6bfceeaee"
        static let clientSecret = "3ec081d594bf83466925ed2af4468d4c9f254e9c"
        static let authorizeUrl = "https://github.com/login/oauth/authorize"
        static let accessTokenUrl = "https://github.com/login/oauth/access_token"
        static let token = "token"
        static let urlScheme = "headway://oauth-callback"
        static let scope = "repo,gist"
    }
    
    struct Login {
        static let namePlaceholder = "Username or email address"
        static let passwordPlaceholder = "Password"
        static let signIn = "Sign in"
    }
    
    struct Search {
        static let searchPlaceholder = "Search"
    }
    
    struct History {
        static let close = "Close"
    }
    
    struct Buttons {
        static let ok = "Ok"
    }
    
    struct Errors {
        static let error = "Error"
        static let wrongCredentials = "Wrong credentials"
        static let mayBad = "My bad 🥺"
        static let noInternet = "You are not connected to internet"
        static let oops = "Oops.. Try again, please"
    }
    
    struct URLs {
        static let api = "api.github.com"
    }
}
