//
//  ViewController.swift
//  XVersion
//
//  Created by Tyrant on 12/17/2019.
//  Copyright (c) 2019 Tyrant. All rights reserved.
//

import UIKit

import Anvil
import Moya
import XVersion
import ReactiveSwift
import ReactiveCocoa

class VersionNet<T: TargetType>: NetProvider<T> {
    
    public override init(endpointClosure: @escaping MoyaProvider<T>.EndpointClosure = MoyaProvider<T>.defaultEndpointMapping,
                         requestClosure: @escaping MoyaProvider<T>.RequestClosure = MoyaProvider<T>.defaultRequestMapping,
                         stubClosure: @escaping MoyaProvider<T>.StubClosure = MoyaProvider<T>.neverStub,
                         callbackQueue: DispatchQueue? = nil,
                         session: Session = NetCer.defaultSession(),
                         plugins: [PluginType] = [NetLogg()],
                         trackInflights: Bool = false) {
        super.init(endpointClosure: endpointClosure, requestClosure: requestClosure, stubClosure: stubClosure, callbackQueue: callbackQueue, session: session, plugins: plugins, trackInflights: trackInflights)
        
    }
    
    
}

class NetCer: GI_NetworkingSession {
    
    static func defaultPolicy() -> ServerTrustPolice? {
        return nil
    }
    
    
    static func defaultSession() -> Session {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20
        configuration.timeoutIntervalForResource = 30
        configuration.httpAdditionalHeaders = defaultHTTPHeader.dictionary
        return Session(configuration: configuration, delegate: SessionDelegate(), serverTrustManager: defaultPolicy())
    }
    
    static var user_agent: String {
        return "DC"
    }
    
    
    static var defaultHTTPHeader: HTTPHeaders {
        // Accept-Encoding HTTP Header; see https://tools.ietf.org/html/rfc7230#section-4.2.3
        let acceptEncoding: String = "gzip;q=1.0, compress;q=0.5"
        
        // Accept-Language HTTP Header; see https://tools.ietf.org/html/rfc7231#section-5.3.5
        let acceptLanguage = Locale.preferredLanguages.prefix(6).enumerated().map { index, languageCode in
            let quality = 1.0 - (Double(index) * 0.1)
            return "\(languageCode);q=\(quality)"
            }.joined(separator: ", ")

        return [
            "Accept-Encoding": acceptEncoding,
            "Accept-Language": acceptLanguage,
            "User-Agent": user_agent
        ]
    }
}

struct NetLogg: Moya.PluginType {
    
    enum Logg {
        case parameters, all
    }
    
    let type: Logg
    let targets: [TargetType]
    
    init(_ type: Logg = .all, _ targets: [TargetType] = []) {
        self.type = type
        self.targets = targets
    }
    
    init(_ type: Logg) {
        self.init(type, [])
    }
    
    init(_ targets: [TargetType]) {
        self.init(.all, targets)
    }
    
    
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        
        
         let response = try! result.get()
            
            if !targets.isEmpty {
                let log = targets.map { $0.path }.contains(target.path)
                
                if !log { return }
            }
            
            print("----- ----- ----- path: \(target.path) ----- ----- -----")
            print("----- ----- ----- path: \(target.baseURL.absoluteString) ----- ----- -----")
            print(target.headers?.description ?? "noheader")
            
            do {
                switch type {
                case .all:
                    let data = try JSONSerialization.jsonObject(with: response.data, options: [])
                    print(data)
                case .parameters:
                    break
                }
                
            }
            catch { }
            
            
            switch target.task {
            case .requestPlain, .requestData(_), .requestCustomJSONEncodable(_, _), .requestCompositeData(_, _), .requestCompositeParameters(_, _, _), .uploadCompositeMultipart(_, _): break
            case .requestJSONEncodable(let encoder):
               print("--JSONEncodable: \(encoder)")
            case .requestParameters(let parameters, let encoding):
                print("--Parameters: \(parameters)")
                print("--Encoding: \(encoding)")
            case .uploadFile(_): break
            case .uploadMultipart(let mfdata):
                for fm in mfdata {
                    switch fm.provider {
                    case .data(let data):
                        let a = String(data: data, encoding: .utf8) ?? "~~nullllllll~~"
                        print("\(fm.name) : \(a)")
                    default: print("--Data: \(mfdata.description)")
                    }
                }
            case .downloadDestination(_), .downloadParameters(_, _, _): break
            }

            print("--Method: \(target.method)")
            print("----- ----- ----- path: \(target.baseURL.absoluteString) ----- ----- -----")
            print("----- ----- ----- path: \(target.path) ----- ----- -----")
  
    }
    
}



enum VersionNeting: TargetType {
    
    var baseURL: URL { URL(string: "https://tcapplv.lvpay.vip/merchant_app")! }
    
    var path: String { "/app/version/list" }
    
    var method: Moya.Method { .post }
    
    var sampleData: Data { Data() }
    
    var task: Task { .requestParameters(parameters: ["type" : 4], encoding: Moya.URLEncoding.default)}
    
    var headers: [String : String]? { nil }
    
    case version
}

struct VersionX: TargetType {
    
    let baseURL: URL //{ URL(string: "https://tcapplv.lvpay.vip/merchant_app")! }
    
    let path = ""
    
    var method: Moya.Method = .post
    
    var sampleData: Data = Data()
    
    var task: Task = .requestParameters(parameters: ["type" : 4], encoding: Moya.URLEncoding.default)
    
    var headers: [String : String]? = nil
    
}



class ViewController: UIViewController {
    
    let net = VersionNet<VersionX>()
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var results: UILabel!
    
    @IBOutlet weak var searchBtn: UIButton!
    
    let url = MutableProperty<VersionX?>(nil)
    
    var action: Action<(), VersionControl, GINetError>!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        url <~ textView.reactive.signal(for: \UITextView.text).merge(with: textView.reactive.continuousTextValues.map { $0 as String? }).producer.map { (string) -> VersionX? in
            guard let s = string, let uri = URL(string: s) else { return nil }
            return VersionX(baseURL: uri)
        }
        
        action = Action(unwrapping: url) { [unowned net] (ver) -> SignalProducer<VersionControl, GINetError> in
            return net.detach(ver, VersionControl.self)
        }
        
        results.reactive.text <~ action.values.map({ (control) -> String in
            let up = control.needUpdate()
            
            
            return """
            最低版本号：\(control.minimum ?? "")
            现在版本号：\(control.current)
            线上版本号：\(control.latest)
            是否需要更新：\(up == nil ? false : true)
            是否强更:\(up?.byForce() ?? false)
            下载地址:\(up?.ipaUrl?.absoluteString ?? "")
            更新信息:\(up?.news() ?? "")
            """
            
        })
        
        results.reactive.text <~ action.errors.map { $0.description }
        
        searchBtn.reactive.pressed = CocoaAction(action)
        
        textView.text = "https://tcapplv.lvpay.vip/merchant_app/app/version/list"
        
//        net.detach(.version, VersionControl.self).startWithResult { (result) in
//            print(result)
//        }
//
//        net.detach(.version, VersionControl.self).startWithResult { (result) in
//            let value = try! result.get()
//
//            print(value.current)
//
//            print(value.latest)
//
//            print(value.needUpdate() ?? "")
//        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
