//
//  EntryPhotoProcessor.swift
//  Fluel
//
//  Created by Codex on 2026/07/13.
//

import Foundation
import ImageIO
import UniformTypeIdentifiers

// swiftlint:disable no_magic_numbers

enum EntryPhotoProcessor {
    enum ProcessingError: Error {
        case invalidImage
        case imageTooLarge
        case encodingFailed
    }

    private enum Limit {
        nonisolated static let maximumInputByteCount = 100 * 1_024 * 1_024
        nonisolated static let maximumOutputByteCount = 4 * 1_024 * 1_024
        nonisolated static let maximumPixelSize = 2_048
    }

    nonisolated private static let compressionQualities = [0.82, 0.68, 0.54]

    nonisolated static func process(_ fileURL: URL) throws -> Data {
        let fileSize = try fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize

        guard let fileSize,
              fileSize <= Limit.maximumInputByteCount,
              let source = CGImageSourceCreateWithURL(
                fileURL as CFURL,
                [kCGImageSourceShouldCache: false] as CFDictionary
              ) else {
            throw ProcessingError.invalidImage
        }

        return try process(source)
    }

    nonisolated static func process(_ data: Data) throws -> Data {
        guard !data.isEmpty,
              data.count <= Limit.maximumInputByteCount,
              let source = CGImageSourceCreateWithData(
                data as CFData,
                [kCGImageSourceShouldCache: false] as CFDictionary
              ),
              CGImageSourceGetCount(source) > 0 else {
            throw ProcessingError.invalidImage
        }

        return try process(source)
    }

    nonisolated private static func process(_ source: CGImageSource) throws -> Data {
        try Task.checkCancellation()

        guard CGImageSourceGetCount(source) > 0 else {
            throw ProcessingError.invalidImage
        }

        let thumbnailOptions: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: Limit.maximumPixelSize
        ]

        guard let image = CGImageSourceCreateThumbnailAtIndex(
            source,
            CGImageSourceGetPrimaryImageIndex(source),
            thumbnailOptions as CFDictionary
        ) else {
            throw ProcessingError.invalidImage
        }

        for compressionQuality in compressionQualities {
            try Task.checkCancellation()

            let encodedData = try encode(
                image,
                compressionQuality: compressionQuality
            )

            if encodedData.count <= Limit.maximumOutputByteCount {
                return encodedData
            }
        }

        throw ProcessingError.imageTooLarge
    }

    nonisolated private static func encode(
        _ image: CGImage,
        compressionQuality: Double
    ) throws -> Data {
        let data = NSMutableData()

        guard let destination = CGImageDestinationCreateWithData(
            data,
            UTType.jpeg.identifier as CFString,
            1,
            nil
        ) else {
            throw ProcessingError.encodingFailed
        }

        let properties: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: compressionQuality
        ]
        CGImageDestinationAddImage(
            destination,
            image,
            properties as CFDictionary
        )

        guard CGImageDestinationFinalize(destination) else {
            throw ProcessingError.encodingFailed
        }

        return data as Data
    }
}

// swiftlint:enable no_magic_numbers
