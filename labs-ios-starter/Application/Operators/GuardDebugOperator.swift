// Copyright © 2020 Lambda, Inc. All rights reserved.
// Created by Shawn James
// GuardDebugOperator.swift

// MARK: - Guard Statement Debugging Operator
/// GuardDebug operator
infix operator ><

/// Used in guard statements to print an error message before failing.
/// ```
/// guard
///     let middleName = middleName >< "Missing middle name"
/// else {
///     print("Exited early from functionName()")
/// }
/// ```
/// - Parameters:
///   - lhs: The optional that is being unwrapped in the guard statement
///   - rhs: The message that you would like to print if the guard statement fails
/// - Returns: The unwrapped object or nil
func >< <T>(lhs: T?, rhs: String) -> T? {
    if lhs == nil { print(rhs) }
    return lhs
}
