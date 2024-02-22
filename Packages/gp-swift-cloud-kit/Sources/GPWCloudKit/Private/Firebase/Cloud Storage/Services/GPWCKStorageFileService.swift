//
// gp-webrtc-ios/swift-cloud-kit
// Copyright (c) 2024, Greg PFISTER. MIT License
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the “Software”), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#if canImport(FirebaseStorage)
import FirebaseStorage
import Foundation

/// ``GPWCKStorageFileService`` allows to access file on a Firebase Storage bucket
class GPWCKStorageFileService {
    typealias GPWCKOnUploadCompletionCallback = (URL?, GPWCKStorageError?) -> Void
    typealias GPWCKOnDownloadCompletionCallback = (Data?, GPWCKStorageError?) -> Void

    private let storage: Storage

    // MARK: - Initialiser

    /// Initialise a service to download/upload file to Firebase Storage from the default bucket
    ///
    ///  - Parameters
    ///    - bucket: The URL of the custom bucket to be used.
    init() {
        storage = Storage.storage()
    }

    /// Initialise a service to download/upload file to Firebase Storage from a given custom bucket
    ///
    ///  - Parameters
    ///    - bucket: The URL of the custom bucket to be used.
    init(bucket: String) {
        storage = Storage.storage(url: bucket)
    }

    // MARK: - Helpers

    /// Provide the Firebase Storage URL (gs://{bucket}/{path} for a given path.
    ///
    /// This helper is useful when implementing local caching, in order to have a unique string for the given
    /// path.
    ///
    /// - Parameters:
    ///     - forPath: The path of the given file. The path is relative to the bucket root
    ///
    /// - Returns: The url
    func url(forPath path: String) -> String {
        "gs://\(storage.reference().bucket)/\(path)"
    }

    // MARK: - Download data

    /// Download the file at a given path
    ///
    /// Downloading using this method doesn't provide a way to cancel the download, it should therefore
    /// be used only for small files. Otherwise, please consider using
    /// ``GPWCKStorageFileService/download(atPath:maxSize:onCompletion:)``.
    ///
    /// - Parameters:
    ///     - path: The path of the file
    ///     - size: The maximum size allowed to be downloaded
    ///
    /// - Returns: The data of the file
    func download(
        atPath path: String,
        maxSize size: Int64 = 1 * 1024 * 1024
    ) async throws -> Data {
        try await withUnsafeThrowingContinuation { continuation in
            let _ = download(atPath: path, maxSize: size) { data, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let data else {
                    continuation.resume(throwing: GPWCKStorageError())
                    return
                }

                continuation.resume(returning: data)
            }
        }
    }

    /// Download the file at a given path
    ///
    /// This function can be wrapped into a publisher to provide control over its execution:
    ///
    /// ```swift
    /// class StorageFileViewModel: ObservableObject {
    ///     let storageFileService = GPWCKStorageFileService()
    ///     private var downloadTask: StorageDownloadTask? = nil
    ///
    ///     /// Return a publisher that can be observed when data is received
    ///     func downloadDataTask(atPath path: String, maxSize: Int) -> AnyPublisher<Data?, GPWCKStorageError> {
    ///         // Cancel older download task, if any
    ///         if let downloadTask = self.downloadTask {
    ///             downloadTask.cancel()
    ///             self.downloadTask = nil
    ///         }
    ///
    ///         // Return the publisher
    ///         return Future<Data?, GPWCKStorageError> { promise in
    ///             self.downloadTask = storageFileService.download(atPath: path, maxSize: maxSize) { (data, error) in
    ///                 if let error = error {
    ///                     promise(.failure(GPWCKStorageError(from: error)))
    ///                    return
    ///                 }
    ///                 promise(.success(data))
    ///             }
    ///         }
    ///         .handleEvents(
    ///             receiveCompletion: { _ in self.downloadTask = nil},
    ///             receiveCancel: {
    ///                 if let downloadTask = self.downloadTask {
    ///                     downloadTask.cancel()
    ///                     self.downloadTask = nil
    ///                 }
    ///             }
    ///         ).eraseToAnyPublisher()
    ///     }
    ///
    ///     /// Cancel the current download task
    ///     func cancelDownload() {
    ///         if let downloadTask = self.downloadTask {
    ///             downloadTask.cancel()
    ///             self.downloadTask = nil
    ///         }
    ///     }
    ///
    ///     /// Pause the current download
    ///     func pauseDownload() {
    ///         if let downloadTask = self.downloadTask {
    ///             downloadTask.pause()
    ///         }
    ///     }
    ///
    ///     /// Resume the download
    ///     func resumeDownload() {
    ///         if let downloadTask = self.downloadTask {
    ///             downloadTask.resume()
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// Alternatively, when it is not required to control the download task,
    /// ``GPWCKStorageFileService/download(atPath:maxSize:)`` can be userd
    ///
    /// - Parameters:
    ///     - path: The path of the file
    ///     - size: The maximum size allowed to be downloaded
    ///     - onCompletionCallback: A block that will be executed when the download completes
    ///
    /// - Returns: The data of the file
    func download(
        atPath path: String,
        maxSize size: Int64 = 1 * 1024 * 1024,
        onCompletion onCompletionCallback: @escaping GPWCKOnDownloadCompletionCallback = { _, _ in }
    ) -> StorageDownloadTask {
        let storageRef = storage.reference().child(path)

        // Get the data
        return storageRef.getData(maxSize: size) { data, error in
            if let error {
                onCompletionCallback(nil, GPWCKStorageError(from: error))
                return
            }

            onCompletionCallback(data, nil)
        }
    }

