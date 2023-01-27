import Foundation

func runtimeWarning(_ message: String) {
    // Load the dynamic library.
    guard let handle = dlopen(nil, RTLD_NOW) else {
        fatalError("Couldn't find dynamic library for runtime warning.")
    }

    // Get the "__main_thread_checker_on_report" symbol from the handle.
    guard let sym = dlsym(handle, "__main_thread_checker_on_report") else {
        fatalError("Couldn't find function for runtime warning reporting.")
    }

    // Cast the symbol to a callable Swift function type.
    typealias ReporterFunction = @convention(c) (UnsafePointer<Int8>) -> Void
    let reporter = unsafeBitCast(sym, to: ReporterFunction.self)

    // Convert the message to a pointer
    message.withCString { messagePointer in
        // Call the reporter with the acquired messagePointer
        reporter(messagePointer)
    }
}
