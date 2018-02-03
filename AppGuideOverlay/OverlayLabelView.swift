//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

import AppKit

open class OverlayLabelView: NSView {

    open let titleLabel: NSTextField
    open let detailLabel: NSTextField

    open let previousStepButton: NSButton
    open let nextStepButton: NSButton

    public override init(frame frameRect: NSRect) {

        self.titleLabel = OverlayLabelView.newTitleLabel()
        self.detailLabel = OverlayLabelView.newDetailLabel()
        self.previousStepButton = OverlayLabelView.newButton(direction: .previous)
        self.nextStepButton = OverlayLabelView.newButton(direction: .next)

        super.init(frame: frameRect)

        layoutLabels()
    }

    public required init?(coder decoder: NSCoder) {

        self.titleLabel = OverlayLabelView.newTitleLabel()
        self.detailLabel = OverlayLabelView.newDetailLabel()
        self.previousStepButton = OverlayLabelView.newButton(direction: .previous)
        self.nextStepButton = OverlayLabelView.newButton(direction: .next)

        super.init(coder: decoder)

        layoutLabels()
    }

    private static func newTitleLabel() -> NSTextField {

        let titleLabel = NSTextField.newLabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = NSFont.systemFont(ofSize: 24, weight: .light)
        titleLabel.textColor = .white
        titleLabel.identifier = .init(rawValue: "OverlayTitleLabel")
        return titleLabel
    }

    private static func newDetailLabel() -> NSTextField {

        let detailLabel = NSTextField.newWrappingLabel()
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.font = NSFont.systemFont(ofSize: 14, weight: .regular)
        detailLabel.textColor = .white
        detailLabel.identifier = .init(rawValue: "OverlayDetailLabel")
        return detailLabel
    }

    private static func newButton(direction: OverlayButton.Direction) -> OverlayButton {

        let button = OverlayButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.bezelStyle = .recessed

        direction.configure(button: button)

        return button
    }

    open var target: Any?
    open var previousAction: Selector?
    open var nextAction: Selector?
    open var finishAction: Selector?

    private func layoutLabels() {

        addSubview(titleLabel)
        addSubview(detailLabel)
        addSubview(previousStepButton)
        addSubview(nextStepButton)

        self.addConstraints(
            visualFormats: [
                "H:|[title]|",
                "H:|[detail]|",
                "H:|[prev]-(12)-[next]-(>=0)-|",

                "V:|[title]-(8)-[detail]-(12)-[prev]|"
            ],
            views: [
                "title" : titleLabel,
                "detail" : detailLabel,
                "prev" : previousStepButton,
                "next" : nextStepButton
            ])
        self.addConstraints([NSLayoutConstraint(item: nextStepButton, attribute: .firstBaseline, relatedBy: .equal, toItem: previousStepButton, attribute: .firstBaseline, multiplier: 1, constant: 0)])
    }

    open func changeText(title: String, detail: String) {

        titleLabel.stringValue = title
        titleLabel.sizeToFit()

        detailLabel.stringValue = detail
        detailLabel.sizeToFit()

        layoutSubtreeIfNeeded()
    }

    open func changeButtons(isFirstStep: Bool, isLastStep: Bool) {

        previousStepButton.isEnabled = !isFirstStep
        previousStepButton.target = nil
        previousStepButton.action = previousAction

        nextStepButton.title = isLastStep
            ? OverlayButtonLabels.finish
            : OverlayButtonLabels.next
        nextStepButton.target = nil
        nextStepButton.action = isLastStep
            ? self.finishAction
            : self.nextAction
    }
}

internal class OverlayButton: NSButton {

    enum Direction {
        case previous, next

        var imageName: NSImage.Name {
            switch self {
            case .previous: return .init(rawValue: "button-prev")
            case .next: return .init(rawValue: "button-next")
            }
        }

        var image: NSImage? {
            return Bundle(for: OverlayButton.self).image(forResource: imageName)
        }

        var imagePosition: NSControl.ImagePosition {
            switch self {
            case .previous: return .imageLeft
            case .next: return .imageRight
            }
        }

        var title: String {
            switch self {
            case .previous: return OverlayButtonLabels.previous
            case .next: return OverlayButtonLabels.next
            }
        }

        func configure(button: NSButton) {
            button.title = self.title
            button.image = self.image
            button.imagePosition = self.imagePosition
            button.imageScaling = .scaleProportionallyDown
        }
    }
}
