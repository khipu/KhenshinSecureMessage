import Foundation

public struct Constants {

    public struct Box {
        public static let publicKeyBytes = 32
        public static let secretKeyBytes = 32
        public static let beforeNMBytes = 32
        public static let nonceBytes = 24
        public static let zeroBytes = 32
        public static let boxZeroBytes = 16
    }

    public struct Secretbox {
        public static let keyBytes = 32
        public static let nonceBytes = 24
        public static let zeroBytes = 32
        public static let boxZeroBytes = 16
    }

    public struct Scalarmult {
        public static let bytes = 32
        public static let scalarBytes = 32
    }

    public struct Sign {
        public static let bytes = 64
        public static let publicKeyBytes = 32
        public static let secretKeyBytes = 64
        public static let seedBytes = 32
    }

    public struct Hash {
        public static let bytes = 64
    }
}