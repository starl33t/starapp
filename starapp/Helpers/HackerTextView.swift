//
//  HackerTextView.swift
//  starweb1
//
//  Created by Peter Tran on 03/07/2024.
//

import SwiftUI

struct HackerTextView: View {
    //config
    var text: String
    var trigger: Bool
    var transition: ContentTransition = .interpolate
    var duration: CGFloat = 1.0
    var speed: CGFloat = 0.1
    //view properties
    @State private var animatedText: String = ""
    @State private var randomCharacters: [Character] = {
        let string = "opwqdklvknsoiuosdfosdpfldksdmfnasxhcvkax"
        return Array(string)
    }()
    @State private var animationID: String = UUID().uuidString
    var body: some View {
        Text(animatedText)
            .fontDesign(.monospaced)
            .truncationMode(/*@START_MENU_TOKEN@*/.tail/*@END_MENU_TOKEN@*/)
            .contentTransition(transition)
            .animation(.easeInOut(duration: 0.1), value: animatedText)
            .onAppear{
                guard animatedText.isEmpty else {
                    return
                }
                setRandomCharacters()
                animateText()
            }
            .onChange(of: trigger) { oldValue, newValue in
                animateText()
            }
            .onChange(of: text) { oldValue, newValue in
                animatedText = text
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
        animatedText=text
        for index in animatedText.indices {
            guard let randomCharacter = randomCharacters.randomElement() else {return}
            replaceCharacter(at: index, character: randomCharacter)
            
        }
    }
    func replaceCharacter(at index: String.Index, character: Character){
        guard animatedText.indices.contains(index) else {return}
        let indexCharacter = String(animatedText[index])
        if indexCharacter.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
            animatedText.replaceSubrange(index...index, with: String(character))
        }
    }
}


