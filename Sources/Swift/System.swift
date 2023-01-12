//
//  System.swift
//  Test
//
//  Created by Сергей Ваничкин on 07.01.2023.
//

import Foundation
import UIKit

/// Main class interface
public class System {
    // Set this key in true, if you need that the name of the simulated device
    // was displayed simulated device. For example "iPhone14,5" (iPhone 13).
    // By default this key is false. Will show "x86_64" (64-bit the simulator).
    public static var maskSimulatorWithRealDevice = false
    
    public static let application:Application = A()
    public static let device     :Device      = D()
    public static let os         :Os          = O()
    
    public static func device(_ index:String) -> Device {D(index)}
    
    // Sample intSysctl("hw.activecpu") -> 8
    public static func strSysctl(_ variable:String ) -> String? {gss(variable)}
    public static func intSysctl(_ variable:String ) -> Int?    {gis(variable)}
}

/// Main protocols
public protocol Application {
    var language   : String   {get}
    var name       : Name     {get}
    var version    : Version  {get}
    var args       : [String] {get}
    var macCatalyst: Bool     {get}
    var iosOnMac   : Bool     {get}
    var processId  : Int32    {get}
}
public protocol Device {
    var index       : String  {get}     // iPad10,1
    var info        : String? {get}     // With trackpad
    var name        : String? {get}     // iPad 6th
    var year        : String? {get}     // 2001-2002
    var cpu         : String? {set get} // Apple @ 1.10GHz
    var manufacturer: String? {get}     // Apple always
    var ram         : UInt64? {get}     // 16
    var worksCPU    : Int?    {get}     // 6
    var coresCPU    : Int?    {get}     // 8
    var lowPower    : Bool?   {get}     // is low power mod enbled (true/false)
    var type        : System.DeviceType  {get}
    var model       : System.DeviceModel {get}
    var thermal     : ProcessInfo.ThermalState? {get} // nominal...critical
}
public protocol Os {
    var name       : String          {get} // macOS
    var version    : Version         {get}
    var platform   : String          {get} // arm64
    var kernel     : String          {get} // Darwin v.21.6.0
    var node       : String          {get} // Mac.local
    var host       : String          {get} // mac.local
    var sign       : String          {get} // Darwin Kernel Version 21.6.0:
    var user       : String?         {get} // Root
    var globalId   : String          {get} // sdfsdf-sdfsdf-sdfsdf-sdfsdf
    var login      : String?         {get} // Root
    var environment: [String:String] {get}
    var uptime     : TimeInterval    {get}
}

