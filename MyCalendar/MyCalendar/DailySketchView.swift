//
//  DailySketchView.swift
//  MyCalendar
//
//  Created by Raif Agovic on 14. 7. 2025..
//

import SwiftUI
import PencilKit

struct DailySketchView: View {
    @State private var canvasView = PKCanvasView()
    let selectedDate: Date

    var body: some View {
        VStack {
            Text("Sketch for \(formattedDate(selectedDate))")
                .font(.headline)
                .padding()

            DrawingView(canvasView: $canvasView)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()

            HStack {
                Button("Save") {
                    saveDrawing(for: selectedDate)
                }
                Button("Load") {
                    loadDrawing(for: selectedDate)
                }
            }
            .padding()
        }
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    func fileURL(for date: Date) -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent("\(formattedDate(date)).drawing")
    }

    func saveDrawing(for date: Date) {
        do {
            let data = try canvasView.drawing.dataRepresentation()
            try data.write(to: fileURL(for: date))
        } catch {
            print("Failed to save drawing: \(error)")
        }
    }

    func loadDrawing(for date: Date) {
        do {
            let data = try Data(contentsOf: fileURL(for: date))
            let drawing = try PKDrawing(data: data)
            canvasView.drawing = drawing
        } catch {
            print("No drawing found or failed to load: \(error)")
            canvasView.drawing = PKDrawing()
        }
    }
}
