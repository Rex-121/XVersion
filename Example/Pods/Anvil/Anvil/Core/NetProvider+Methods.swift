//
//  NetProvider+Methods.swift
//  GINetworking
//
//  Created by Tyrant on 2019/9/10.
//


import ReactiveSwift

import Moya

// MARK: - Launch - 返回方式为 `<GIResult<解析>, GINetError>`
extension NetProvider {
    
    
    public func transform<Engine>(_ decodable: Engine.Type, _ decoder: JSONDecoder/* = JSONDecoder()*/) -> (Response) -> GIResult<Engine> {
        return { (response) -> GIResult<Engine> in
            do {
                var result = try decoder.decode(GIResult<Engine>.self, from: response.data)
                if decodable == DontCare.self { result.result = (DontCare() as! Engine) }
                return result
            }
            catch {
                //FIXME: 临时
                if response.statusCode != 200 {
                    return GIResult(result: nil, message: "网络错误 \(response.statusCode)", code: response.statusCode, good: false)
                }
                return GIResult.ParseWrong
            }
        }
    }
    
    /// 网络请求 <GIResult<解析>, GINetError>
    ///
    ///   - (1) 将未成功的网络请求(`MoyaError`)转译为`GINetError`
    ///   - (2) 分析网络是否响应成功(200)
    ///   - (3) 解析数据
    /// - Parameters:
    ///   - target: 网络目标
    ///   - codable: 解析方式
    /// - Returns: GIResult<解析>, GINetError
    open func launch<Engine>(_ target: T, _ decodable: Engine.Type, _ decoder: JSONDecoder/* = JSONDecoder()*/) -> SignalProducer<GIResult<Engine>, GINetError> where Engine: Decodable {
        return super.reactive.request(target)
            .parachute()
            .attempt({ (response) -> Swift.Result<(), GINetError> in
                switch response.statusCode {
                case 200: return .success(())
                default: return .failure(GINetError.network("网络错误 \(response.statusCode)", response))
                }
            })
            .attemptMap({ (response) -> Result<GIResult<Engine>, GINetError> in
                do {
                    let result = try decoder.decode(GIResult<Engine>.self, from: response.data)
                    if result.good {
                        return .success(result)
                    }
                    return .failure(result.errorInfo)
                } catch {
                    print(error)
                    return .failure(.ParseWrong)
                }
            })
    }
    
    /// 网络请求 <GIResult<DontCare>, GINetError>
    ///
    /// - Parameters:
    ///   - target: 网络目标
    /// - Returns: GIResult<DontCare>, GINetError
    open func launch(_ target: T,  _ decoder: JSONDecoder = JSONDecoder()) -> SignalProducer<GIResult<DontCare>, GINetError> {
        return self.launch(target, DontCare.self, decoder)
    }
    
}

// MARK: - Detach - 返回方式为 `<解析, GINetError>`
extension NetProvider {
    /// 网络请求 <解析, GINetError>
    ///
    /// - Parameters:
    ///   - target: 网络目标
    ///   - codable: 解析方式
    /// - Returns: 解析, GINetError
    public func detach<Engine: Decodable>(_ target: T, _ codable: Engine.Type, _ decoder: JSONDecoder = JSONDecoder()) -> SignalProducer<Engine, GINetError> {
        return self.launch(target, codable, decoder).attemptMap({ (result) -> Result<Engine, GINetError> in
            guard let result = result.result else { return .failure(.ParseWrong) }
            return .success(result)
        })
    }
    
    /// 网络请求 <(), GINetError>
    ///
    /// - Parameters:
    ///   - target: 网络目标
    /// - Returns: (), GINetError
    public func detach(_ target: T) -> SignalProducer<(), GINetError> {
        return self.detach(target, DontCare.self).map { _ in () }
    }
    
}

// MARK: - Docking - 返回方式为 `<(解析, BasicInfo), GINetError>`  or  `<BasicInfo, GINetError>`
//extension NetProvider {
//
//    /// 网络请求 <(解析, BasicInfo), GINetError>
//    ///
//    /// - Parameters:
//    ///   - target: 网络目标
//    ///   - codable: 解析方式
//    /// - Returns: <(解析, BasicInfo), GINetError>
//    @available(*, deprecated, message: "`dock` 关键词让行，请使用 `brief` 相应方法")
//    public func docking<Engine: Decodable>(_ target: T, _ codable: Engine.Type, _ decoder: JSONDecoder = JSONDecoder()) -> SignalProducer<(Engine, BasicInfo), GINetError> {
//        return self.launch(target, codable, decoder).attemptMap({ (result) -> Result<(Engine, BasicInfo), GINetError> in
//            guard let value = result.result else { return .failure(.ParseWrong) }
//            return .success((value, result.info))
//        })
//    }
//
//    /// 网络请求 <BasicInfo, GINetError>
//    ///
//    /// - Parameters:
//    ///   - target: 网络目标
//    ///   - codable: 解析方式
//    /// - Returns: <BasicInfo, GINetError>
//    @available(*, deprecated, message: "`dock` 关键词让行，请使用 `brief` 相应方法")
//    public func docked<Engine: Decodable>(_ target: T, _ codable: Engine.Type) -> SignalProducer<BasicInfo, GINetError> {
//        return self.docking(target, codable).map { $1 }
//    }
//
//    /// 网络请求 <BasicInfo, GINetError>
//    ///
//    /// - Parameters:
//    ///   - target: 网络目标
//    /// - Returns: <BasicInfo, GINetError>
//    @available(*, deprecated, message: "`dock` 关键词让行，请使用 `brief` 相应方法")
//    public func docked(_ target: T) -> SignalProducer<BasicInfo, GINetError> {
//        return self.docking(target, DontCare.self).map { $1 }
//    }
//
//}

