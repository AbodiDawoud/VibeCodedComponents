//
//  ContentView.swift
//  VibeCodedComponents
    

import SwiftUI

struct ContentView: View {
    var body: some View {
        ComponentsListScreen {
            ComponentEntry(title: "Fan Menu", date: "April 12", destination: FanMenuView.init)
            ComponentEntry(title: "Gooey Menu", date: "April 12", destination: SmoothGooeyMenu.init)
            ComponentEntry(title: "Expandable QR Button", date: "April 12", destination: ExpandableQRButton.init)
            ComponentEntry(title: "QRCode Interaction Button", date: "April 12", destination: QRCodeInteractionButton.init)
            ComponentEntry(title: "Cook Text", date: "April 12", destination: LoadingCookTextView.init)
            ComponentEntry(title: "AI Loading Indicator", date: "April 12", destination: AILoadingIndicator.init)
            ComponentEntry(title: "Expanding Delete Button", date: "April 12", destination: ExpandingDeleteButton.init)
            ComponentEntry(title: "Notify Me Button", date: "April 12", destination: NotifyMeButton.init)
            ComponentEntry(title: "Wave Text Renderer", date: "April 12", destination: WaveTextRendererView.init)
            ComponentEntry(title: "Segmented Color Control", date: "April 12", destination: SegmentedColorControl.init)
            ComponentEntry(title: "Nested Dynamic Segment", date: "April 12", destination: NestedDynamicSegment.init)
            ComponentEntry(title: "ChatGPT Model Menu", date: "April 12", destination: ChatGPTModelMenu.init)
            ComponentEntry(title: "Discrete Tabs View", date: "April 12", destination: DiscreteTabsView.init)
            ComponentEntry(title: "Split Button Interaction", date: "April 12", destination: SplitButtonInteraction.init)
            ComponentEntry(title: "Feedback Form", date: "April 12", badge: "New", destination: FeedbackFormView.init)
            ComponentEntry(title: "Time Slider", date: "April 12", destination: CustomTimeSlider.init)
            ComponentEntry(title: "Intensity Slider", date: "April 12", destination: IntensitySliderView.init)
            ComponentEntry(title: "Temperature Controls", date: "April 12", destination: TemperatureControlsView.init)
            ComponentEntry(title: "Interactive Time Picker", date: "April 12", destination: InteractiveTimePicker.init)
            ComponentEntry(title: "Fluid Drop Interaction", date: "April 12", destination: FluidDropInteractionView.init)
            ComponentEntry(title: "Preparation Widget", date: "April 12", destination: PreparationWidgetView.init)
            ComponentEntry(title: "Playful Carousel Indicator", date: "April 12", destination: PlayfulCarouselIndicator.init)
            ComponentEntry(title: "Hold To Delete Button", date: "April 12", destination: HoldToDeleteButton.init)
            ComponentEntry(title: "Pomodoro Roller", date: "April 12", destination: PomodoroRollerView.init)
            ComponentEntry(title: "Horizontal Pill Picker", date: "April 12", destination: HorizontalPillPicker.init)
            ComponentEntry(title: "Text Roller", date: "April 12", destination: TextRollerView.init)
            ComponentEntry(title: "Receive Confirmation", date: "April 12", destination: ReceiveConfirmationView.init)
            ComponentEntry(title: "Timer Widget", date: "April 12", destination: PremiumTimerWidget.init)
            ComponentEntry(title: "Battery Widget", date: "April 12", destination: BatteryWidgetView.init)
            ComponentEntry(title: "Orb Loader", date: "April 12", destination: OrbLoaderView.init)
            ComponentEntry(title: "Searching Orb", date: "April 12", destination: SearchingOrbLoader.init)
            ComponentEntry(title: "Joyful Price Stepper", date: "April 12", destination: JoyfulPriceStepper.init)
            ComponentEntry(title: "Drawing Prompt Box", date: "April 12", destination: DrawingPromptBox.init)
            ComponentEntry(title: "Fluid Signing Interaction", date: "April 12", destination: FluidSigningInteraction.init)
            ComponentEntry(title: "Date Picker Interaction", date: "April 12") {
                DatePickerInteractionView()
            }
            ComponentEntry(title: "Liquid Time Picker", date: "April 12", destination: LiquidTimePickerReplicaDemo.init)
            ComponentEntry(title: "Interactive Node", date: "April 12", destination: InteractiveNodeView.init)
            ComponentEntry(title: "Audio Player Component", date: "April 12", destination: AudioPlayerComponentPreview.init)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
