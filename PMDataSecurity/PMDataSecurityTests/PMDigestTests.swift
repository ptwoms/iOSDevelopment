//
//  PMDigestTests.swift
//  PMDataSecurity
//
//  Created by Pyae Phyo Myint Soe on 2/2/25.
//

import Testing
import XCTest
@testable import PMDataSecurity

struct PMDigestTests {
    @Test("Testing Hash functions by CryptoKit")
    func testBuiltInHashes() {
        #expect("Hello World".pm_digest(algorithm: .md5) == "b10a8db164e0754105b7a99be72e3fe5")
        #expect(
            "Hello World".pm_digest(algorithm: .sha1) == "0a4d55a8d778e5022fab701977c5d840bbc486d0"
        )
        #expect(
            "Hello World".pm_digest(algorithm: .sha2_256) == "a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e"
        )
        #expect(
            "Hello World".pm_digest(algorithm: .sha2_384) == "99514329186b2f6ae4a1329e7ee6c610a729636335174ac6b740f9028396fcc803d0e93863a7c3d90f86beee782f4f3f"
        )
        #expect(
            "Hello World".pm_digest(algorithm: .sha2_512) == "2c74fd17edafd80e8447b0d46741ee243b7eb74dd2149a0ab1b9246fb30382f27e853d8585719e0e67cbda0daa8f51671064615d645ae27acb15bfb1447f459b"
        )
    }

    @Test("Testing SHA3")
    func testSHA3General() {
        #expect(
            "Hello World".pm_digest(algorithm: .sha3_224) == "8e800079a0b311788bf29353f400eff969b650a3597c91efd9aa5b38"
        )
        #expect(
            "Hello World".pm_digest(algorithm: .sha3_256) == "e167f68d6563d75bb25f3aa49c29ef612d41352dc00606de7cbd630bb2665f51"
        )
        #expect(
            "Hello World".pm_digest(algorithm: .sha3_384) == "a78ec2851e991638ce505d4a44efa606dd4056d3ab274ec6fdbac00cde16478263ef7213bad5a7db7044f58d637afdeb"
        )
        #expect(
            "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.".pm_digest(algorithm: .sha3_512) == "0e861535e9a92bc92266bb94769ef034af43ec35ccdaf2b9e4ed57cdf92cf40f318b62a1df766106fec3263f1371484794793d1571fabad052df43ad2e4d72c3"
        )
    }

    @Test("Testing SHA3-256")
    func testSHA3_256() {
        let input1 = "Hello, Swift!"
        let expectedHash1 = "ab85db138771e36845750c0a69ffc019cf599ebfa059a33f59db5d3beaa690e8"
        #expect(input1.pm_digest(algorithm: .sha3_256) == expectedHash1)

        // Test Empty String
        let input2 = ""
        let expectedHash2 = "a7ffc6f8bf1ed76651c14756a061d662f580ff4de43b49fa82d80a4b80f8434a"
        #expect(input2.pm_digest(algorithm: .sha3_256) == expectedHash2)

        // Test Long Input
        let input3 = String(repeating: "A", count: 1000) // 1000 "A"s
        let expectedHash3 = "9a0ad8e2b4dd2bba189511f7759bcff54e3455046303d3cf86cb0c1747224936"
        #expect(input3.pm_digest(algorithm: .sha3_256) == expectedHash3)
    }

    @Test("Testing SHA3-512")
    func testSHA3_512() {
        let input1 = "Hello, Swift!"
        let expectedHash1 = "50ff7f335fd54f223b45f4f17dc4fdf603046b780af36e9f5182fae3c6b9ab7ec9ee7ed782aa888763e5a84c317c9c2d2cc3391890c14b8a54904ed52bb3c6a4"
        #expect(input1.pm_digest(algorithm: .sha3_512) == expectedHash1)

        // Test Empty String
        let input2 = ""
        let expectedHash2 = "a69f73cca23a9ac5c8b567dc185a756e97c982164fe25859e0d1dcc1475c80a615b2123af1f5f94c11e3e9402c3ac558f500199d95b6d3e301758586281dcd26"
        #expect(input2.pm_digest(algorithm: .sha3_512) == expectedHash2)

        // "Hello World" in Japanese
        let input3 = "こんにちは世界"
        let expectedHash3 = "45c6597839deb8e03bab0007a59d6881dbc9cadda1740c6a85f652b8300a85b9cc7d8ebfbfb32f2a6a22b461d8e3a4a193dddb79ce207287333a777d8c44d392"
        #expect(input3.pm_digest(algorithm: .sha3_512) == expectedHash3)

        // Special chars
        let input4 = "!@#$%^&*()_+-=[]{}|;:'\",.<>?/\\"
        let expectedHash4 = "0b54a20077464123a40f76c8e66006d87635283693a49fe513269a74300b1f48e261f99ae18196bc98fd18eab81606d52e971bf592865de928112c58e4c7e20b"
        #expect(input4.pm_digest(algorithm: .sha3_512) == expectedHash4)

        // Test Long Input
        let input5 = String(repeating: "A", count: 100_000) // 100,000 "A"s
        let expectedHash5 = "babf2fadc1567f2e2667ffaaf4741837b5ba0f8d7a7c739965790526e083f3033bd3a806a0a775f2baa9f7d7bcd33bd1bbf522a6acb57f18647dafd4e65ff787"
        #expect(input5.pm_digest(algorithm: .sha3_512) == expectedHash5)
    }

    @Test("Testing SHAKE-128")
    func testSHAKE_128() {
        let input1 = "Hello, Swift!"
        let expectedHash1 = "1128e2743406cc931a6373a35272e50a"
        #expect(
            input1.pm_digest(algorithm: .shake_128()) == expectedHash1
        )

        // Test Empty String
        let input2 = ""
        let expectedHash2 = "7f9c2ba4e88f827d616045507605853e"
        #expect(
            input2.pm_digest(algorithm: .shake_128()) == expectedHash2
        )

        // Test Long Input
        let input3 = String(repeating: "A", count: 1000) // 1000 "A"s
        let expectedHash3 = "e65350a10f64aa1ced45fc1664f102fb"
        #expect(input3.pm_digest(algorithm: .shake_128()) == expectedHash3)
    }

    @Test("Testing SHAKE-256")
    func testSHAKE_256() {
        let input1 = "Hello, Swift!"
        let expectedHash1 = "09ad7089ecfc2209f306b911444a22285aa63f69a529f2c69f85f68014f1a697"
        #expect(
            input1.pm_digest(algorithm: .shake_256()) == expectedHash1
        )

        // Test Empty String
        let input2 = ""
        let expectedHash2 = "46b9dd2b0ba88d13233b3feb743eeb243fcd52ea62b81b82b50c27646ed5762fd75dc4ddd8c0f200cb05019d67b592f6fc821c49479ab48640292eacb3b7c4be"
        #expect(
            input2.pm_digest(algorithm: .shake_256(length: 64)) == expectedHash2
        )

        // Test Long Input
        let input3 = String(repeating: "A", count: 1000) // 1000 "A"s
        let expectedHash3 = "9358881f7aed432af4f30ec54af33acee9d0dff7626324d3006fbb8c275872b1ae309e0a08b00d730806f848154746f94ea2feba8b8ba2d9e46e7eec01dfe8f9606837aca262fc1baff8c61a5148a69b6c3c6208a170c702c3a32cd2bc0cd4524a1597f5117903b8ab0545fad9fffcf91b22891cf8e49568c96720796d94cee549bf21104f089b9ca1df90d9411c05409cbf4cdf9790eff3a47a6a3fde337ffd33dcd47ed236a161ea625163959fdf39db146de46d08da63e71f3b23e4925b4d6f39aa7d61fc5c5fa01daa3d7ab9172e6eb86cf89590e9cbb2b4c2011f0ecbea83c322cae0ca72b1b030e6a1dfdd008c3ee94e72a9fbf9584dadbceedd4be2ce"
        #expect(
            input3.pm_digest(algorithm: .shake_256(length: 256)) == expectedHash3
        )

        let input4 = "Hello, Swift!"
        let expectedHash4 = "09ad7089ecfc2209f306b911444a22285aa63f69a529f2c69f85f68014f1a697250ff66e9bb3b93f5122f4368be0bf2439467e2bbd41393165bc2fb66c36be344b23b2ce37a2d2870eabdde692c1cb1a0b9c827a1069d9bb9d2b4561a922c3d73b34695d9e6e0e173e8f1df928b6be67f8b94240b69e3b638f838c74afd68c68645ac946feb5fd1f5b24db862d7efe92aa51c02e2bf73cc49344a28f54f701d1f52f9f1b220a9de161658d8e01e6d333599a6a71ef6297b9955ce1832be0d914bae210c25bc9f867e4a16aa4bafc40504eead6a4d78ac23507d75528ea1494fae2241b24480a7201a0d44cf01cf2d504b8558d459e8c179a0ca0be8cb09ca783cdd0dcfbe915fbaaa9ba390a4325dffa8f9e73599748ee44a8f3f4eae02a39c46385c70bb4a01b5d696adc8dea9dc10d1019f44be62492b4a37fe88d0c5c1531bf4fadfa19d46b920548460e190270ac2b65fb9e9112e00670b03f63a0d1ad981969736dd883fbbcada1d394c6f44ccfa509e87b6700dd8d7dba3c985a2fd2e1d429e0a50da10d58c85c9183f44f1afc0fd7d3e6a32a17381eab54f86827925adb5293d064dab39e79328d2a59a9113b1f054319d8249947642b8d7a2de1a1e7d1d2cf240b9ed7c91aef07c5188ecde86a394f09d678081eceabc5d0fe45361ee2502c53f2a21947024dfaca41430cd9ab4f92effa7043d9bf20faff7da524ea"
        #expect(
            input4.pm_digest(algorithm: .shake_256(length: 512)) == expectedHash4
        )
    }
}

class PMDigestTestsPerformanceTests: XCTestCase {
    func testSHA2Peforemance() {
        measure {
            _ = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.".pm_digest(algorithm: .sha2_512)
        }
    }

    func testSHA3Performance() {
        measure {
            _ = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.".pm_digest(algorithm: .sha3_512)
        }
    }

    func testSHAKEPerformance() {
        measure {
            _ = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."
                .pm_digest(algorithm: .shake_256(length: 512))
        }
    }
}
