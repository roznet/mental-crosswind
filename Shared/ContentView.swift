//
//  ContentView.swift
//  Shared
//
//  Created by Brice Rosenzweig on 13/02/2022.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State private var runway: String = "24"
    @State private var announce : String = ""
    @State private var hint : String = ""
    @State private var analysisHint : String = ""
    @State private var analysis : String = ""
    
    var model = RunwayWindModel()
    
    func startUpdateSequence() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
            self.updateAnnounce()
        }
    }
    
    func updateAnnounce() {
        self.announce = model.announce
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
            self.updateHint()
        }
    }

    func updateHint() {
        self.hint = model.hint()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
            self.updateAnalysis()
        }
    }

    func updateAnalysis() {
        self.analysisHint = model.analyseHint()
        self.analysis = model.analyse()
    }
    
    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .center) {
                Text("Runway")
                    .frame(width:60)
                TextField("Runway", text: $runway)
                    .frame(width:60)
                    .padding()
                    .keyboardType(.numberPad)
                    .onReceive(Just(runway)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.runway = filtered
                        }
                    }
            }
            Button("Wind Check") {
                model.runwayHeading = Heading(runwayDescription: self.runway)
                model.randomizeWind()
                self.analysis = ""
                self.announce = ""
                self.hint = ""
                self.analysisHint = ""
                print( model.announce)
                print( model.analyse() )
                model.speak() {
                    self.startUpdateSequence()
                }
            }
            Spacer()
            VStack() {
                Text( self.announce )
                Text( self.hint )
                Text( self.analysisHint )
                Text( self.analysis )
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        var c = ContentView()
        
        return c
    }
}
