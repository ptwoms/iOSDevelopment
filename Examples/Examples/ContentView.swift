//
//  ContentView.swift
//  Examples
//
//  Created by Pyae Phyo Myint Soe on 15/1/25.
//

import SwiftUI
import PMPageControlSwiftUI

struct ContentView: View {
    @State private var pageProgress: Bool = false
    var body: some View {
        VStack {
            PMPageControlView(
                numberOfPages: 3,
                currentPage: 0,
                startProgress: $pageProgress
            )
                .frame(height: 10)
        }
        .padding()
        .onAppear {
            pageProgress = true
        }
    }
}

#Preview {
    ContentView()
}
