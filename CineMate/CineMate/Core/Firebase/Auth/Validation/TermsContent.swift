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
    # Terms of Service
    **Last updated:** 2025-08-21  

    ## About
    CineMate uses Firebase Auth for sign-in and TMDB for artwork/metadata.  
    > Uses the TMDB API but not endorsed by TMDB.

    ## Eligibility
    Must be 13+ (or local minimum).

    ## Account
    Keep your login secure and follow the law.

    ## Data & Privacy
    We store minimal data (email, ID, favorites).  
    Passwords handled by Firebase. HTTPS used.  
    Contact: **support@example.com**

    ## TMDB Content
    Posters/metadata may change.  
    See [TMDB Terms](https://www.themoviedb.org/terms-of-use).

    ## Acceptable Use
    No scraping, abuse, or IP violation.

    ## Warranty
    Provided “as is.” No liability for losses.

    ## Updates
    Using the app means you accept changes.
    """
}
