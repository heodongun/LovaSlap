import CoreGraphics

enum ReactionPhase {
    case idle
    case impact
    case recoil
}

struct ReactionVisual: Equatable {
    let spriteOffset: CGPoint
    let showImpactBurst: Bool
}

final class GameState {
    private(set) var slapCount = 0
    private(set) var reactionPhase: ReactionPhase = .idle

    func triggerSlap() {
        slapCount += 1
        reactionPhase = .impact
    }

    func moveToRecoil() {
        reactionPhase = .recoil
    }

    func settle() {
        reactionPhase = .idle
    }

    var reactionVisual: ReactionVisual {
        switch reactionPhase {
        case .idle:
            return ReactionVisual(spriteOffset: .zero, showImpactBurst: false)
        case .impact:
            return ReactionVisual(spriteOffset: CGPoint(x: -12, y: 8), showImpactBurst: true)
        case .recoil:
            return ReactionVisual(spriteOffset: CGPoint(x: 10, y: -2), showImpactBurst: false)
        }
    }
}
