//
//  navigationView.swift
//  Moyer Calorie Tracker App
//
//  Created by Christian Moyer on 2/28/25.
//
import SwiftUI

struct NavigationViewComponent: View {
    var saveDayData: () -> Void
    var loadPreviousDay: () -> Void
    var loadNextDay: () -> Void
    var formattedDate: (Date) -> String
    var days: [Day]
    var currentIndex: Int

    var body: some View {
        HStack {
            Button(action: {
                saveDayData()
                withAnimation { loadPreviousDay() }
            }) {
                Image(systemName: "arrow.left.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
            }
            .disabled(currentIndex == 0)

            Spacer()

            Text("\(formattedDate(days.indices.contains(currentIndex) ? days[currentIndex].date : Date()))")
                .font(.title)
                .bold()

            Spacer()

            Button(action: {
                saveDayData()
                withAnimation { loadNextDay() }
            }) {
                Image(systemName: "arrow.right.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal, 50)
    }
}
