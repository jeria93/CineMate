//
//  PersonViewModel+Preview.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-21.
//

import SwiftUI

/// Preview variants for `PersonViewModel` using centralized PreviewFactory.
extension PersonViewModel {
    static var preview: PersonViewModel { PreviewFactory.personViewModelPreview }
    static var loading: PersonViewModel { PreviewFactory.personViewModelLoading }
    static var error: PersonViewModel { PreviewFactory.personViewModelError }
    static var empty: PersonViewModel { PreviewFactory.personViewModelEmpty }
}
