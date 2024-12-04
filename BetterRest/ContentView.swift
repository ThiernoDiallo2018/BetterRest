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
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date { // For a property to be static means it below to the view. Need it to be static if we want to reference it via another property
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("When do you want to wake up?")
                    .font(.headline)
                
                DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                
                Text("Desired amount of sleep")
                    .font(.headline)
                
                Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                
                Text("Daily coffee intake")
                    .font(.headline)
                
                Stepper("\(coffeeAmount) cup(s)", value: $coffeeAmount, in: 1...20, step: 1)
            }
            .navigationTitle("BetterRest")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Calculate", action: calculateBedTime)
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("Ok") {}
            } message: {
                Text(alertMessage)
            }
            
        }
        
    }
    
    // You want to wake up at this time so we will subtract our prediction from that so you should wake up at this time that is presented
    
    func calculateBedTime() { //Putting the model in a do try just in case it fails
        
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
            
            
            
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
        
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime"
        }
        
        showingAlert = true
        
    }
}

#Preview {
    ContentView()
}
