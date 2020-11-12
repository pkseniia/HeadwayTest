//
//  Date+Current.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 11.11.2020.
//

import Foundation

extension Date {
    
    ///
    /// GitHub will discontinue password authentication to the API.
    /// You must now authenticate to the GitHub API with an API token, such as an OAuth access token,
    /// GitHub App installation access token, or personal access token, depending on what you need to do with the token.
    /// Password authentication to the API will be removed on November 13, 2020.
    ///
    
    func checkIfGitHubAPIDeprecated() -> Bool {
        let apiChangedDateString = "2020-11-13"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let apiChangedDate = formatter.date(from: apiChangedDateString) else { return true }
        print(apiChangedDate)
        return self >= apiChangedDate
    }
}
