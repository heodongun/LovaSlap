import AppKit

@MainActor
final class GameSceneView: NSView {
    private let state = GameState()
    private let script = DialogueScript()

    private let backgroundView = PixelBackgroundView()
    private let characterView = PixelCharacterView()
    private let dialoguePanel = DialoguePanelView()

    private var pendingReactionWork: [DispatchWorkItem] = []

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        translatesAutoresizingMaskIntoConstraints = false
        buildViewHierarchy()
        refreshScene()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    private func buildViewHierarchy() {
        addSubview(backgroundView)
        addSubview(characterView)
        addSubview(dialoguePanel)

        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        characterView.translatesAutoresizingMaskIntoConstraints = false
        dialoguePanel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),

            dialoguePanel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: SceneMetrics.outerPadding),
            dialoguePanel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -SceneMetrics.outerPadding),
            dialoguePanel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -SceneMetrics.outerPadding),
            dialoguePanel.heightAnchor.constraint(equalToConstant: SceneMetrics.dialogueHeight),

            characterView.centerXAnchor.constraint(equalTo: centerXAnchor),
            characterView.bottomAnchor.constraint(equalTo: dialoguePanel.topAnchor, constant: -12),
            characterView.widthAnchor.constraint(equalToConstant: 280),
            characterView.heightAnchor.constraint(equalToConstant: 340)
        ])
    }

    func triggerPhysicalSlap() {
        triggerSharedSlap()
    }

    private func triggerSharedSlap() {
        pendingReactionWork.forEach { $0.cancel() }
        pendingReactionWork.removeAll()

        state.triggerSlap()
        _ = script.advance()
        refreshScene()

        let recoilWork = DispatchWorkItem { [weak self] in
            self?.state.moveToRecoil()
            self?.refreshScene()
        }

        let settleWork = DispatchWorkItem { [weak self] in
            self?.state.settle()
            self?.refreshScene()
        }

        pendingReactionWork = [recoilWork, settleWork]

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08, execute: recoilWork)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18, execute: settleWork)
    }

    private func refreshScene() {
        let line = script.currentLine
        characterView.update(mood: line.mood, reaction: state.reactionVisual)
        dialoguePanel.update(with: line)
    }
}

@MainActor
final class DialoguePanelView: NSView {
    private let speakerLabel = NSTextField(labelWithString: "")
    private let dialogueLabel = NSTextField(wrappingLabelWithString: "")
    private let instructionLabel = NSTextField(labelWithString: "맥북 본체를 톡 쳐 보세요")

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = ScenePalette.dialogueBackground.cgColor
        layer?.borderColor = ScenePalette.dialogueBorder.cgColor
        layer?.borderWidth = SceneMetrics.borderWidth
        layer?.cornerRadius = SceneMetrics.dialogueCorner

        setupLabels()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func update(with line: DialogueLine) {
        speakerLabel.stringValue = line.speaker
        dialogueLabel.stringValue = line.text
    }

    private func setupLabels() {
        [speakerLabel, dialogueLabel, instructionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
            $0.backgroundColor = .clear
            $0.isBezeled = false
            $0.isEditable = false
            $0.drawsBackground = false
            $0.lineBreakMode = .byWordWrapping
        }

        speakerLabel.font = SceneTypography.speaker
        speakerLabel.textColor = ScenePalette.accentPink

        dialogueLabel.font = SceneTypography.dialogue
        dialogueLabel.textColor = ScenePalette.textPrimary
        dialogueLabel.maximumNumberOfLines = 3

        instructionLabel.font = SceneTypography.detail
        instructionLabel.textColor = ScenePalette.textSecondary
        instructionLabel.alignment = .right

        NSLayoutConstraint.activate([
            speakerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            speakerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),

            instructionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            instructionLabel.centerYAnchor.constraint(equalTo: speakerLabel.centerYAnchor),

            dialogueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            dialogueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            dialogueLabel.topAnchor.constraint(equalTo: speakerLabel.bottomAnchor, constant: 14),
            dialogueLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -18)
        ])
    }
}

