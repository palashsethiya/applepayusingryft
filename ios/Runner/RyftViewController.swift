//
//  ViewController.swift
//  RyftPaymentGateway
//
//  Created by Mac_Mini2 on 22/01/24.
//

import UIKit
import RyftCore
import RyftUI

//protocol RyftProtocol {
//    func getCallback(strResult : String)
//}

class ApplePayComponentDelegateTester: RyftApplePayComponentDelegate {
    func applePayPayment(finishedWith status: RyftApplePayComponent.RyftApplePayPaymentStatus) {
        print("applePayPayment called with status: \(status)")
        switch status {
        case .cancelled:
            // Handle user cancellation
            print("Apple Pay was cancelled by the user.")
//            self.dismissPresenter(resultStr: "Apple Pay was cancelled by the user.", paymentSessionId: nil)
        case .error(let error, let paymentError):
            // Handle error
                print("Payment error occurred")
//            self.dismissPresenter(resultStr: "Payment error occurred", paymentSessionId: nil)
        case .success(let paymentSession):
            // Handle successful payment
            print("Payment was successful. Payment session: \(paymentSession)")
//            self.dismissPresenter(resultStr: "Payment was successful. Payment session: \(paymentSession)", paymentSessionId: nil)
            // Optionally, you can navigate to a receipt view or update the UI
        }
    }
}

class RyftViewController: UIViewController, RyftDropInPaymentDelegate, RyftRequiredActionDelegate {
    
    private var ryftDropIn: RyftDropInPaymentViewController?
    private var ryftApiClient: RyftApiClient?
    var publishableKey : String?
    var paymentMethodType : String?
    var clientSecret : String?
    var subAccountId : String?
    
    let applePayDelegateTester = ApplePayComponentDelegateTester()
    
    //    var delegateRft : RyftProtocol?
    var result : FlutterResult?

    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        self.showDropIn()
                
        ryftApiClient = DefaultRyftApiClient(publicApiKey: publishableKey!)
        
        if(paymentMethodType == "dropIn"){
            self.ryftPaymentThroughDropIn()
        } else if(paymentMethodType == "applePay"){
            self.ryftPaymentThroughApplePay()
        }
    }
    
    @objc private func ryftPaymentThroughDropIn() {
            ryftDropIn = RyftDropInPaymentViewController(
                config: RyftDropInConfiguration(
                    clientSecret: clientSecret!,
                    applePay: RyftApplePayConfig(
                        merchantIdentifier: "merchant.com.siyatech.rateddriving",
                        merchantCountryCode: "GB",
                        merchantName: "Rated Driving"
                    )
                ),
                publicApiKey: publishableKey!,
                delegate: self
            )
            present(ryftDropIn!, animated: true, completion: nil)
    }

    @objc private func ryftPaymentThroughApplePay() {
        let config = RyftApplePayConfig(
            merchantIdentifier: "merchant.com.siyatech.rateddriving",
            merchantCountryCode: "GB",
            merchantName: "Rated Driving"
        )
        // create a fresh instance each time you want to display the ApplePay sheet
        let applePayComponent = RyftApplePayComponent(
            publicApiKey: publishableKey!,
            clientSecret: clientSecret!,
            accountId: subAccountId!,
            config: .auto(config: config),
            delegate: applePayDelegateTester
        )
        print("Setting delegate to self")
        applePayComponent?.present { presented in
            if !presented {
                /*
                * something went wrong with presenting the ApplePay sheet
                * show an alert or retry
                */
//                self.applePayButton.isEnabled = true
                print("something went wrong with presenting the ApplePay sheet")
            } else {
                print("Presenting the ApplePay sheet")
            }
        }
    }
    
