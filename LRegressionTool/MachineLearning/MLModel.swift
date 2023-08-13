//
//  MLModel.swift
//  Linear Regression
//
//  Created by Егор Колобаев on 12.08.2023.
//

import Foundation
import Accelerate

enum RunErrors: Error {
    case IDValueMustExistAsAnInteger, TargetValueMustExistAsAnInteger
}

class MLModel {
    static func mult(_ A: [Double], _ B:[Double], firstD M: Int, secondD K: Int, thirdD N: Int) -> [Double] {
        var C = Array<Double>(repeating: 0, count: M * N)
        vDSP_mmulD(A, vDSP_Stride(1), B, vDSP_Stride(1), &C, vDSP_Stride(1), vDSP_Length(M), vDSP_Length(N), vDSP_Length(K))
        return C
    }
    static func T(_ A: [Double], firstD N: Int, secondD M: Int) -> [Double] {
        var C = Array<Double>(repeating: 0, count: M * N)
        vDSP_mtransD(A, vDSP_Stride(1), &C, vDSP_Stride(1), vDSP_Length(M), vDSP_Length(N))
        return C
    }
    private func getError(from err: [Double]) -> Double {
        var sum: Double = 0
        for i in err {
            sum += i * i
        }
        return sum / Double(err.count)
    }
    var w: [Double]
    var alpha: Double
    var s: Int
    var m: Int
    var tit: Double?
    func fit(trainData x: [Double], countData N: Int, countArray y: [Double]) {
        for _ in 1...s {
            let f = MLModel.mult(x, w, firstD: N, secondD: m + 1, thirdD: 1)
            let err = vDSP.subtract(f, y)
            if (tit != nil && getError(from: err) < tit!) {
                break
            }
            let xT = MLModel.T(x, firstD: N, secondD: m + 1)
            let xTerr = MLModel.mult(xT, err, firstD: m + 1, secondD: N, thirdD: 1)
            let grad = vDSP.multiply(2 / Double(N), xTerr)
            w = vDSP.subtract(w, vDSP.multiply(alpha, grad))
        }
    }
    func predict(testData x: [Double], countData N: Int) -> [Double] {
        return MLModel.mult(x, w, firstD: N, secondD: m + 1, thirdD: 1)
    }
    init(alpha: Double, s: Int, m: Int, tit: Double?) {
        self.alpha = alpha
        self.s = s
        self.m = m
        self.w = [1]
        self.tit = tit
        for _ in 0..<m {
            self.w.append(Double.random(in: -20...20))
        }
    }
}
