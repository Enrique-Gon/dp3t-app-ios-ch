/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import UIKit

class NSOnboardingContentViewController: NSViewController {
    internal let stackScrollView = NSStackScrollView()

    private let defaultAnimationOffset: CGFloat = 200
    private let imageAnimationOffset: CGFloat = 400

    var continueButtonText = "onboarding_continue_button".ub_localized

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        setupStackView()
    }

    private func setupStackView() {
        stackScrollView.stackView.alignment = .center

        view.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        stackScrollView.addSpacerView(NSPadding.large)
    }

    internal func addArrangedView(_ view: UIView, spacing: CGFloat? = nil, index: Int? = nil, insets: UIEdgeInsets = .zero) {
        let wrapperView = UIView()
        wrapperView.ub_setContentPriorityRequired()
        wrapperView.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(insets)
        }

        view.alpha = 0

        if let idx = index {
            stackScrollView.stackView.insertArrangedSubview(wrapperView, at: idx)
        } else {
            stackScrollView.stackView.addArrangedSubview(wrapperView)
        }
        if let s = spacing {
            stackScrollView.stackView.setCustomSpacing(s, after: wrapperView)
        }
    }

    func fadeAnimation(fromFactor: CGFloat, toFactor: CGFloat, delay: TimeInterval, completion: ((Bool) -> Void)?) {
        for (idx, wrapperView) in stackScrollView.stackView.arrangedSubviews.enumerated() {
            if wrapperView.subviews.isEmpty {
                // If the view has no subviews, it has not been added with addArrangedView() (probably a spacer view)
                // and will be ignored for the animation
                continue
            }

            let v = wrapperView.subviews[0]

            // this is needed since the last swipe animation could still be running
            // if we removeAllAnimations UIView.animate will call the completionhandler
            // with finished = false
            v.layer.removeAllAnimations()

            setViewState(view: v, factor: fromFactor)
            UIView.animate(withDuration: 0.5, delay: delay + Double(idx) * 0.05, options: [.beginFromCurrentState], animations: {
                self.setViewState(view: v, factor: toFactor)
            }, completion: (idx == stackScrollView.stackView.arrangedSubviews.count - 1) ? completion : nil)
        }

        if stackScrollView.stackView.arrangedSubviews.count == 0 {
            completion?(true)
        }
    }

    internal func setViewState(view: UIView, factor: CGFloat) {
        if view is UIImageView || view is UIButton {
            view.transform = CGAffineTransform(translationX: imageAnimationOffset * factor, y: 0)
            view.alpha = 1
        } else {
            view.transform = CGAffineTransform(translationX: defaultAnimationOffset * factor, y: 0)
            view.alpha = (1.0 - abs(factor))
        }
    }
}
