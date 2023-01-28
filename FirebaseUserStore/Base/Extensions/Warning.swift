import Foundation

var runtimeReporter: @convention(c) (UnsafePointer<Int8>) -> Void {
    guard let handle = dlopen(nil, RTLD_NOW) else {
        fatalError("Couldn't find dynamic library for runtime warning.")
    }

    guard let sym = dlsym(handle, "__main_thread_checker_on_report") else {
        fatalError("Couldn't find function for runtime warning reporting.")
    }

    typealias ReporterFunction = @convention(c) (UnsafePointer<Int8>) -> Void
    return unsafeBitCast(sym, to: ReporterFunction.self)
}
