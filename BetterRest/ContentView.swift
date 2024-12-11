//
//  ContentView.swift
//  BetterRest
//
//  Created by Thierno Diallo on 11/29/24.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime //created defaultwaketime so people can see the 7am
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    static var defaultWakeTime: Date { // For a property to be static means it below to the view. Need it to be static if we want to reference it via another property
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var sleepResults: String {
        do { //
            
            let config = MLModelConfiguration() //create an instance so we can access MLModelConfiguration
            let model = try SleepCalculator(configuration: config) //We have bought in the model and are now able to access it
            
            //We want the it to be shown in hours and minutes
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp) //Split the code into hour and minute
            let hour = (components.hour ?? 0) * 60 * 60 //converting to seconds since model is in seconds
            let minute = (components.minute ?? 0) * 60 //converting to seconds since model is in seconds
            
            
            //Deals with the prediction
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            
            return "Your ideal bedtime is " + sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            
            return "There was an error"
        }

    }
    
    var body: some View {
        NavigationStack {
            Form {
                
                Section("When do you want to Wake Up?") {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                Section("Desired Amount of Sleep") {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                Section("Daily Coffee Intake") {
                    Picker("Number of Cups", selection: $coffeeAmount) {
                        ForEach(0..<21) {
                            Text(String($0))
                        }
                    }
                }
                
                Text(sleepResults)
                    .font(.headline)
            }
            .navigationTitle("BetterRest")
            .navigationBarTitleDisplayMode(.inline)
            .listSectionSpacing(.compact)
        }
        
    }
}

#Preview {
    ContentView()
}
