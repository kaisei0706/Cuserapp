//
//  PostViewController.swift
//  cuser
//
//  Created by 岩田海靖 on 2020/09/09.
//  Copyright © 2020 kaisei.iwata. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD


class PostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    var image: UIImage!
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var adressTextField: UITextField!
    @IBOutlet weak var staTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var explainTextField: UITextField!
    
    
    
    @IBAction func imagepostButton(_ sender: Any) {
        let picker = UIImagePickerController() //アルバムを開く処理を呼び出す
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
        self.present(picker, animated: true, completion: nil)
        }
    
    // 画像が選択された時に呼ばれる
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])  {
        if let selectedImage = info[.originalImage] as? UIImage {
            photoImageView.image = selectedImage  //imageViewにカメラロールから選んだ画像を表示する
        }
        self.dismiss(animated: true)  //画像をImageViewに表示したらアルバムを閉じる
    }
    
    // 画像選択がキャンセルされた時に呼ばれる
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handlePostButton(_ sender: Any) {
        image = photoImageView.image
        if ( image != nil ) {
            // 画像をJPEG形式に変換する
            let imageData = image.jpegData(compressionQuality: 0.75)
                // 画像と投稿データの保存場所を定義する
                let postRef = Firestore.firestore().collection(Const.PostPath).document()
                let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postRef.documentID + ".jpg")
                // HUDで投稿処理中の表示を開始
                SVProgressHUD.show()
                // Storageに画像をアップロードする
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                imageRef.putData(imageData!, metadata: metadata) { (metadata, error) in
                    if error != nil {
                        // 画像のアップロード失敗
                        print(error!)
                        SVProgressHUD.showError(withStatus: "画像のアップロードが失敗しました")
                        // 投稿処理をキャンセルし、先頭画面に戻る
                        UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
                        return
                    }
                    // FireStoreに投稿データを保存する
                    let name = Auth.auth().currentUser?.displayName
                    let postDic = [
                        "name": self.nameTextField.text!,
                        "adress": self.adressTextField.text!,
                        "station": self.staTextField.text!,
                        "price": self.priceTextField.text!,
                        "time": self.timeTextField.text!,
                        "explain": self.explainTextField.text!,
                        "date": FieldValue.serverTimestamp(),
                        ] as [String : Any]
                    postRef.setData(postDic)
                    // HUDで投稿完了を表示する
                    SVProgressHUD.showSuccess(withStatus: "投稿しました")
                    // 投稿処理が完了したので先頭画面に戻る
                   UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
                }
        }
        
        
    }

    @IBAction func handleCancelButton(_ sender: Any) {
        // 加工画面に戻る
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
