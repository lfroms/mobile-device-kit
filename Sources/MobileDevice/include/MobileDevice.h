//
//  MobileDevice.h
//  MobileDevice
//
//  An interface to the private API of MobileDevice.framework.
//
//  Created by Lukas Romsicki on 2022-11-21.
//
//  Methods and constants sourced from my own personal introspection, as well as:
//    - http://theiphonewiki.com/wiki/index.php?title=MobileDevice_Library
//    - https://github.com/DerekSelander/mobdevim/blob/089e688de54fa29bb7280af530436ee32b02f721/mobdevim/misc/ExternalDeclarations.h
//    - https://github.com/tidev/node-ios-device/blob/8a7a93828559116b42e7d3d0f59974fa27455b45/src/mobiledevice.h
//

#ifndef MobileDevice_h
#define MobileDevice_h

#include <CoreFoundation/CoreFoundation.h>

// MARK: - Errors

/// General error.
typedef int AMDError;

/// A specific error that has occurred.
enum {
    kAMDSuccess = 0
};

/// Returns a human-readable description of an `AMDError`.
/// - Parameter error: The error to retrieve the description for.
CFStringRef AMDCopyErrorText(AMDError error);

// MARK: - Types

/// An opaque pointer to a single device.
typedef struct AMDevice *AMDeviceRef;

/// An opaque pointer to an Apple File Conduit connection.
typedef struct AFCConnection *AFCConnectionRef;

/// An opaque pointer an an Apple Mobile Device service connection.
typedef struct AMDServiceConnection *AMDServiceConnectionRef;

/// An opaque pointer to a notification.
typedef struct AMDeviceNotification *AMDeviceNotificationRef;

/// Events reported by `AMDeviceNotificationInfo`.
typedef enum {
    kAMDeviceConnected = 1,
    kAMDeviceDisconnected = 2,
    kAMDeviceUnsubscribed = 3,
} AMDeviceEvent;

/// Information returned by an `AMDeviceNotificationCallback`.
typedef struct AMDeviceNotificationInfo {
    AMDeviceRef device;
    AMDeviceEvent event;
} AMDeviceNotificationInfo;

/// The type of the connection of a device.
typedef enum {
    kAMDeviceInterfaceAny = 0,
    kAMDeviceInterfaceWired = 1,
    kAMDeviceInterfaceWireless = 2
} AMDeviceInterfaceType;

// MARK: - Callbacks

/// Callback used to report installation progress.
typedef void (*AMDeviceInstallationCallback)(CFDictionaryRef status, void *context);

/// Callback used to report connect/disconnect events of devices on the system.
typedef void (*AMDeviceNotificationCallback)(AMDeviceNotificationInfo *info, void *context);

// MARK: - Connections

/// Establishes a connection to the given device.
/// - Parameter device: The device to connect to.
AMDError AMDeviceConnect(AMDeviceRef device);

/// Disconnects from the device.
/// - Parameter device: The device to disconnect from
AMDError AMDeviceDisconnect(AMDeviceRef device);

// MARK: - Sessions

/// Starts a session with the given device.
/// - Parameter device: The device to start a session for.
AMDError AMDeviceStartSession(AMDeviceRef device);

/// Stops a session for a given device.
/// - Parameter device: The device to stop the session for.
AMDError AMDeviceStopSession(AMDeviceRef device);

// MARK: - Listing

/// Queries for devices currently connected to macOS.
CFArrayRef AMDCreateDeviceList(void);

/// Subscribes to device connect/disconnect events.
/// - Parameters:
///   - callback: Callback when a new event is produced.
///   - unknown: Unknown
///   - interface_type: The type of interface through which the device is connected.
///   - context: Argument to pass to the provided `callback`.
///   - notification: A returned reference to the notification subscribed to.
///   - options: Options to pass to the operation.
AMDError AMDeviceNotificationSubscribeWithOptions(
    AMDeviceNotificationCallback callback,
    UInt32 unknown,
    AMDeviceInterfaceType interface_type,
    void *context,
    AMDeviceNotificationRef *notification,
    CFDictionaryRef options
);

/// Unsubscribes from the given notification.
/// - Parameter notification: The notification to unsubscribe from.
AMDError AMDeviceNotificationUnsubscribe(AMDeviceNotificationRef notification);

// MARK: - Devices

#define kAMDDeviceNameKey           CFSTR("DeviceName")
#define kAMDBuildVersionKey         CFSTR("BuildVersion")
#define kAMDProductTypeKey          CFSTR("ProductType")
#define kAMDProductVersionKey       CFSTR("ProductVersion")
#define kAMDDeviceClassKey          CFSTR("DeviceClass")

/// Copies the device identifier.
/// - Parameter device: The device to copy the device identifier from.
CFStringRef AMDeviceCopyDeviceIdentifier(AMDeviceRef device);

/// Copies the specified value from a given device.
/// - Parameters:
///   - device: The device to copy the value from.
///   - domain: Optional domain that the value is found in.
///   - key: The key under which the value is stored.
CFTypeRef AMDeviceCopyValue(AMDeviceRef device, CFStringRef domain, CFStringRef key);

/// Returns the interface type
/// - Parameter device: The device to get the interface for.
AMDeviceInterfaceType AMDeviceGetInterfaceType(AMDeviceRef device);

/// Gets the status of developer mode.
/// - Parameters:
///   - device: The device to get the developer mode status for.
///   - error: Any error that may have occurred.
bool AMDeviceCopyDeveloperModeStatus(AMDeviceRef device,AMDError *error);

/// Starts a service on the device.
/// - Parameters:
///   - device: The device to start the service on.
///   - service_name: The name (identifier) of the service to start.
///   - options: Options to start the service with.
///   - service_connection: A returned reference to a service connection.
AMDError AMDeviceSecureStartService(
    AMDeviceRef device,
    CFStringRef service_name,
    CFDictionaryRef options,
    AMDServiceConnectionRef *service_connection
);

// MARK: - Installation

#define kAFCServiceName             CFSTR("com.apple.afc")

#define kAMDPackageTypeKey          CFSTR("PackageType")
#define kAMDPackageTypeCustomer     CFSTR("Customer")
#define kAMDPackageTypeDeveloper    CFSTR("Developer")

/// Transfers the given application bundle to the device securely.
/// - Parameters:
///   - afc_connection: Optional reference to an Apple File Conduit connection.
///   - device: The device to transfer the application to.
///   - bundle_url: The URL of the application bundle.
///   - options: Dictionary of options to use.
///   - callback: Callback with status updates during the transfer process.
///   - context: Argument to pass to the provided `callback`.
AMDError AMDeviceSecureTransferPath(
    AFCConnectionRef afc_connection,
    AMDeviceRef device,
    CFURLRef bundle_url,
    CFDictionaryRef options,
    AMDeviceInstallationCallback callback,
    void *context
);

/// Installs the given application bundle to the device securely.
/// - Parameters:
///   - service_connection: Optional reference to a Mobile Device service connection.
///   - device: The device to install the applicaiton on.
///   - bundle_url: The URL of the application bundle.
///   - options: Dictionary of options to use.
///   - callback: Callback with status updates during the transfer process.
///   - context: Argument to pass to the provided `callback`.
AMDError AMDeviceSecureInstallApplication(
    AMDServiceConnectionRef service_connection,
    AMDeviceRef device,
    CFURLRef bundle_url,
    CFDictionaryRef options,
    AMDeviceInstallationCallback callback,
    void *context
);

#endif /* MobileDevice_h */
