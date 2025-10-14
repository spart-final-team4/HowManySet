//
//  TextFieldNavigator.swift
//  HowManySet
//
//  Created by MJ on 9/25/25.
//

import UIKit

final class TextFieldNavigator {
    
    private var textfields: [NavigatableTextField] = [] {
        didSet {
            textfields.forEach {
                $0.enabledNextButton()
                $0.enabledPreviousButton()
            }
            textfields.first?.disabledPreviousButton()
            textfields.last?.disabledNextButton()
        }
    }
    
    
    func register(_ textfields: [NavigatableTextField]) {
        self.textfields = textfields
        self.textfields.forEach { $0.navigator = self }
    }
    
    func didTappedPreviousButton(from textfield: NavigatableTextField) {
        guard let index = textfields.firstIndex(of: textfield),
              index > 0 else { return }
        let previousTextField = textfields[index - 1]
        previousTextField.becomeFirstResponder()
    }
    
    func didTappedNextButton(from textfield: NavigatableTextField) {
        guard let index = textfields.firstIndex(of: textfield),
              index < textfields.count - 1 else { return }
        let nextTextField = textfields[index + 1]
        nextTextField.becomeFirstResponder()
    }
}
