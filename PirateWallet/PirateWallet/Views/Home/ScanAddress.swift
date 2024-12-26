//
//  SendFlow.swift
//  PirateWallet
//
//  Created by Lokesh on 29/11/24.
//


import SwiftUI
import Combine
import AVFoundation

class ScanAddressViewModel: ObservableObject {
    let addressPublisher = PassthroughSubject<String,Never>()
    let scannerDelegate = CombineAdapter()
    var dispose = Set<AnyCancellable>()
    var shouldShowSwitchButton: Bool = true
    var showCloseButton: Bool = false
    @Published var showInvalidAddressMessage: Bool = false
    init(shouldShowSwitchButton: Bool, showCloseButton: Bool) {
        self.shouldShowSwitchButton = shouldShowSwitchButton
        self.showCloseButton = showCloseButton
        
        self.scannerDelegate.publisher.receive(on: DispatchQueue.main)
            .removeDuplicates(by: { $0 == $1 })
            .sink(receiveCompletion: { (completion) in
            switch completion {
            case .failure(let error):
                printLog("\(error)")
            case .finished:
                printLog("Finished")
            }
        }) { (address) in
            
            var mAddress = address
                        
            if let url:URL = URL(string: address) {
                
                if let actualCode = url.host {
                    mAddress = actualCode
                }else{
                    guard address.isValidAddress else {
                        
                        self.showInvalidAddressMessage = true
                        return
                    }
                    
                    mAddress = address
                }
            }else{
                guard address.isValidAddress else {
                    
                    self.showInvalidAddressMessage = true
                    return
                }
                
                mAddress = address
            }
            
           
            self.showInvalidAddressMessage = false
            self.addressPublisher.send(mAddress)
                
        }.store(in: &dispose)
    }
  
}

struct ScanAddress: View {

    @ObservedObject var viewModel: ScanAddressViewModel
    @State var cameraAccess: CameraAccessHelper.Status
    @Binding var isScanAddressShown: Bool
    @State var wrongAddressScanned = false
    @State var torchEnabled: Bool = false

    var scanFrame: some View {
        Image("QRCodeScanFrame")
            .padding()
    }
    
    var torchButton: AnyView {
        guard torchAvailable else { return AnyView(EmptyView()) }
        return AnyView(
            Button(action: {
                self.toggleTorch(on: !self.torchEnabled)
                self.torchEnabled.toggle()
            }) {
                Image("bolt")
                    .renderingMode(.template)
            }
        )
    }
    
    var authorized: some View {
          ZStack {
            QRCodeScannerView(delegate: viewModel.scannerDelegate)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                VStack {
                    scanFrame
                    Text("scan_invalidQR".localized())
                        .bold()
                        .scaledFont(size: 14)
                        .foregroundColor(.white)
                        .opacity(self.wrongAddressScanned ? 1 : 0)
                        .animation(.easeInOut)
                        .onReceive(viewModel.$showInvalidAddressMessage) { (value) in
                            
                            guard value else { return }
                            self.wrongAddressScanned = true
                            DeviceFeedbackHelper.vibrate()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                self.wrongAddressScanned = false
                            }
                    }
                }
                Spacer()
            }
        }
    }
    
    var unauthorized: some View {
         ZStack {
            ARRRBackground()
            VStack {
                Spacer()
                ZStack {
                    scanFrame
                    Text("We don't have permission to access your camera".localized())
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.all, 36)
                }
                Spacer()
                
                Button(action: {}){
                    ARRRButton(text: "scan_cameraunallowed".localized())
                        .frame(height: 50)
                }
                .padding()
            }
        }
    }
    
    var restricted: some View {
          ZStack {
            ARRRBackground()
            VStack {
             
                ZStack {
                    scanFrame
                    Text("scan_cameraunavaliable".localized())
                        .foregroundColor(.white)
                }
            }
        }
    }

    
    func viewFor(state: CameraAccessHelper.Status) -> some View {
        switch state {
        case .authorized, .undetermined:
            let auth = authorized.navigationBarTitle("send_scanQR".localized(), displayMode: .inline)
            
            if viewModel.showCloseButton {
                return AnyView(
                    auth.navigationBarItems(leading: torchButton, trailing:  ARRRCloseButton(action: {
                        
                            self.isScanAddressShown = false
                    }).frame(width: 30, height: 30))
                )
            }
            return AnyView(
                auth.navigationBarItems(
                    trailing: torchButton
                )
            )
        case .unauthorized:
            return AnyView(unauthorized)
        case .unavailable:
            return AnyView(restricted)
        }
    }
    
    var body: some View {
        viewFor(state: cameraAccess)
        .onDisappear() {
            self.toggleTorch(on: false)
        }
        .onAppear() {
            printLog("ScanAddress: onAppear")
        }
    }
    
    private var torchAvailable: Bool {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return false}
        return device.hasTorch
    }
    
    private func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        guard device.hasTorch else { printLog("Torch isn't available"); return }

        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            // Optional thing you may want when the torch it's on, is to manipulate the level of the torch
            if on { try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel) }
            device.unlockForConfiguration()
        } catch {
            printLog("Torch can't be used")
        }
    }
}
//
//struct ScanAddress_Previews: PreviewProvider {
//    static var previews: some View {
//        ScanAddress(isShown: .constant(false), showCloseButton: false, showSwitchButton: <#Bool#>)
//            .environmentObject(ZECCWalletEnvironment.shared)
//    }
//}
