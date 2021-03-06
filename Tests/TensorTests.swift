// Copyright © 2015 Venture Media Labs.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import XCTest
@testable import Upsurge

class TensorTests: XCTestCase {
    var diagonalTensor3D: Tensor<Double>!
    var diagonalTensor4D: Tensor<Double>!

    override func setUp() {
        super.setUp()
        diagonalTensor3D = Tensor(dimensions: [5, 5, 5], repeatedValue: 0)
        diagonalTensor3D[0, 0, 0] = 1
        diagonalTensor3D[1, 1, 1] = 1
        diagonalTensor3D[2, 2, 2] = 1
        diagonalTensor3D[3, 3, 3] = 1
        diagonalTensor3D[4, 4, 4] = 1

        diagonalTensor4D = Tensor(dimensions: [2, 2, 2, 2], repeatedValue: 0)
        diagonalTensor4D[0, 0, 0, 0] = 1
        diagonalTensor4D[1, 1, 1, 1] = 1
    }

    func testSliceAndSubscript() {
        let slice1 = diagonalTensor3D[3...3, 2...3, 2...3]
        let slice2 = diagonalTensor4D[1...1, 1...1, Interval.all, Interval.all]
        let slice3 = diagonalTensor4D.asMatrix(1...1, 1...1, 0...1, 0...1)

        XCTAssertEqual(slice1, slice2)
        XCTAssert(slice1 == slice3)
        XCTAssert(slice3 == slice2)
        XCTAssertEqual(slice1[3, 3, 3], 1)
    }

    func testSliceAndValueAssignment() {
        XCTAssertEqual(diagonalTensor3D[0, 1, 1], 0)

        diagonalTensor3D[0, 1, 1] = 16
        XCTAssertEqual(diagonalTensor3D[0, 1, 1], 16)
    }

    func testSliceValueAssignment() {
        let tensor = Tensor(dimensions: [2, 2, 2, 2], elements: [6.4, 2.4, 8.6, 0.2, 6.4, 1.5, 7.3, 1.1, 6.0, 1.4, 7.8, 9.2, 4.2, 6.1, 8.7, 3.6] as ValueArray<Double>)
        diagonalTensor4D[Interval(integerLiteral: 1), Interval.all, Interval(range: 0...1), Interval(range: 0...1)] = tensor[Interval(integerLiteral: 0), Interval(range: 0...1), Interval.all, Interval(range: 0...1)]

        let expected = Tensor(dimensions: [2, 2, 2, 2], elements: [1, 0, 0, 0, 0, 0, 0, 0, 6.4, 2.4, 8.6, 0.2, 6.4, 1.5, 7.3, 1.1] as ValueArray<Double>)
        XCTAssertEqual(diagonalTensor4D, expected)
    }

    func testMatrixExtraction() {
        var matrix = diagonalTensor4D.asMatrix(1...1, 1...1, 0...1, 0...1)
        var expected = Matrix<Double>([[0, 0], [0, 1]])
        XCTAssert(matrix == expected)

        matrix = diagonalTensor4D.asMatrix(Interval(integerLiteral: 0), Interval(integerLiteral: 0), Interval(integerLiteral: 0), Interval(integerLiteral: 0))
        expected = Matrix<Double>([[1]])
        XCTAssert(matrix == expected)
    }

    func testContinuity() {
        XCTAssert(diagonalTensor3D[1...4, Interval.all, Interval.all].isContiguous)
        XCTAssert(diagonalTensor3D[4...4, 2...2, 1...2].isContiguous)
        XCTAssert(diagonalTensor3D[1...1, 4...4, Interval.all].isContiguous)
        XCTAssert(diagonalTensor3D[1...1, Interval.all, Interval.all].isContiguous)
        XCTAssert(diagonalTensor3D[1...1, 2...3, Interval.all].isContiguous)
    }

    func testNoContinuity() {
        XCTAssertFalse(diagonalTensor3D[1...2, 3...4, 1...1].isContiguous)
        XCTAssertFalse(diagonalTensor3D[Interval.all, 3...4, Interval.all].isContiguous)
        XCTAssertFalse(diagonalTensor3D[1...1, Interval.all, 1...1].isContiguous)
        XCTAssertFalse(diagonalTensor3D[Interval.all, 1...1, 1...1].isContiguous)
    }
}