    // MARK: - Upload data

    /// Upload data into a file at a given path
    ///
    /// Uploading using this method doesn't provide a way to cancel the upload, it should therefore
    /// be used only for small files. Otherwise, please consider using
    /// ``GPWCKStorageFileService/upload(_:atPath:maxSize:onCompletion:)``.
    ///
    /// - Parameters:
    ///     - data: The to be uploaded
    ///     - path: The path of the file
    ///
    /// - Returns: A URL that can be shared unless the assigned token is revoked on the storage side
    func upload(
        _ data: Data,
        metadata: GPWCKStorageMetadata? = nil,
        atPath path: String
    ) async throws -> URL {
        try await withUnsafeThrowingContinuation { continuation in
            let _ = upload(data, metadata: metadata, atPath: path) { url, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let url else {
                    continuation.resume(throwing: GPWCKStorageError())
                    return
                }

                continuation.resume(returning: url)
            }
        }
    }

    /// Upload data into a file at a given path
    ///
    /// This function can be wrapped into a publisher to provide control over its execution. For example:
    ///
    /// ```swift
    /// class StorageFileViewModel: ObservableObject {
    ///     let storageFileService = GPWCKStorageFileService()
    ///     private var uploadTask: StorageUploadTask? = nil
    ///
    ///     /// Return a publisher that can be observed when data is received
    ///     func uploadDataTask(data, atPath path: String, maxSize: Int) -> AnyPublisher<(String?, String?), GPWCKStorageError> {
    ///         // Cancel older download task, if any
    ///         if let uploadTask = self.uploadTask {
    ///             uploadTask.cancel()
    ///             self.uploadTask = nil
    ///         }
    ///
    ///         // Return the publisher
    ///         return Future<Data?, GPWCKStorageError> { promise in
    ///             self.uploadTask = self.upload(data, atPath: path, maxSize: maxSize) { ((filename, url), error) in
    ///                 if let error = error {
    ///                     promise(.failure(GPWCKStorageError(from: error)))
    ///                    return
    ///                 }
    ///                 guard let url
    ///                 promise(.success(data))
    ///             }
    ///         }
    ///         .handleEvents(
    ///             receiveCompletion: { _ in self.uploadTask = nil },
    ///             receiveCancel: {
    ///                 if let uploadTask = self.uploadTask {
    ///                     uploadTask.cancel()
    ///                     self.uploadTask = nil
    ///                 }
    ///             }
    ///         ).eraseToAnyPublisher()
    ///     }
    ///
    ///     /// Cancel the current download task
    ///     func cancelDownload() {
    ///         if let uploadTask = self.uploadTask {
    ///             uploadTask.cancel()
    ///             self.uploadTask = nil
    ///         }
    ///     }
    ///
    ///     /// Pause the current download
    ///     func pauseDownload() {
    ///         if let uploadTask = self.uploadTask {
    ///             uploadTask.pause()
    ///         }
    ///     }
    ///
    ///     /// Resume the download
    ///     func resumeDownload() {
    ///         if let uploadTask = self.uploadTask {
    ///             uploadTask.resume()
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// Alternatively, when it is not required to control the download task,
    /// ``GPWCKStorageFileService/download(atPath:maxSize:)`` can be userd
    ///
    /// - Parameters:
    ///     - data: The to be uploaded
    ///     - path: The path of the file
    ///     - onCompletionCallback: A block that will be executed when the upload completes
    ///
    /// - Returns: A URL that can be shared unless the assigned token is revoked on the storage side
    func upload(
        _ data: Data,
        metadata: GPWCKStorageMetadata? = nil,
        atPath path: String,
        onCompletion onCompletionCallback: @escaping GPWCKOnUploadCompletionCallback = { _, _ in }
    ) -> StorageUploadTask {
        let storageRef = storage.reference().child(path)

        // Put the data
        return storageRef.putData(data, metadata: metadata) { _, error in
            if let error {
                onCompletionCallback(nil, GPWCKStorageError(from: error))
                return
            }

            // Get the image URL
            storageRef.downloadURL { url, error in
                if let error {
                    onCompletionCallback(nil, GPWCKStorageError(from: error))
                    return
                }

                onCompletionCallback(url, nil)
            }
        }
    }

    // MARK: - Delete

    func delete(atPath path: String) async throws {
        let storageRef = storage.reference().child(path)
        try await storageRef.delete()
    }
}
#endif