@MainActor
final class PixelCharacterView: NSView {
    private var mood: CharacterMood = .calm
    private var reaction = ReactionVisual(spriteOffset: .zero, showImpactBurst: false)

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func update(mood: CharacterMood, reaction: ReactionVisual) {
        self.mood = mood
        self.reaction = reaction
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let pixel = floor(min(bounds.width / 20, bounds.height / 26))
        let spriteWidth = pixel * 20
        let spriteHeight = pixel * 26
        let originX = floor((bounds.width - spriteWidth) / 2 + reaction.spriteOffset.x)
        let originY = floor((bounds.height - spriteHeight) / 2 + reaction.spriteOffset.y)

        drawPixelRect(x: 4, y: 1, w: 12, h: 1, color: ScenePalette.shadow, pixel: pixel, originX: originX, originY: originY)

        drawPixelRect(x: 8, y: 1, w: 1, h: 4, color: ScenePalette.skin, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 11, y: 1, w: 1, h: 4, color: ScenePalette.skin, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 7, y: 5, w: 6, h: 1, color: ScenePalette.dressShadow, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 6, y: 6, w: 8, h: 6, color: ScenePalette.dress, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 5, y: 8, w: 1, h: 3, color: ScenePalette.skin, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 14, y: 8, w: 1, h: 3, color: ScenePalette.skin, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 6, y: 12, w: 8, h: 1, color: ScenePalette.ribbon, pixel: pixel, originX: originX, originY: originY)

        drawPixelRect(x: 5, y: 13, w: 10, h: 7, color: ScenePalette.hairShadow, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 7, y: 13, w: 6, h: 1, color: ScenePalette.skin, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 6, y: 14, w: 8, h: 5, color: ScenePalette.skin, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 7, y: 19, w: 6, h: 1, color: ScenePalette.skin, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 4, y: 14, w: 2, h: 6, color: ScenePalette.hair, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 14, y: 14, w: 2, h: 6, color: ScenePalette.hair, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 5, y: 13, w: 1, h: 1, color: ScenePalette.hair, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 14, y: 13, w: 1, h: 1, color: ScenePalette.hair, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 7, y: 18, w: 6, h: 1, color: ScenePalette.hair, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 6, y: 20, w: 8, h: 2, color: ScenePalette.hair, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 8, y: 23, w: 4, h: 1, color: ScenePalette.ribbon, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 6, y: 22, w: 2, h: 2, color: ScenePalette.ribbon, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 12, y: 22, w: 2, h: 2, color: ScenePalette.ribbon, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 9, y: 21, w: 2, h: 2, color: ScenePalette.accentRose, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 7, y: 15, w: 2, h: 1, color: ScenePalette.blush, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 11, y: 15, w: 2, h: 1, color: ScenePalette.blush, pixel: pixel, originX: originX, originY: originY)

        drawFace(pixel: pixel, originX: originX, originY: originY)

        if reaction.showImpactBurst {
            drawImpactBurst(pixel: pixel, originX: originX, originY: originY)
        }
    }

    private func drawFace(pixel: CGFloat, originX: CGFloat, originY: CGFloat) {
        switch mood {
        case .calm:
            drawPixelRect(x: 7, y: 18, w: 2, h: 1, color: ScenePalette.hairShadow, pixel: pixel, originX: originX, originY: originY)
            drawPixelRect(x: 11, y: 18, w: 2, h: 1, color: ScenePalette.hairShadow, pixel: pixel, originX: originX, originY: originY)
            drawPixelRect(x: 8, y: 17, w: 1, h: 1, color: ScenePalette.eye, pixel: pixel, originX: originX, originY: originY)
            drawPixelRect(x: 11, y: 17, w: 1, h: 1, color: ScenePalette.eye, pixel: pixel, originX: originX, originY: originY)
            drawPixelRect(x: 9, y: 14, w: 2, h: 1, color: ScenePalette.accentRose, pixel: pixel, originX: originX, originY: originY)
        case .startled:
            drawPixelRect(x: 8, y: 16, w: 1, h: 2, color: ScenePalette.eye, pixel: pixel, originX: originX, originY: originY)
            drawPixelRect(x: 11, y: 16, w: 1, h: 2, color: ScenePalette.eye, pixel: pixel, originX: originX, originY: originY)
            drawPixelRect(x: 9, y: 14, w: 2, h: 2, color: ScenePalette.accentRose, pixel: pixel, originX: originX, originY: originY)
        case .pout:
            drawPixelRect(x: 7, y: 17, w: 2, h: 1, color: ScenePalette.eye, pixel: pixel, originX: originX, originY: originY)
            drawPixelRect(x: 11, y: 16, w: 2, h: 1, color: ScenePalette.eye, pixel: pixel, originX: originX, originY: originY)
            drawPixelRect(x: 9, y: 14, w: 2, h: 1, color: ScenePalette.accentRose, pixel: pixel, originX: originX, originY: originY)
        case .dizzy:
            drawPixelRect(x: 7, y: 16, w: 2, h: 1, color: ScenePalette.eye, pixel: pixel, originX: originX, originY: originY)
            drawPixelRect(x: 8, y: 17, w: 1, h: 2, color: ScenePalette.eye, pixel: pixel, originX: originX, originY: originY)
            drawPixelRect(x: 11, y: 16, w: 2, h: 1, color: ScenePalette.eye, pixel: pixel, originX: originX, originY: originY)
            drawPixelRect(x: 11, y: 17, w: 1, h: 2, color: ScenePalette.eye, pixel: pixel, originX: originX, originY: originY)
            drawPixelRect(x: 9, y: 14, w: 2, h: 1, color: ScenePalette.accentRose, pixel: pixel, originX: originX, originY: originY)
        }
    }