/// Structures
public extension System {
    private struct A: Application {
        let language   : String   = NSLocale.preferredLanguages.first!
        let name       : Name     = N()
        let version    : Version  = V(info?["CFBundleShortVersionString"] as! String)
        let args       : [String] = ProcessInfo.processInfo.arguments
        let macCatalyst: Bool     = ProcessInfo.processInfo.isMacCatalystApp
        let iosOnMac   : Bool     = {
            if #available(iOS 14.0, *) {
                return ProcessInfo.processInfo.isiOSAppOnMac
            }
            return false
        }()
        let processId  : Int32    = ProcessInfo.processInfo.processIdentifier
    }
    private struct O: Os {
        let name       : String  = UIDevice.current.systemName
        let version    : Version = V(UIDevice.current.systemVersion)
        let platform   : String  = currentPlatform()
        let kernel     : String  = currentKernel()
        let node       : String  = currentNode()
        let host       : String  = ProcessInfo.processInfo.hostName
        let sign       : String  = currentSign()
        let user       : String? = ProcessInfo.processInfo.environment["USER"]
        let globalId   : String  = ProcessInfo.processInfo.globallyUniqueString
        let login      : String? = ProcessInfo.processInfo.environment["LOGNAME"]
        let environment: [String:String] = ProcessInfo.processInfo.environment
        let uptime     : TimeInterval = ProcessInfo.processInfo.systemUptime
    }
    private struct D: Device {
        let index       : String
        let info        : String?
        let year        : String?
        var cpu         : String? {
            willSet {
                if newValue != nil &&
                    isHackintoshWithDeviceIndex(index, newValue) {
                    model = System.DeviceModel.Hackintosh
                    manufacturer = "Unknown"
                }
            }
        }
        let name        : String?
        let type        : System.DeviceType
        var model       : System.DeviceModel
        var manufacturer: String?
        let ram         : UInt64?
        let worksCPU    : Int?
        let coresCPU    : Int?
        let thermal     : ProcessInfo.ThermalState?
        let lowPower    : Bool?
        init(_ ind: String) {
            index        = ind
            if let dbDevice = db[ind] {
                info         = dbDevice.info
                name         = dbDevice.name
                year         = dbDevice.year
                type         = dbDevice.type ?? System.DeviceType.Unknown
                model        = dbDevice.model ?? System.DeviceModel.Unknown
                manufacturer = "Apple inc."
                cpu          = dbDevice.cpu
            } else {
                info         = nil
                name         = ind
                year         = nil
                cpu          = nil
                type         = System.DeviceType.Unknown
                model        = System.DeviceModel.Unknown
                manufacturer = nil
            }
            ram      = nil
            worksCPU = nil
            coresCPU = nil
            thermal  = nil
            lowPower = nil
        }
        init() {
            if let ind = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
                if maskSimulatorWithRealDevice { index = ind }
                else if let arch = ProcessInfo().environment["SIMULATOR_ARCHS"],
                        arch.contains("x86_64") { index = "x86_64" }
                else { index = "i386" }
            } else { index = gss("hw.model")! }
            
            let currentCPULegal = gss("machdep.cpu.brand_string")
            
            let d = D(index)
            
            info         = d.info
            year         = d.year
            cpu          = (d.cpu != nil) ? d.cpu : currentCPULegal
            name         = d.name
            type         = d.type
            manufacturer = d.manufacturer
            model        = isHackintoshWithDeviceIndex(index, currentCPULegal) ?
            System.DeviceModel.Hackintosh : d.model
            ram          = (ProcessInfo.processInfo.physicalMemory/1024/1024/1024)
            worksCPU     = ProcessInfo.processInfo.activeProcessorCount
            coresCPU     = ProcessInfo.processInfo.processorCount
            thermal      = ProcessInfo.processInfo.thermalState
            lowPower     = ProcessInfo.processInfo.isLowPowerModeEnabled
        }
    }
    private struct V: Version, CustomStringConvertible {
        let major      : String
        let minor      : String
        let path       : String
        let full       : String
        var description: String
        init(_ version: String) {
            full        = version
            description = version
            let array = full.split(separator: ".")
            major = String(array.count > 0 ? array[0] : "0" )
            minor = String(array.count > 1 ? array[1] : "0" )
            path  = String(array.count > 2 ? array[2] : "0" )
        }
    }
    private struct N: Name, CustomStringConvertible {
        let bundle          : Localized
        let display         : Localized?
        var description     : String {
            if let d = display?.localized   {return d}
            if let d = display?.description {return d}
            if let b = bundle.localized     {return b}
            return bundle.description
        }
        init() {
            bundle  = L(ProcessInfo.processInfo.processName, infoLocalized?["CFBundleName"] as? String)
            if info?["CFBundleDisplayName"] != nil || infoLocalized?["CFBundleDisplayName"] != nil {
                display = L(info?["CFBundleDisplayName"] as? String, infoLocalized?["CFBundleDisplayName"] as? String)
            } else {
                display = nil
            }
        }
    }
    private struct L: Localized, CustomStringConvertible {
        let localized  : String?
        var description: String
        init(_ name: String?, _ locName: String?) {
            if let l = locName {description = l}
            if let l = name    {description = l}
            else               {description = ""}
            localized = locName
        }
    }
    private struct DBDevice: Decodable {
        var name : String
        var info : String?
        var year : String?
        var legal: String?
        var cpu  : String?
        var type : System.DeviceType?
        var model: System.DeviceModel?
    }
}

/// Second protocols
public protocol Version {
    var major: String {get} // 11
    var minor: String {get} // 5
    var path : String {get} // 70
    var full : String {get} // 11.5.70
}
public protocol Name  {
    var bundle     : Localized  {get} // ProjectName
    var display    : Localized? {get} // DisplayName
    var description: String     {get}
}
public protocol Localized  {
    var localized  : String? {get}
    var description: String  {get}
}

