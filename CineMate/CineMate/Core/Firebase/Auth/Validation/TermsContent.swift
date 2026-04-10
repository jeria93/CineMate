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
    **Last updated:** 2026-04-10
    
    ## About
    CineMate uses Firebase Auth for sign-in and TMDB for movie data and images.
    
    ## TMDB Notice
    > This product uses the TMDB API but is not endorsed or certified by TMDB.
    
    ## Eligibility
    You must be 13+ (or the local minimum).
    
    ## Account
    Keep your credentials secure and follow applicable laws.
    
    ## Data & Privacy
    We store minimal data (email, user ID, favorites).
    Passwords are handled by Firebase. All requests use HTTPS.
    
    ## TMDB Terms
    TMDB data and images may change at any time.
    Usage must follow the [TMDB API Terms of Use](https://www.themoviedb.org/api-terms-of-use) and the [TMDB Terms of Use](https://www.themoviedb.org/terms-of-use).
    Attribution and branding requirements are described in the [TMDB FAQ](https://developer.themoviedb.org/docs/faq).
    
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