    private func drawImpactBurst(pixel: CGFloat, originX: CGFloat, originY: CGFloat) {
        drawPixelRect(x: 15, y: 16, w: 2, h: 1, color: ScenePalette.impactOutline, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 16, y: 15, w: 1, h: 3, color: ScenePalette.impact, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 17, y: 16, w: 1, h: 1, color: ScenePalette.impactOutline, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 15, y: 18, w: 1, h: 1, color: ScenePalette.impact, pixel: pixel, originX: originX, originY: originY)
    }

    private func drawPixelRect(
        x: CGFloat,
        y: CGFloat,
        w: CGFloat,
        h: CGFloat,
        color: NSColor,
        pixel: CGFloat,
        originX: CGFloat,
        originY: CGFloat
    ) {
        color.setFill()
        NSRect(
            x: originX + (x * pixel),
            y: originY + (y * pixel),
            width: w * pixel,
            height: h * pixel
        ).fill()
    }
}

@MainActor
final class PixelBackgroundView: NSView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        ScenePalette.windowBackground.setFill()
        dirtyRect.fill()

        let pixel = SceneMetrics.pixel
        let wallRect = NSRect(x: 0, y: bounds.height * 0.28, width: bounds.width, height: bounds.height * 0.72)
        let floorRect = NSRect(x: 0, y: 0, width: bounds.width, height: bounds.height * 0.28)

        ScenePalette.wall.setFill()
        wallRect.fill()
        ScenePalette.floor.setFill()
        floorRect.fill()

        for row in stride(from: wallRect.minY + 24, to: wallRect.maxY - 24, by: pixel * 3) {
            for column in stride(from: 48 as CGFloat, to: bounds.width - 48, by: pixel * 4) {
                let tile = NSRect(x: column, y: row, width: pixel, height: pixel)
                if Int((column + row) / pixel).isMultiple(of: 2) {
                    ScenePalette.wallAccent.setFill()
                    tile.fill()
                }
            }
        }

        for row in stride(from: floorRect.minY, to: floorRect.maxY, by: pixel * 2) {
            ScenePalette.floorStripe.setFill()
            NSRect(x: 0, y: row, width: bounds.width, height: pixel).fill()
        }

        drawWindow(pixel: pixel)
        drawFurniture(pixel: pixel)
    }

    private func drawWindow(pixel: CGFloat) {
        let frame = NSRect(x: 88, y: 364, width: pixel * 20, height: pixel * 14)
        ScenePalette.dialogueBorder.setFill()
        frame.fill()

        let inset = frame.insetBy(dx: pixel, dy: pixel)
        ScenePalette.wallAccent.setFill()
        inset.fill()

        ScenePalette.moon.setFill()
        NSRect(x: inset.minX + pixel * 11, y: inset.minY + pixel * 8, width: pixel * 2, height: pixel * 2).fill()
        ScenePalette.accentSky.setFill()
        NSRect(x: inset.minX + pixel * 3, y: inset.minY + pixel * 3, width: pixel * 9, height: pixel * 4).fill()
        NSRect(x: inset.midX - (pixel / 2), y: inset.minY, width: pixel, height: inset.height).fill()
        NSRect(x: inset.minX, y: inset.midY - (pixel / 2), width: inset.width, height: pixel).fill()
    }

    private func drawFurniture(pixel: CGFloat) {
        ScenePalette.hairShadow.setFill()
        NSRect(x: bounds.width - 220, y: 190, width: 120, height: 18).fill()
        NSRect(x: bounds.width - 210, y: 208, width: 12, height: 72).fill()
        NSRect(x: bounds.width - 122, y: 208, width: 12, height: 72).fill()

        ScenePalette.accentMint.setFill()
        NSRect(x: bounds.width - 200, y: 236, width: 24, height: 28).fill()
        ScenePalette.accentRose.setFill()
        NSRect(x: bounds.width - 168, y: 236, width: 24, height: 20).fill()
    }
}
