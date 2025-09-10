//
//  TermsContent.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-21.
//

import Foundation

enum TermsContent {
    /// Short markdown for the “View terms” sheet.
    static let termsMarkdown = """
    **Last updated:** 2025-09-10

    ## About
    CineMate uses Firebase Auth for sign-in and TMDB for artwork/metadata.  
    > Uses the TMDB API but is not endorsed or certified by TMDB.

    ## Eligibility
    You must be 13+ (or the local minimum).

    ## Account
    Keep your credentials secure and follow applicable laws.

    ## Data & Privacy
    We store minimal data (email, user ID, favorites).  
    Passwords are handled by Firebase. All requests use HTTPS.

    ## TMDB Content
    Posters and metadata may change.  
    See the [TMDB Terms](https://www.themoviedb.org/terms-of-use).

    ## Acceptable Use
    No scraping, abuse, or IP infringement.

    ## Warranty
    Provided “as is,” without warranties. We are not liable for losses.

    ## Updates
    Using the app means you accept changes to these terms.

    ## Support
    **Contact:** Open a GitHub Issue on the project repository.
    """
}
