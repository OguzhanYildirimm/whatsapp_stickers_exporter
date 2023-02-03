//
// Copyright (c) WhatsApp Inc. and its affiliates.
// All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree.
//

import UIKit

struct Interoperability {
	private static let DefaultBundleIdentifier: String = "WA.WAStickersThirdParty"
	private static let PasteboardExpirationSeconds: TimeInterval = 60
	private static let PasteboardStickerPackDataType: String = "net.whatsapp.third-party.sticker-pack"
	private static let WhatsAppURL: URL = URL(string: "whatsapp://stickerPack")!
	
	static var iOSAppStoreLink: String?
	static var AndroidStoreLink: String?
	
	static func canSend() -> Bool {
		return UIApplication.shared.canOpenURL(URL(string: "whatsapp://")!)
	}
	
	static func send(json: [String: Any]) -> Bool {
		if Bundle.main.bundleIdentifier?.contains(DefaultBundleIdentifier) == true {
			fatalError("Your bundle identifier must not include the default one.")
		}
		
		let pasteboard = UIPasteboard.general
		
		var jsonWithAppStoreLink: [String: Any] = json
		jsonWithAppStoreLink["ios_app_store_link"] = iOSAppStoreLink
		jsonWithAppStoreLink["android_play_store_link"] = AndroidStoreLink
		
		guard let dataToSend = try? JSONSerialization.data(withJSONObject: jsonWithAppStoreLink, options: []) else {
			return false
		}
		
		pasteboard.setItems([[PasteboardStickerPackDataType: dataToSend]], options: [UIPasteboard.OptionsKey.localOnly: true, UIPasteboard.OptionsKey.expirationDate: NSDate(timeIntervalSinceNow: PasteboardExpirationSeconds)])
		
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			if canSend() {
				UIApplication.shared.open(WhatsAppURL)
			}
		}
		return true
	}
	
	static func copyImageToPasteboard(image: UIImage) {
		UIPasteboard.general.image = image
	}
}