/// Database working
public extension System {
    private static let instance = System()
    private static let info = Bundle.main.infoDictionary
    private static let infoLocalized = Bundle.main.localizedInfoDictionary
    private static let SYSTEM_CONFIG = "SystemConfig"
    private static let SYSTEM_UPDATE = "SystemUpdate"
    private static let SYSTEM_URL = "https://raw.githubusercontent.com/svanichkin/System/master/Sources/Swift/System.json"
    private static var db:[String:DBDevice] = {
        System.instance.addListeners()
        if let db = dbFromDictionary() { return db }
        return dbFromFile()
    }()
    private static var listenersAdded:Bool = false
    private func addListeners() {
        if System.listenersAdded { return }
        System.listenersAdded = true
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.willEnterForegroundNotification),
            name: UIApplication.willEnterForegroundNotification,
            object: nil)
        
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.willEnterForegroundNotification),
                name: UIScene.willEnterForegroundNotification,
                object: nil)
        }
    }
    
    private static var isProgress: Bool = false
    
    @objc private func willEnterForegroundNotification () {
        if System.isProgress { return }
        defer { System.isProgress = false }
        System.isProgress = true
        let dispatchGroup = DispatchGroup()
        let globalQueue = DispatchQueue.global()
        dispatchGroup.enter()
        globalQueue.async {
            if let url = URL(string: System.SYSTEM_URL),
               let newContentLength = System.contentLengthWithURL(url) {
                let oldContentLength = UserDefaults.standard.object(forKey: System.SYSTEM_UPDATE) as? String
                if newContentLength != oldContentLength {
                   if let data = try? Data(contentsOf: url),
                      let dict = try? JSONDecoder().decode([String:DBDevice].self, from: data) {
                       UserDefaults.standard.set(newContentLength, forKey: System.SYSTEM_UPDATE)
                       UserDefaults.standard.set(data, forKey: System.SYSTEM_CONFIG)
                       DispatchQueue.main.async { System.db = dict }
                   }
                }
            }
            dispatchGroup.leave()
        }
        dispatchGroup.wait()
    }
    
    static private func dbFromDictionary() -> [String:DBDevice]? {
        if let data = UserDefaults.standard.object(forKey: System.SYSTEM_CONFIG),
           let dict = try? JSONDecoder().decode([String:DBDevice].self, from: data as! Data) {
            UserDefaults.standard.set(data, forKey: System.SYSTEM_CONFIG)
            return dict
        }
        return nil
    }
    static private func dbFromFile() -> [String:DBDevice] {
        if let url = Bundle.main.url(forResource: "System", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let dict = try? JSONDecoder().decode([String:DBDevice].self, from: data) {
            return dict
        }
        return [String:DBDevice]()
    }
    
    static private func contentLengthWithURL(_ url: URL) -> String? {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        var error: Error? = nil
        var response: URLResponse? = nil
        let semaphore = DispatchSemaphore(value: 0)
        URLSession.shared.dataTask(with: request) { (data, resp, err) in
            if let err = err { error = err }
            else { response = resp }
            semaphore.signal()
        }.resume()
        semaphore.wait()
        if error != nil { return nil }
        if let response = response as? HTTPURLResponse {
            let headerFields = response.allHeaderFields
            if let contentLength = headerFields["Content-Length"] as? String {
                return contentLength
            }
        }
        return nil
    }
}

/// Enums
public extension System {
    enum DeviceType: String, Decodable {
        case Unknown = "DeviceType_Unknown"
        case iPod    = "DeviceType_iPod"
        case iPhone  = "DeviceType_iPhone"
        case iPad    = "DeviceType_iPad"
        case Mac     = "DeviceType_Mac"
        case TV      = "DeviceType_TV"
        case Watch   = "DeviceType_Watch"
        case HomePod = "DeviceType_HomePod"
    }

    enum DeviceModel: String, Decodable {
        case Unknown = "DeviceModel_Unknown"

        case Compact = "DeviceModel_Compact" // 5, 5s, 5C, SE
        case Classic = "DeviceModel_Classic" // 6, 6s, 7, 8, SE 2
        case Plus    = "DeviceModel_Plus"    // 7 Plus, 8 Plus
        case Simple  = "DeviceModel_Simple"  // XR, 11
        case X       = "DeviceModel_X"       // X, Xs, 11 Pro
        case Max     = "DeviceModel_Max"     // Xs Max, 11 Pro Max