// MARK: - Brief - 返回方式为 `<(解析, BasicInfo), GINetError>`  or  `<BasicInfo, GINetError>`
extension NetProvider {
    
    /// 网络请求 <(解析, BasicInfo), GINetError>
    ///
    /// - Parameters:
    ///   - target: 网络目标
    ///   - codable: 解析方式
    /// - Returns: <(解析, BasicInfo), GINetError>
    public func briefing<Engine: Decodable>(_ target: T, _ codable: Engine.Type, _ decoder: JSONDecoder = JSONDecoder()) -> SignalProducer<(Engine, BasicInfo), GINetError> {
        return self.launch(target, codable, decoder).attemptMap({ (result) -> Result<(Engine, BasicInfo), GINetError> in
            guard let value = result.result else { return .failure(.ParseWrong) }
            return .success((value, result.info))
        })
    }
    
    /// 网络请求 <BasicInfo, GINetError>
    ///
    /// - Parameters:
    ///   - target: 网络目标
    ///   - codable: 解析方式
    /// - Returns: <BasicInfo, GINetError>
    public func brief<Engine: Decodable>(_ target: T, _ codable: Engine.Type) -> SignalProducer<BasicInfo, GINetError> {
        return self.briefing(target, codable).map { $1 }
    }
    
    /// 网络请求 <BasicInfo, GINetError>
    ///
    /// - Parameters:
    ///   - target: 网络目标
    /// - Returns: <BasicInfo, GINetError>
    public func brief(_ target: T) -> SignalProducer<BasicInfo, GINetError> {
        return self.briefing(target, DontCare.self).map { $1 }
    }
    
}


// MARK: - 主/次解析方式
extension NetProvider {
    
    /// 用于解析的结果
    ///
    /// - main: 首要解析方式
    /// - second: 次要解析方式
    public enum Engine<Main: Decodable, Second: Decodable>: Decodable {
        case main(Main), second(Second)
        
        public init(from decoder: Decoder) throws {
            self = Engine<DontCare, DontCare>.main(DontCare()) as! NetProvider<T>.Engine<Main, Second>
        }
    }
    
    
    
    
    /// 尝试解码2次 <NetProvider.Engine<Engine, Second>, GINetError>
    ///
    /// - Parameters:
    ///   - target: 网络目标
    ///   - engine: 主解析，失败后采用副解析
    ///   - second: 副解析
    /// - Returns: <NetProvider.Engine<Engine, Second>, GINetError>
    open func launch<Engine: Decodable, Second: Decodable>(_ target: Target, main engine: Engine.Type, second: Second.Type) -> SignalProducer<NetProvider.Engine<Engine, Second>, GINetError> {
        
        return super.reactive.request(target)
            .parachute()
            .attemptMap { (response) -> Result<NetProvider.Engine<Engine, Second>, GINetError> in
                
                do {
                    let mainEngine = try JSONDecoder().decode(GIResult<Engine>.self, from: response.data)
                    if mainEngine.good == false { return .failure(mainEngine.errorInfo) }
                    if let res = mainEngine.result { return .success(.main(res)) }
                    throw GINetError.ParseWrong
                }
                catch {
                    do {
                        let secondEngine = try JSONDecoder().decode(GIResult<Second>.self, from: response.data)
                        guard let res = secondEngine.result else { throw GINetError.ParseWrong }
                        return .success(.second(res))
                    } catch {
                        return .failure(GINetError.ParseWrong)
                    }
                }
                
        }
    }
    
}

extension NetProvider {
    
    public func progressed(_ target: Target) -> SignalProducer<ProgressResponse, GINetError> {
        return reactive.requestWithProgress(target).parachute()
    }
    
}


extension NetProvider {
    
    
    /// 网络请求 <(target, BasicInfo), GINetError>
    ///
    /// - Parameters:
    ///   - target: 网络目标
    /// - Returns: (网络目标, BasicInfo)
    /// 暂时不建议使用
    public func echo(_ target: T) -> SignalProducer<(T, BasicInfo), GINetError> {
        return self.briefing(target, DontCare.self).map { (target, $1) }
    }
    
    
    public struct EchoSidesError<T>: Error {
        let target: T
        let error: GINetError
    }
    
}


extension SignalProducer where Error == MoyaError {
    
    
    /// 将 `MoyaError` 转换为 `GINetError`
    ///
    /// - Returns: SignalProducer<Value, GINetError>
    func parachute() -> SignalProducer<Value, GINetError> {
        
        return mapError { (my) -> GINetError in
            
            print(my)
            
            var msg = "您的网络不稳定，请更换网络环境并尝试"
            
            if let res = my.response {
                return .network("\(msg) '\(res.statusCode)'", res)
            }
            
            switch my {
            case .imageMapping, .jsonMapping, .stringMapping(_), .objectMapping(_, _), .encodableMapping(_),
                 .parameterEncoding, .requestMapping:
                break
            case .statusCode(let a):
                msg = "\(msg) '\(a.statusCode)'"
            case .underlying(_, _):
                msg = "无法连接到服务器"
            }
            return .network(msg, my.response)
        }
    }
    
}
