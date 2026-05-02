//
//  ContentView.swift
//  VibeCodedComponents
    

import SwiftUI

struct ContentView: View {
    var body: some View {
        ComponentsListScreen {
            ComponentEntry(title: "Fan Menu", date: "March 18", destination: FanMenuView.init)
            ComponentEntry(title: "Gooey Menu", date: "March 21", destination: SmoothGooeyMenu.init)
            ComponentEntry(title: "Expandable QR Button", date: "March 24", destination: ExpandableQRButton.init)
            ComponentEntry(title: "QRCode Interaction Button", date: "March 25", destination: QRCodeInteractionButton.init)
            ComponentEntry(title: "Cook Text", date: "March 27", destination: LoadingCookTextView.init)
            ComponentEntry(title: "AI Loading Indicator", date: "March 29", destination: AILoadingIndicator.init)
            ComponentEntry(title: "Expanding Delete Button", date: "April 1", destination: ExpandingDeleteButton.init)
            ComponentEntry(title: "Notify Me Button", date: "April 2", destination: NotifyMeButton.init)
            ComponentEntry(title: "Wave Text Renderer", date: "April 4", destination: WaveTextRendererView.init)
            ComponentEntry(title: "Segmented Color Control", date: "April 5", destination: SegmentedColorControl.init)
            ComponentEntry(title: "Nested Dynamic Segment", date: "April 6", destination: NestedDynamicSegment.init)
            ComponentEntry(title: "ChatGPT Model Menu", date: "April 7", destination: ChatGPTModelMenu.init)
            ComponentEntry(title: "Discrete Tabs View", date: "April 8", destination: DiscreteTabsView.init)
            ComponentEntry(title: "Split Button Interaction", date: "April 9", destination: SplitButtonInteraction.init)
            ComponentEntry(title: "Feedback Form", date: "April 10", badge: "New", destination: FeedbackFormView.init)
            ComponentEntry(title: "Time Slider", date: "April 11", destination: CustomTimeSlider.init)
            ComponentEntry(title: "Intensity Slider", date: "April 13", destination: IntensitySliderView.init)
            ComponentEntry(title: "Temperature Controls", date: "April 14", destination: TemperatureControlsView.init)
            ComponentEntry(title: "Interactive Time Picker", date: "April 15", destination: InteractiveTimePicker.init)
            ComponentEntry(title: "Fluid Drop Interaction", date: "April 16", destination: FluidDropInteractionView.init)
            ComponentEntry(title: "Preparation Widget", date: "April 17", destination: PreparationWidgetView.init)
            ComponentEntry(title: "Playful Carousel Indicator", date: "April 18", destination: PlayfulCarouselIndicator.init)
            ComponentEntry(title: "Hold To Delete Button", date: "April 19", destination: HoldToDeleteButton.init)
            ComponentEntry(title: "Pomodoro Roller", date: "April 20", destination: PomodoroRollerView.init)
            ComponentEntry(title: "Horizontal Pill Picker", date: "April 21", destination: HorizontalPillPicker.init)
            ComponentEntry(title: "Text Roller", date: "April 22", destination: TextRollerView.init)
            ComponentEntry(title: "Receive Confirmation", date: "April 23", destination: ReceiveConfirmationView.init)
            ComponentEntry(title: "Timer Widget", date: "April 24", destination: PremiumTimerWidget.init)
            ComponentEntry(title: "Battery Widget", date: "April 25", destination: BatteryWidgetView.init)
            ComponentEntry(title: "Orb Loader", date: "April 26", destination: OrbLoaderView.init)
            ComponentEntry(title: "Searching Orb", date: "April 27", destination: SearchingOrbLoader.init)
            ComponentEntry(title: "Joyful Price Stepper", date: "April 28", destination: JoyfulPriceStepper.init)
            ComponentEntry(title: "Drawing Prompt Box", date: "April 29", destination: DrawingPromptBox.init)
            ComponentEntry(title: "Fluid Signing Interaction", date: "April 30", destination: FluidSigningInteraction.init)
            ComponentEntry(title: "Date Picker Interaction", date: "May 1") {
                DatePickerInteractionView()
            }
            ComponentEntry(title: "Liquid Time Picker", date: "May 2", destination: LiquidTimePickerReplicaDemo.init)
            ComponentEntry(title: "Interactive Node", date: "May 2", destination: InteractiveNodeView.init)
            ComponentEntry(title: "Audio Player Component", date: "May 2", destination: AudioPlayerComponentPreview.init)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