        case iPadClassic = "DeviceModel_iPadClassic" // iPad
        case iPadPro     = "DeviceModel_iPadPro"     // iPad Pro
        case iPadMini    = "DeviceModel_iPadMini"    // iPad Mini
        case iPadAir     = "DeviceModel_iPadAir"     // iPad Air

        case MacPro     = "DeviceModel_MacPro"
        case Hackintosh = "DeviceModel_Hackintosh"
        case iMac       = "DeviceModel_iMac"
        case iMacPro    = "DeviceModel_iMacPro"
        case MacMini    = "DeviceModel_MacMini"
        case MacBook    = "DeviceModel_MacBook"
        case MacBookPro = "DeviceModel_MacBookPro"
        case MacBookAir = "DeviceModel_MacBookAir"
        case Xserve     = "DeviceModel_Xserve"

        case TVHD = "DeviceModel_TVHD"
        case TV4K = "DeviceModel_TV4K"

        case WatchSS = "DeviceModel_WatchSS" // Small eSim 38-40mm
        case WatchS  = "DeviceModel_WatchS"  // Small no eSim 38-40mm
        case WatchBS = "DeviceModel_WatchBS" // Big eSim 42-44mm
        case WatchB  = "DeviceModel_WatchB"  // Big no eSim 42-44mm
    }
}

/// Helpers
public extension System {
    private static func isHackintoshWithDeviceIndex(_ index:String, _ cpuString:String?) -> Bool {
        guard let cpuString = cpuString,
              let item = db[index],
              let modelDetector = item.legal else { return false }
        // "["Intel&Xeon", "W-2140B|W-2150B", "3.20"]
        let detectorLines = modelDetector.components(separatedBy: ",")
        for detectorLine in detectorLines {
            // @"Intel&Xeon"
            if detectorLine.contains("&") {
                let detectorStrings = detectorLine.components(separatedBy: "&")
                var contains = 0
                for detectorString in detectorStrings {
                    if cpuString.contains(detectorString) { contains += 1 }
                }
                if contains < detectorStrings.count { return true }
                // @"W-2140B|W-2150B"
            } else if detectorLine.contains("|") {
                let detectorStrings = detectorLine.components(separatedBy: "|")
                var contains = 0
                for detectorString in detectorStrings {
                    if cpuString.contains(detectorString) { contains += 1 }
                }
                if (contains == 0) { return true }
                // @"3.20"
            } else if cpuString.contains(detectorLine) == false { return true }
        }
        return false
    }
    
    private static func currentPlatform () -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        // "arm64"
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    private static func currentKernel () -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        // "Darwin"
        let machineMirror = Mirror(reflecting: systemInfo.sysname)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        let machineMirror2 = Mirror(reflecting: systemInfo.release)
        let identifier2 = machineMirror2.children.reduce("") { identifier2, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier2 }
            return identifier2 + String(UnicodeScalar(UInt8(value)))
        }
        return identifier + " v." + identifier2
    }
    private static func currentNode () -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        // "arm64"
        let machineMirror = Mirror(reflecting: systemInfo.nodename)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    private static func currentSign () -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        // "Darwin Kernel Version 21.6.0: Mon Aug 22 20:20:05 PDT 2022; root:xnu-8020.140.49~2/RELEASE_ARM64_T8101"
        let machineMirror = Mirror(reflecting: systemInfo.version)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    private static func gss(_ typeSpecifier: String ) -> String? {
        var size:Int = 0
        sysctlbyname(typeSpecifier, nil, &size, nil, 0);
        var answer = [CChar](repeating: 0,  count: size)
        sysctlbyname(typeSpecifier, &answer, &size, nil, 0)
        if answer.count > 0 { return String(cString: answer, encoding: .utf8) }
        return nil
    }
    private static func gis(_ typeSpecifier: String ) -> Int? {
        var size:Int = 0
        sysctlbyname(typeSpecifier, nil, &size, nil, 0);
        var answer = [CChar](repeating: 0,  count: size)
        sysctlbyname(typeSpecifier, &answer, &size, nil, 0)
        if answer.count > 0 { return UnsafeRawPointer(answer).assumingMemoryBound(to: Int.self).pointee.littleEndian }
        return nil
    }
}
