import Foundation

enum CharacterMood {
    case calm
    case startled
    case pout
    case dizzy
}

struct DialogueLine: Equatable {
    let speaker: String
    let text: String
    let mood: CharacterMood
}

final class DialogueScript {
    private let lines: [DialogueLine] = [
        DialogueLine(
            speaker: "미연",
            text: "히잉... 맥북을 톡 칠 거면, 조금은 귀엽게 해 줘.",
            mood: .calm
        ),
        DialogueLine(
            speaker: "미연",
            text: "앗, 너무해! 방금 리본이 날아갈 뻔했잖아.",
            mood: .startled
        ),
        DialogueLine(
            speaker: "미연",
            text: "끝까지 이 콘셉트로 가네...? 나, 지금 조용히 삐졌어.",
            mood: .pout
        ),
        DialogueLine(
            speaker: "미연",
            text: "으으... 별 돈다... 알겠어. 오늘은 여기까지만 톡 쳐 줘.",
            mood: .dizzy
        )
    ]

    private var index = 0

    var currentLine: DialogueLine {
        lines[index]
    }

    var count: Int {
        lines.count
    }

    func advance() -> DialogueLine {
        if index < lines.count - 1 {
            index += 1
        }

        return lines[index]
    }
}
