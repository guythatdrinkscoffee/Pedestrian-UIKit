//
//  CSVMaker.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/24/23.
//

import Foundation
import CSV

final class CSVMaker {
    // MARK: - Properties
    private var data: [PedestrianDay]
    private var distanceUnits: DistanceUnits?
    
    // MARK: - Life cycle
    init(data: [PedestrianDay], distanceUnits: DistanceUnits? = .miles) {
        self.data = data
        self.distanceUnits = distanceUnits
    }
    
    // MARK: - Private Methods
    private func writeHeaders(headers: [String], writer: CSVWriter) {
        do {
            try writer.write(row: headers)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func writeRows(data: [PedestrianDay], writer: CSVWriter) {
        for day in data {
            writeRow(day, writer: writer)
        }
        
        writer.stream.close()
    }
    
    private func writeRow(_ pedestrianData: PedestrianDay, writer: CSVWriter) {
        writer.beginNewRow()
        
        do {
            try writer.write(field: pedestrianData.startDate?.formatted(.dateTime.day().month().year()) ?? " ")
            try writer.write(field: pedestrianData.numberOfSteps.formatted(.number))
            
            let unitLength: UnitLength = distanceUnits == .miles ? .miles : .kilometers
            let distance = Measurement<UnitLength>(value: pedestrianData.distanceInMeters, unit: .meters).converted(to: unitLength)
            let distanceString = distance.formatted(.measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(2))))
            
            try writer.write(field: distanceString)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Public Methods
    public func makeCSV() -> URL? {
        do {
            let writer = try CSVWriter(stream: .toMemory())
            
            writeHeaders(headers: ["Date", "Step Count", "Distance"], writer: writer)
            writeRows(data: data, writer: writer)
            
            if let data = writer.stream.property(forKey: .dataWrittenToMemoryStreamKey) as? Data,
               let output = String(data: data, encoding: .utf8) {
                
                let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
                let filePath = cacheDirectory.appendingPathComponent("Steps_\(UUID().uuidString).csv")
                
                try output.write(to: filePath, atomically: true, encoding: .utf8)
                
                return filePath
            }
            
            return nil
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
