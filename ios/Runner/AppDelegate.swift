import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate
//,RyftProtocol
{
        
//    func getCallback(strResult: String) {
//
//        self.ryftResult?(strResult)
//
//        print(strResult)
//    }
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let ryftPaymentGatewayChannel = FlutterMethodChannel(name: "ryftPaymentGatewayInitiate",binaryMessenger: controller.binaryMessenger)
        ryftPaymentGatewayChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if call.method == "initiatePayment"{
                                
                print("Navite iOS call if")
                
                guard let objRyftVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RyftViewController") as? RyftViewController else {
                    return
                }
                
                var paymentMethodType : String?
                
                if let arguments = call.arguments as? [String: Any] {
                    paymentMethodType = arguments["paymentMethodType"] as? String

                    objRyftVC.paymentMethodType = arguments["paymentMethodType"] as? String
                    objRyftVC.publishableKey = arguments["publishableKey"] as? String
                    objRyftVC.clientSecret = arguments["clientSecret"] as? String
                    objRyftVC.subAccountId = arguments["subAccountId"] as? String
                }
                
//                objRyftVC.delegateRft = self
                objRyftVC.result = result
                objRyftVC.modalPresentationStyle = .overFullScreen
                controller.present(objRyftVC, animated: false)
            } else {
                print("Navite iOS call else")
                result(FlutterMethodNotImplemented)
            }
        })
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
