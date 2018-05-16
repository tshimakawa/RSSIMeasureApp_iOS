//
//  ViewController.swift
//  RSSIMeasure_iOS
//
//  Created by 司嶋川 on 2018/04/27.
//  Copyright © 2018年 ISDL. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate {
    
    @IBOutlet weak var uuidText: UILabel!   //計測しているBLEBeaconのUUIDを表示する
    @IBOutlet weak var majorText: UILabel!  //計測しているBLEBeaconのmajorを表示する
    @IBOutlet weak var minorText: UILabel!  //計測しているBLEBeaconのminorを表示する
    @IBOutlet weak var rssiText: UILabel!   //計測しているBLEBeaconのRSSIを表示する
    @IBOutlet weak var controlButton: UIButton! //計測の開始や終了を操作するボタン
    
    var uuids:[String]!
    var proximityUUID : NSUUID!
    var region : CLBeaconRegion!
    var manager : CLLocationManager!
    var targetBeacon : CLBeacon!
    
    //CSVファイルの名前を格納する
    var textFileName:String!
    //ドキュメントファイルのパスを格納する
    var documentDirectoryFileURL:URL!
    //CSVファイルのパスを格納する
    var targetFilePath:URL!
    //コントロールボタンの状態把握に利用
    var flag:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ロケーションマネージャの作成.
        manager = CLLocationManager()
        //デリゲートの設定
        manager.delegate = self
        
        uuids = ["3DBD0100-1DDD-46AC-9E40-6B530FA0DF94","00000000-E30A-1001-B000-001C4D99F26D"]
        
//        //ログファイルの名前
//        textFileName = "rssi.csv"
        //ドキュメントファイルのパスを取得
        documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
//        //ドキュメントファイルのパスにファイル名を追加
//        targetFilePath = documentDirectoryFileURL.appendingPathComponent(textFileName)
        
        checkLocationAuthorization()
        // Do any additional setup after loading the view, typically from a nib.
    }

    //CCLocationManagerデリゲートの実装
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        manager.requestState(for: region)
        print("didStartMonitoring")
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for inRegion: CLRegion) {
        print("didDetermineState")
        manager.startRangingBeacons(in: inRegion as! CLBeaconRegion)
        //        if (state == .inside) {
        //            //領域内にはいったときに距離測定を開始
        //            manager.startRangingBeacons(in: self.region)
        //        }
    }
    
    /*
     リージョン監視失敗（bluetoosの設定を切り替えたりフライトモードを入切すると失敗するので１秒ほどのdelayを入れて、再トライするなど処理を入れること）*/
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("monitoringDidFailForRegion \(error)")
    }
    
    //通信失敗
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        manager.startRangingBeacons(in: region as! CLBeaconRegion)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        manager.stopRangingBeacons(in: region as! CLBeaconRegion)
    }
    
    
    //beaconsを受信するデリゲートメソッド。複数あった場合はbeaconsに入る
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        print(beacons)
        
        if(beacons.count == 0) {
            return
        }else{
            targetBeacon = beacons[0]
            uuidText.text = "\(targetBeacon.proximityUUID)"
            majorText.text = "\(targetBeacon.major)"
            minorText.text = "\(targetBeacon.minor)"
            rssiText.text = "\(targetBeacon.rssi)"

            targetFilePath = documentDirectoryFileURL.appendingPathComponent("\(targetBeacon.proximityUUID).csv")
            //ファイルが存在するかの場合わけに利用
            let checkValidation = FileManager.default

            //ファイルが存在するかで場合分け
            if (checkValidation.fileExists(atPath: (targetFilePath?.path)!)){//ファイルが存在する場合

                let text = "\(targetBeacon.proximityUUID)"+","+"\(targetBeacon.major)"+","+"\(targetBeacon.minor)"+","+"\(targetBeacon.rssi)"
                addwriteFile(targetFilePath: targetFilePath!, text: text)
            }else{//ファイルが存在しない場合
                let text = "Major"+","+"Minor"+","+"RSSI"+"\n"+"\(targetBeacon.major)"+","+"\(targetBeacon.minor)"+","+"\(targetBeacon.rssi)"
                writeFile(targetFilePath: targetFilePath!, text: text)
            }
        }
        
        /*
         beaconから取得できるデータ
         proximityUUID   :   regionの識別子
         major           :   識別子１
         minor           :   識別子２
         proximity       :   相対距離
         accuracy        :   精度
         rssi            :   電波強度
         */
    }
    
    
    @IBAction func controlButton_Push(_ sender: Any) {
        if(flag == 0){
            //self.manager.startMonitoring(for:self.region)
            
            for i in 0..<self.uuids.count{
                //UUIDからNSUUIDを作成
                proximityUUID = NSUUID(uuidString:uuids[i]);
                region = CLBeaconRegion(proximityUUID:proximityUUID! as UUID,identifier:"BLEBeacon\(i)")//リージョンの作成
                self.manager.startMonitoring(for: region)
            }
            
            flag = 1
            controlButton.setTitle("計測停止", for: .normal)
        }else if(flag == 1){
            //self.manager.stopRangingBeacons(in:self.region)
            for i in 0..<self.uuids.count{
                //UUIDからNSUUIDを作成
                proximityUUID = NSUUID(uuidString:uuids[i]);
                region = CLBeaconRegion(proximityUUID:proximityUUID! as UUID,identifier:"BLEBeacon\(i)")//リージョンの作成
                self.manager.stopRangingBeacons(in: region)
            }
            flag = 0
            controlButton.setTitle("計測開始", for: .normal)
        }
    }
    
    //ファイルを新規作成して書き込みor上書きするメソッド
    func writeFile(targetFilePath:URL,text:String){//ファイルが存在しない場合
        do {
            try text.write(to: targetFilePath, atomically: true, encoding: String.Encoding.shiftJIS)
        } catch let error as NSError {
            print("ファイル作成でエラー")
        }
    }
    
    //ファイルに追記するメソッド
    func addwriteFile(targetFilePath:URL,text:String){
        do {
            let fileHandle = try FileHandle(forWritingTo: targetFilePath)
            
            // 改行を入れる
            let stringToWrite = "\n" + text
            
            // ファイルの最後に追記
            fileHandle.seekToEndOfFile()
            fileHandle.write(stringToWrite.data(using: String.Encoding.shiftJIS)!)
            
        } catch let error as NSError {
            print("failed to append: \(error)")
            print("ファイル追記でエラー")
        }
        
    }
    
    //位置情報サービスの認証状態を取得
    func checkLocationAuthorization(){
        // セキュリティ認証のステータスを取得
        let status = CLLocationManager.authorizationStatus()
        /*
         位置情報サービスへの認証状態を取得する
         notDetermined   --  アプリ起動後、位置情報サービスへのアクセスを許可するかまだ選択されていない状態
         restricted      --  設定 > 一般 > 機能制限により位置情報サービスの利用が制限中
         denied          --  ユーザーがこのアプリでの位置情報サービスへのアクセスを許可していない
         authorized      --  位置情報サービスへのアクセスを許可している
         */
        switch status {
        case  .authorizedAlways:
            //iBeaconによる領域観測を開始する
            print("観測準備完了")
        case .notDetermined:
            print("許可承認")
            //デバイスに許可を促す
            self.manager.requestAlwaysAuthorization()
        case .restricted, .denied:
            //デバイスから拒否状態
            print("Restricted")
            self.manager.requestAlwaysAuthorization()
        default :
            print("default")
            self.manager.requestAlwaysAuthorization()
            break
        }
    }
}

