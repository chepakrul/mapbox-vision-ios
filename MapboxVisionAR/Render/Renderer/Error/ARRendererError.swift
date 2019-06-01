/// The error that occurred during rendering process.
enum ARRendererError: LocalizedError {
    /// A queue that organizes command buffers to be executed by a GPU can't be created.
    case cantCreateCommandQueue
    /// Texture cache can't be created.
    case cantCreateTextureCache
    /// Buffer for Metal device can't be created.
    case cantCreateBuffer
    /// One of required shared function can't be found.
    case cantFindFunctions
}
