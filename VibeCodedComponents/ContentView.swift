//
//  ContentView.swift
//  VibeCodedComponents
    

import SwiftUI

struct ContentView: View {
    var body: some View {
        Form {
            Section("Tests") {
                NavigationLink("BankingWidgetView") {
                    ZStack {
                        // Light grey screen background to make the widget pop
                        Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                        BankWidgetView()
                    }
                }
            }
            
            NavigationLink("Gooey Menu", destination: SmoothGooeyMenu.init)
            NavigationLink("Expandable QR Button", destination: ExpandableQRButton.init)
            NavigationLink("QRCode Interaction Button", destination: QRCodeInteractionButton.init)
            NavigationLink("Cook Text", destination: LoadingCookTextView.init)
            NavigationLink("AI Loading Indicator", destination: AILoadingIndicator.init)
            NavigationLink("Expanding Delete Button", destination: ExpandingDeleteButton.init)
            NavigationLink("Notify Me Button", destination: NotifyMeButton.init)
            NavigationLink("Wave Text Renderer", destination: WaveTextRendererView.init)
            NavigationLink("Segmented Color Control", destination: SegmentedColorControl.init)
            NavigationLink("Nested Dynamic Segment", destination: NestedDynamicSegment.init)
            NavigationLink("ChatGPT Model Menu", destination: ChatGPTModelMenu.init)
            NavigationLink("Discrete Tabs View", destination: DiscreteTabsView.init)
            NavigationLink("Split Button Interaction", destination: SplitButtonInteraction.init)
            NavigationLink("Feedback Form", destination: FeedbackFormView.init)
            NavigationLink("Time Slider", destination: CustomTimeSlider.init)
            NavigationLink("Intensity Slider", destination: IntensitySliderView.init)
            NavigationLink("Temperature Controls", destination: TemperatureControlsView.init)
            NavigationLink("Interactive Time Picker", destination: InteractiveTimePicker.init)
            NavigationLink("Fluid Drop Interaction", destination: FluidDropInteractionView.init)
            NavigationLink("Preparation Widget", destination: PreparationWidgetView.init)
            NavigationLink("Playful Carousel Indicator", destination: PlayfulCarouselIndicator.init)
            NavigationLink("Hold To Delete Button", destination: HoldToDeleteButton.init)
            NavigationLink("Pomodoro Roller", destination: PomodoroRollerView.init)
            NavigationLink("Horizontal Pill Picker", destination: HorizontalPillPicker.init)
            NavigationLink("Text Roller", destination: TextRollerView.init)
            NavigationLink("Receive Confirmation", destination: ReceiveConfirmationView.init)
            NavigationLink("Timer Widget", destination: PremiumTimerWidget.init)
            NavigationLink("Battery Widget", destination: BatteryWidgetView.init)
            NavigationLink("Orb Loader", destination: OrbLoaderView.init)
            NavigationLink("Searching Orb", destination: SearchingOrbLoader.init)
            NavigationLink("Joyful Price Stepper", destination: JoyfulPriceStepper.init)
            NavigationLink("Drawing Prompt Box", destination: DrawingPromptBox.init)
            NavigationLink("Fluid Signing Interaction", destination: FluidSigningInteraction.init)
            NavigationLink("Date Picker Interaction") { DatePickerInteractionView() }
            NavigationLink("Liquid Time Picker", destination: LiquidTimePickerReplicaDemo.init)
            NavigationLink("Interactive Node", destination: InteractiveNodeView.init)
            NavigationLink("Audio Player Component", destination: AudioPlayerComponentPreview.init)
        }
    }
}