//    func applePayPayment(finishedWith status: RyftApplePayComponent.RyftApplePayPaymentStatus) {
//        print("applePayPayment called with status: \(status)")
//        switch status {
//        case .cancelled:
//            // Handle user cancellation
//            print("Apple Pay was cancelled by the user.")
//            self.dismissPresenter(resultStr: "Apple Pay was cancelled by the user.", paymentSessionId: nil)
//        case .error(let error, let paymentError):
//            // Handle error
//                print("Payment error occurred")
//            self.dismissPresenter(resultStr: "Payment error occurred", paymentSessionId: nil)
//        case .success(let paymentSession):
//            // Handle successful payment
//            print("Payment was successful. Payment session: \(paymentSession)")
//            self.dismissPresenter(resultStr: "Payment was successful. Payment session: \(paymentSession)", paymentSessionId: nil)
//            // Optionally, you can navigate to a receipt view or update the UI
//        }
//    }

    private func handle3DSecure(with responseData: Data){
        do {
               // Decode the response data into the appropriate type
               let paymentSession = try JSONDecoder().decode(RyftCore.PaymentSession.self, from: responseData)
               
               // Extract the required action from the payment session
               if let requiredAction = paymentSession.requiredAction {
                   let config = RyftRequiredActionComponent.Configuration(
                       clientSecret: clientSecret!,
                       accountId: subAccountId!
                   )
                   
                   // Create a fresh instance of RyftRequiredActionComponent
                   let component = RyftRequiredActionComponent(
                       config: config,
                       apiClient: DefaultRyftApiClient(publicApiKey: publishableKey!)
                   )
                   
                   component.delegate = self
                   component.handle(action: requiredAction)
               } else {
                   // Handle the case where requiredAction is nil
                   print("No required action found in the payment session response.")
               }
           } catch {
               // Handle decoding errors
               print("Error decoding payment session response: \(error)")
           }
    }
    
    public func onRequiredActionInProgress() {
        /*
        * (optional)
        * the component is performing some asynchronous task
        * show your loading indicator/screen
        */
    }
    
    public func onRequiredActionHandled(result: Result<PaymentSession, Error>) {
        /*
        * The action has completed with either the updated PaymentSession, or an Error
        */
        
        DispatchQueue.main.async {
            switch result {
            case .success(let updatedPaymentSession):
                // Extract the data from the payment session and call your function
                self.dismissPresenter(resultStr: "SUCCESS", paymentSessionId: nil)
            case .failure(let error):
                // Handle the failure case, e.g., log the error or show an error message
                print("Failed")
                self.dismissPresenter(resultStr: "FAILED", paymentSessionId: nil)
                
                print("error handling required action \(error)")
            }
        }
    }
    
    func showAlertDialog(title: String, message: String, isDropInFailed: Bool){
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .default) { _ in
            self.dismissPresenter(resultStr: "FAILED", paymentSessionId: nil)
        })

        if(isDropInFailed)
        {
            alert.addAction(UIAlertAction(title: "Try again", style: .default) { _ in
                self.ryftPaymentThroughDropIn()
            })
        } else {
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.dismissPresenter(resultStr: "FAILED", paymentSessionId: nil)
            })
        }
        present(alert, animated: true, completion: nil)
    }

    func onPaymentResult(result: RyftPaymentResult) {
        switch result {
        case .success:
            print("success")
            print(result.self)
            
            self.dismissPresenter(resultStr: "SUCCESS", paymentSessionId: nil)

            //showSuccessView()
        case .pendingAction(let paymentSession, let requiredAction):
            ryftDropIn?.handleRequiredAction(
                returnUrl: URL(string: paymentSession.returnUrl),
                requiredAction
            )
        // `error.displayError` provides a human friendly message you can display
        case .failed(let error):
            print(error)
            showAlertDialog(title: "Alert!!", message: error.displayError, isDropInFailed: true)
        case .cancelled:
            print("cancelled")
            self.dismissPresenter(resultStr: "CANCELLED", paymentSessionId: nil)
            break
        }
    }
    
    func dismissPresenter(resultStr : String, paymentSessionId : String?)
    {
        DispatchQueue.main.async {
            //self.delegateRft?.getCallback(strResult: result)
                if(resultStr == "SUCCESS")
                {
                    var map: [String: String] = [:]
                    map["paymentSessionId"] = paymentSessionId
                    map["result"] = resultStr
                    
                    var mapString = "{"
                    for (key, value) in map {
                        mapString += "\"\(key)\"=\"\(value)\","
                    }
                    mapString.removeLast() // Remove the trailing comma
                    mapString += "}"

                    self.result?(mapString)
                } else {
                    self.result?(FlutterError(code: "Ryft Payment Alert!",                                                                      
                                              message: resultStr,
                                              details: nil))
                }
            self.dismiss(animated: false)
        }
    }
}

