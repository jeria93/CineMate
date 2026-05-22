//
//  TermsContent.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-21.
//

import Foundation

enum TermsContent {
    static let currentVersion = "2026-04-10"
    static let privacyPolicyVersion = currentVersion
    
    /// Short markdown for the “View terms” sheet.
    static let termsMarkdown = """
    **Last updated:** \(currentVersion)
    
    ## What changed
    This version adds direct links to TMDB API Terms and TMDB Terms.
    
    This version clarifies TMDB attribution requirements with the TMDB FAQ link.
    
    This version updates legal wording for data usage and support.
    
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
    
    /// Short markdown for the privacy policy sheet.
    static let privacyPolicyMarkdown = """
    **Last updated:** \(privacyPolicyVersion)
    
    ## About
    CineMate uses Firebase Auth for sign-in and TMDB for movie data and images.
    
    ## Data We Store
    We store only data needed to run the app.
    This includes email, user ID, and favorites.
    
    ## Passwords
    Passwords are handled by Firebase Auth.
    CineMate does not store raw passwords.
    
    ## Why We Store Data
    We use your data to create your account, keep you signed in, and sync your favorites.
    
    ## Data Sharing
    We do not sell personal data.
    We only share data with service providers needed to run the app.
    
    ## Security
    All network requests use HTTPS.
    
    ## Your Choices
    You can request account deletion in app settings.
    Removing your account removes stored user data from CineMate services.
    
    ## TMDB
    TMDB provides movie metadata and images.
    TMDB has its own privacy and data rules.
    
    ## Updates
    We may update this policy when legal or product needs change.
    
    ## Contact
    **Contact:** Open a GitHub Issue on the project repository.
    """
}
