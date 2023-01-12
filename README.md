[![SPM supported](https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat)](https://swift.org/package-manager)
[![Platform](https://img.shields.io/cocoapods/p/KeychainAccess.svg)](http://cocoadocs.org/docsets/KeychainAccess)
# System
System is a class that allows you to work immediately with all systems, applications and os fields, in a simple and convenient wrapper. 
The library allows you to get information about devices, for example: Apple A14 Bionic CPU @ 3.00GHz or Wifi + Cellular (model A2324, A2072, A2325) or iPad Air 4th and date of manufactured 2020.

This library works on many projects such as Mubert, Morse, etc. Top of App Store.

## Sample 1

### Get all fields for current device:

```swift
print(System.application.name)
print(System.application.name.bundle)             // Bundle Name
print(System.application.name.bundle.localized)   // Localized Bundle Name
print(System.application.name.display)            // Displayed Name
print(System.application.name.display?.localized) // Localized Displayed Name
print(System.application.version)
print(System.application.version.major)
print(System.application.version.minor)
print(System.application.version.path)
print(System.application.args) // Array of arguments set withs start app
print(System.application.macCatalyst) // If macCatalyst
print(System.application.iosOnMac)    // If iOS app Running on Mac
print(System.application.processId)   // System information of process id
        
print(System.os.name)
print(System.os.version)
print(System.os.version.major)
print(System.os.version.minor)
print(System.os.version.path)
print(System.os.platform) // arm64
print(System.os.kernel)   // Darwin
print(System.os.node)     // Macbook.local
print(System.os.host)     // macbook.local
print(System.os.sign)     
print(System.os.user)
print(System.os.globalId)
print(System.os.login)
print(System.os.environment)
print(System.os.uptime)
        
print(System.device.name)         // MacBook Air 13"
print(System.device.model)        // MacBookAir
print(System.device.type)         // Mac
print(System.device.index)        // MacBookAir10,1
print(System.device.info)         // With Apple Silicon
print(System.device.cpu)          // Apple M1 CPU @ 3.2 GHz
print(System.device.year)         // 2020
print(System.device.manufacturer) // Apple inc.
print(System.device.ram)          // 16
print(System.device.lowPower)     // true
print(System.device.worksCPU)     // 6
print(System.device.coresCPU)     // 8
print(System.device.thermal)      // nominal
```

## Sample 2

### Get device information with index, another device:

```swift
let device = System.device("MacBookAir10,1")
        
print(device.name)  // MacBook Air 13"
print(device.model) // MacBookAir
print(device.type)  // Mac
print(device.index) // MacBookAir10,1
print(device.info)  // With Apple Silicon
print(device.cpu)   // Apple M1 CPU @ 3.2 GHz
print(device.year)  // 2020
```

## Sample 3

### Get Sysctl information:

If you want to see the entire list of available parameters, you can first execute the "sysctl -a" command in the macOS terminal. These same commands are also available on iOS. 
Use two methods for string strSysctl() and numerical intSysctl() parameters.

```swift
print(System.strSysctl("kern.version")
print(System.intSysctl("hw.l1icachesize")
```

### How it work:

I collected all the mechanisms to collect information in one convenient class.
This library also updates online data, taking it with GitHub when necessary. All data and descriptions are contained in the System.json file, so it is not at all necessary to update your application so that the data is relevant. This will happen automatically.

If you have questions, contact me. If you want to offer improvements or add a list of fresh Apple devices.
