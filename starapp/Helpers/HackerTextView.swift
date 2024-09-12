//
//  HackerTextView.swift
//  starweb1
//
//  Created by Peter Tran on 03/07/2024.
//

import SwiftUI

struct HackerTextView: View {
    @EnvironmentObject var appState: AppState
    var text: String
    var trigger: Bool
    var transition: ContentTransition = .interpolate
    var duration: CGFloat = 1.0
    var speed: CGFloat = 0.1
    @State private var randomCharacters: [Character] = {
        let string = "opwqdklvknsoiuosdfosdpfldksdmfnasxhcvkax"
        return Array(string)
    }()
    @State private var animationID: String = UUID().uuidString
    var body: some View {
        Text(appState.animatedText)
            .fontDesign(.monospaced)
            .fixedSize(horizontal: true, vertical: false) 
            .contentTransition(transition)
            .animation(.easeInOut(duration: 0.1), value: appState.animatedText)
            .onAppear{
                if appState.animatedText != text {
                    setRandomCharacters()
                    animateText()
                }
            }
            .onChange(of: trigger) { oldValue, newValue in
                animateText()
                animationID = UUID().uuidString
            }
            .onChange(of: text) { oldValue, newValue in
                appState.animatedText = text
                animationID = UUID().uuidString
                setRandomCharacters()
                animateText()
            }
        
    }
    private func animateText(){
        let currentID = animationID
        for index in text.indices{
            let delay = CGFloat.random(in: 0...duration)
            var timerDuration: CGFloat = 0
            let timer = Timer.scheduledTimer(withTimeInterval: speed, repeats: true){timer in
                if currentID != animationID{
                    timer.invalidate()
                } else {
                    timerDuration += speed
                    if timerDuration >= delay {
                        if text.indices.contains(index){
                            let actualCharacter = text[index]
                            replaceCharacter(at: index, character: actualCharacter)
                        }
                        timer.invalidate()
                        
                    } else {
                        guard let randomCharacter = randomCharacters.randomElement() else {return}
                        replaceCharacter(at: index, character: randomCharacter)
                    }
                    
                }
                
            }
            timer.fire()
            
        }
        
    }
    
    private func setRandomCharacters(){
        appState.animatedText=text
        for index in appState.animatedText.indices {
            guard let randomCharacter = randomCharacters.randomElement() else {return}
            replaceCharacter(at: index, character: randomCharacter)
            
        }
    }
    
    func replaceCharacter(at index: String.Index, character: Character){
        guard appState.animatedText.indices.contains(index) else {return}
        let indexCharacter = String(appState.animatedText[index])
        if indexCharacter.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
            appState.animatedText.replaceSubrange(index...index, with: String(character))
        }
    }
}


